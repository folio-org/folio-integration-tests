# For MODORDERS-803
Feature: Should fail updating fund in poLine when related invoice is approved

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Should fail updating fund in poLine when related invoice is approved
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Prepare finances
    * table funds
      | id      |
      | fundId1 |
      | fundId2 |
    * def v = call createFund funds
    * table budgets
      | id        | fundId  | allocated |
      | budgetId1 | fundId1 | 1000      |
      | budgetId2 | fundId2 | 1000      |
    * def v = call createBudget budgets

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create a po line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', paymentStatus: 'Awaiting Payment', receiptStatus: 'Partially Received' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 6. Create an invoice line linked to the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', total: 10 }

    # 7. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 8. Check the budget
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    # 9. Try to update fundId in poLine
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
    Then status 403
    And match response.errors[0].code == "poLineHasRelatedApprovedInvoice"
