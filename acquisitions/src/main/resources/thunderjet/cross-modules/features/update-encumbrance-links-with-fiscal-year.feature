# For MODINVOICE-474
Feature: Update encumbrance links with fiscal year

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def codePrefix = callonce random_string
    * def currentYear = callonce getCurrentYear
    * def pastYear = currentYear - 1
    * def currentStart = currentYear + '-01-01T00:00:00Z'
    * def currentEnd = currentYear + '-12-30T23:59:59Z'
    * def pastStart = pastYear + '-01-01T00:00:00Z'
    * def pastEnd = pastYear + '-12-30T23:59:59Z'
    * def pastFiscalYearId = callonce uuid { n: 1 }
    * def currentFiscalYearId = callonce uuid { n: 2 }
    * def ledgerId = callonce uuid { n: 3 }
    * def fundId = callonce uuid { n: 4 }
    * def pastBudgetId = callonce uuid { n: 5 }
    * def currentBudgetId = callonce uuid { n: 6 }

    # Create finances
    * def v = callonce createFiscalYear { id: '#(pastFiscalYearId)', code: '#(codePrefix + pastYear)', periodStart: '#(pastStart)', periodEnd: '#(pastEnd)', series: '#(codePrefix)' }
    * def v = callonce createFiscalYear { id: '#(currentFiscalYearId)', code: '#(codePrefix + currentYear)', periodStart: '#(currentStart)', periodEnd: '#(currentEnd)', series: '#(codePrefix)' }
    * def v = callonce createLedger { id: '#(ledgerId)', fiscalYearId: '#(pastFiscalYearId)', restrictEncumbrance: false, restrictExpenditures: false }
    * def v = callonce createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = callonce createBudget { id: '#(pastBudgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active', fiscalYearId: '#(pastFiscalYearId)' }
    * def v = callonce createBudget { id: '#(currentBudgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active', fiscalYearId: '#(currentFiscalYearId)' }


  Scenario: Using invoice in past fiscal year, create an invoice line, encumbrance link is changed to past fiscal year
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def pastEncumbranceId = call uuid

    # 1. Create the order and order line
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Get the current encumbrance id
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def currentEncumbranceId = poLine.fundDistribution[0].encumbrance

    # 3. Create the past encumbrance
    * def v = call createTransaction { id: '#(pastEncumbranceId)', transactionType: 'Encumbrance', fiscalYearId: '#(pastFiscalYearId)', fundId: '#(fundId)', amount: 10.0, orderId: '#(orderId)', poLineId: '#(poLineId)' }

    # 4. Create an invoice in the past fiscal year
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(pastFiscalYearId)' }

    # 5. Add an invoice line linked to a po line, using the encumbrance in the current fiscal year
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(currentEncumbranceId)', total: 10 }

    # 6. Check the encumbrance link was changed to use the past fiscal year encumbrance
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

    # 1. Create the order and order lines
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId)', fundId: '#(fundId)' }
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId)', fundId: '#(fundId)' }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Get the current encumbrance ids
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

    # 3. Create one past encumbrance
    * def v = call createTransaction { id: '#(pastEncumbranceId)', transactionType: 'Encumbrance', fiscalYearId: '#(pastFiscalYearId)', fundId: '#(fundId)', amount: 10.0, orderId: '#(orderId)', poLineId: '#(poLineId1)' }

    * print "Create an invoice in the current fiscal year"
    * def v = call createInvoice { id: '#(invoiceId)' }

    * print "Add invoice lines linked to the po lines, using the encumbrances in the current fiscal year"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId1)', fundId: '#(fundId)', encumbranceId: '#(currentEncumbranceId1)', total: 10 }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId2)', fundId: '#(fundId)', encumbranceId: '#(currentEncumbranceId2)', total: 10 }

    # 4. Change the invoice to use the past fiscal year
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.fiscalYearId = pastFiscalYearId
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    # 5. Check the encumbrance links were changed to use the past fiscal year encumbrances
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == pastEncumbranceId
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == '#notpresent'

    # 6. Change the invoice to use the current fiscal year
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.fiscalYearId = currentFiscalYearId
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    # 7. Check the encumbrance links were changed to use the current fiscal year encumbrances
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == currentEncumbranceId1
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.fundDistributions[0].encumbrance == currentEncumbranceId2
