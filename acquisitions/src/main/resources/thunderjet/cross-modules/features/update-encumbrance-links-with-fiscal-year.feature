# and https://issues.folio.org/browse/MODINVOICE-474
@parallel=false
Feature: Update encumbrance links with fiscal year

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-audit-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')
    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createTransaction = read('classpath:thunderjet/mod-finance/reusable/createTransaction.feature')

    * def currentYear = callonce getCurrentYear
    * def currentStart = currentYear + '-01-01T00:00:00Z'
    * def currentEnd = currentYear + '-12-30T23:59:59Z'
    * def pastFiscalYearId = callonce uuid1
    * def currentFiscalYearId = callonce uuid2
    * def ledgerId = callonce uuid3
    * def fundId = callonce uuid4
    * def pastBudgetId = callonce uuid5
    * def currentBudgetId = callonce uuid6


  Scenario: Create finances
    * configure headers = headersAdmin
    * def v = call createFiscalYear { id: #(pastFiscalYearId), code: 'INVTEST2020', periodStart: '2020-01-01T00:00:00Z', periodEnd: '2020-12-30T23:59:59Z', series: 'INVTEST' }
    * def v = call createFiscalYear { id: #(currentFiscalYearId), code: #('INVTEST' + currentYear), periodStart: #(currentStart), periodEnd: #(currentEnd), series: 'INVTEST' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(pastFiscalYearId), restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { 'id': '#(fundId)', ledgerId: #(ledgerId) }
    * def v = call createBudget { 'id': '#(pastBudgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active', fiscalYearId: #(pastFiscalYearId) }
    * def v = call createBudget { 'id': '#(currentBudgetId)', 'allocated': 100, 'fundId': '#(fundId)', 'status': 'Active', fiscalYearId: #(currentFiscalYearId) }


  Scenario: Using invoice in past fiscal year, create an invoice line, encumbrance link is changed to past fiscal year
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def pastEncumbranceId = call uuid

    * print "Create the order and order line"
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }
    * def v = call openOrder { orderId: #(orderId) }

    * print "Get the current encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def currentEncumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Create the past encumbrance"
    * configure headers = headersAdmin
    Given path 'finance/order-transaction-summaries', orderId
    And request
    """
      {
        "id": "#(orderId)",
        "numTransactions": 1
      }
    """
    When method PUT
    Then status 204
    * def v = call createTransaction { id: #(pastEncumbranceId), transactionType: 'Encumbrance', fiscalYearId: #(pastFiscalYearId), fundId: #(fundId), amount: 10.0, orderId: #(orderId), poLineId: #(poLineId) }
    * configure headers = headersUser

    * print "Create an invoice in the past fiscal year"
    * def v = call createInvoice { id: #(invoiceId), fiscalYearId: #(pastFiscalYearId) }

    * print "Add an invoice line linked to a po line, using the encumbrance in the current fiscal year"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(currentEncumbranceId), total: 10 }

    * print "Check the encumbrance link was changed to use the past fiscal year encumbrance"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == pastEncumbranceId


  Scenario: Change invoice to use past fiscal year and then current fiscal year, encumbrance links are updated
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def pastEncumbranceId = call uuid

    * print "Create the order and order lines"
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId1), orderId: #(orderId), fundId: #(fundId) }
    * def v = call createOrderLine { id: #(poLineId2), orderId: #(orderId), fundId: #(fundId) }
    * def v = call openOrder { orderId: #(orderId) }

    * print "Get the current encumbrance ids"
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def poLine = $
    * def currentEncumbranceId1 = poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    * def poLine = $
    * def currentEncumbranceId2 = poLine.fundDistribution[0].encumbrance

    * print "Create one past encumbrance"
    * configure headers = headersAdmin
    Given path 'finance/order-transaction-summaries', orderId
    And request
    """
      {
        "id": "#(orderId)",
        "numTransactions": 1
      }
    """
    When method PUT
    Then status 204
    * def v = call createTransaction { id: #(pastEncumbranceId), transactionType: 'Encumbrance', fiscalYearId: #(pastFiscalYearId), fundId: #(fundId), amount: 10.0, orderId: #(orderId), poLineId: #(poLineId1) }
    * configure headers = headersUser

    * print "Create an invoice in the current fiscal year"
    * def v = call createInvoice { id: #(invoiceId) }

    * print "Add invoice lines linked to the po lines, using the encumbrances in the current fiscal year"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId1), invoiceId: #(invoiceId), poLineId: #(poLineId1), fundId: #(fundId), encumbranceId: #(currentEncumbranceId1), total: 10 }
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId2), invoiceId: #(invoiceId), poLineId: #(poLineId2), fundId: #(fundId), encumbranceId: #(currentEncumbranceId2), total: 10 }

    * print "Change the invoice to use the past fiscal year"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.fiscalYearId = pastFiscalYearId
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    * print "Check the encumbrance links were changed to use the past fiscal year encumbrances"
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == pastEncumbranceId
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == '#notpresent'

    * print "Change the invoice to use the current fiscal year"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.fiscalYearId = currentFiscalYearId
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    * print "Check the encumbrance links were changed to use the current fiscal year encumbrances"
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == currentEncumbranceId1
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == currentEncumbranceId2

