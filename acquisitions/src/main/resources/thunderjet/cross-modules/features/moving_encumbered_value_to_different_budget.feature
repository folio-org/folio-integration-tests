# For MODORDERS-800
@parallel=false
Feature: Moving encumbered value from budget 1 to budget 2

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

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
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    Examples:
      | fundId  | budgetId  |
      | fundId1 | budgetId1 |
      | fundId2 | budgetId2 |


  Scenario: Create an order
    * def v = call createOrder { id: '#(orderId)' }

  Scenario: Create a po line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', paymentStatus: 'Awaiting Payment', receiptStatus: 'Partially Received' }

  Scenario: Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

  Scenario: Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

  Scenario: Create an invoice line from the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', total: 1 }

  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

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
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

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