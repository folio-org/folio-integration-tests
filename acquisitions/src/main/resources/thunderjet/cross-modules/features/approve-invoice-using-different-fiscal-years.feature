# For https://issues.folio.org/browse/MODINVOICE-387
# and https://issues.folio.org/browse/MODFISTO-293
@parallel=false
Feature: Approve an invoice using different fiscal years

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
    * def poFyId = callonce uuid1
    * def poLedgerId = callonce uuid2
    * def fundId1 = callonce uuid3
    * def fundId2 = callonce uuid4
    * def fundId3 = callonce uuid5
    * def budgetId1 = callonce uuid6
    * def budgetId2 = callonce uuid7
    * def budgetId3 = callonce uuid8
    * def orderId1 = callonce uuid9
    * def orderId2 = callonce uuid10
    * def poLineId1 = callonce uuid11
    * def poLineId2 = callonce uuid12
    * def invoiceId = callonce uuid13
    * def invoiceLineId1 = callonce uuid14
    * def invoiceLineId2 = callonce uuid15
    * def invoiceLineId3 = callonce uuid16
    * def invoiceLineId4 = callonce uuid17
    * def fundCode1 = 'FUND1'
    * def fundCode2 = 'FUND2'
    * def fundCode3 = 'FUND3'
    * def possibleMessage1 = 'Multiple fiscal years are used with the funds ' + fundCode1 + ' and ' + fundCode3 + '.'
    * def possibleMessage2 = 'Multiple fiscal years are used with the funds ' + fundCode3 + ' and ' + fundCode1 + '.'

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')


  Scenario: Create a new fiscal year using the same range as the current one, and the associated ledger
    * configure headers = headersAdmin
    Given path 'finance/fiscal-years', globalFiscalYearId
    When method GET
    Then status 200
    * def currentFiscalYear = $

    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": "#(poFyId)",
      "name": "Product Owner Fiscal Year 1",
      "code": "#('PO' + currentFiscalYear.code)",
      "description": "Fiscal year series used by product owner for testing",
      "periodStart": "#(currentFiscalYear.periodStart)",
      "periodEnd": "#(currentFiscalYear.periodEnd)",
      "series": "POFY"
    }
    """
    When method POST
    Then status 201

    * call createLedger { id: #(poLedgerId), fiscalYearId: #(poFyId) }


  Scenario: Create funds and budgets
    * configure headers = headersAdmin
    # funds 1 and 2 use the same fiscal year, fund 3 uses the other one
    * call createFund { id: #(fundId1), code: #(fundId1), ledgerId: #(globalLedgerId) }
    * call createBudget { id: #(budgetId1), fundId: #(fundId1), fiscalYearId: #(globalFiscalYearId), allocated: 1000, status: 'Active' }
    * call createFund { id: #(fundId2), code: '#(fundId2)', ledgerId: #(globalLedgerId) }
    * call createBudget { id: #(budgetId2), fundId: #(fundId2), fiscalYearId: #(globalFiscalYearId), allocated: 1000, status: 'Active' }
    * call createFund { id: #(fundId3), code: #(fundId3), ledgerId: #(poLedgerId) }
    * call createBudget { id: #(budgetId3), fundId: #(fundId3), fiscalYearId: #(poFyId), allocated: 1000, status: 'Active' }


  Scenario: Create order 1
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId1)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Add order line 1 using fund 1
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId1
    * set poLine.fundDistribution[0].fundId = fundId1
    * set poLine.fundDistribution[0].code = fundId1
    * set poLine.cost.listUnitPrice = 10
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Create order 2
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId2)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Add order line 2 using fund 3
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * set poLine.fundDistribution[0].fundId = fundId3
    * set poLine.fundDistribution[0].code = fundId3
    * set poLine.cost.listUnitPrice = 10
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Create an invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201


  Scenario: Add invoice line 1 linked to po line 1
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId1
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId1
    * set invoiceLine.fundDistributions[0].fundId = fundId1
    * set invoiceLine.fundDistributions[0].code = fundCode1
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Add invoice line 2 linked to po line 1
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId2
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId1
    * set invoiceLine.fundDistributions[0].fundId = fundId1
    * set invoiceLine.fundDistributions[0].code = fundCode1
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Add invoice line 3 linked to po line 1
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId3
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId1
    * set invoiceLine.fundDistributions[0].fundId = fundId1
    * set invoiceLine.fundDistributions[0].code = fundCode1
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Add invoice line 4 linked to po line 2
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId4
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId2
    * set invoiceLine.fundDistributions[0].fundId = fundId3
    * set invoiceLine.fundDistributions[0].code = fundCode3
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422
    * def message = $.errors[0].message
    And assert message == possibleMessage1 || message == possibleMessage2


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422


  Scenario: Try to approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 422
    * def message = $.errors[0].message
    And assert message == possibleMessage1 || message == possibleMessage2


  Scenario: Change invoice line 4 fund distribution to use fund 2
    Given path 'invoice/invoice-lines', invoiceLineId4
    When method GET
    Then status 200
    * def invoiceLine = $
    * set invoiceLine.fundDistributions[0].fundId = fundId2
    * set invoiceLine.fundDistributions[0].code = fundCode2
    * remove invoiceLine.fundDistributions[0].encumbrance
    Given path 'invoice/invoice-lines', invoiceLineId4
    And request invoiceLine
    When method PUT
    Then status 204


  Scenario: Approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


  Scenario: Pay the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204
