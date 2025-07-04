@parallel=false
# for https://issues.folio.org/browse/MODORDERS-800
Feature: Moving encumbered value from budget 1 to budget 2

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def budgetId1 = callonce uuid3
    * def budgetId2 = callonce uuid4
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId = callonce uuid8

  Scenario Outline: Prepare finances
    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    Examples:
      | fundId  | budgetId  |
      | fundId1 | budgetId1 |
      | fundId2 | budgetId2 |


  Scenario: Create an order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

  Scenario: Create a po line
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId1
    * set poLine.fundDistribution[0].code = fundId1
    * set poLine.paymentStatus = 'Awaiting Payment'
    * set poLine.receiptStatus = 'Partially Received'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

  Scenario: Create an invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

  Scenario: Create a invoice line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId1
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.total = 1
    * set invoiceLine.subTotal = 1
    * remove invoiceLine.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

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

  Scenario: Check the budget after invoice approve
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 1
    And match $.available == 999
    And match $.awaitingPayment == 1
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

  Scenario: Cancel the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Cancelled'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Check the budget after invoice cancel
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 1
    And match $.available == 999
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 1

  Scenario: Update fundId in poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.fundDistribution[0].fundId = fundId2
    * set poLine.fundDistribution[0].code = fundId2
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

  Scenario: Check the previous budget
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1000
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

  Scenario: Check the current budget
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 1
    And match $.available == 999
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 1