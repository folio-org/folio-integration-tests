# For MODINVOICE-346
Feature: Approve an invoice with a negative line

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Approve an invoice with a negative line
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid

    # 1. Create finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 6. Create 3 invoice lines linked to the po line
    * table invoiceLines
      | description      | total  | invoiceLineId  |
      | 'invoice line 1' | 10.0   | invoiceLineId1 |
      | 'invoice line 2' | 10.0   | invoiceLineId2 |
      | 'invoice line 3' | 10.0   | invoiceLineId3 |
    * def v = call createInvoiceLine invoiceLines

    # 7. Update second invoice line
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    * def invoiceLine = $
    * set invoiceLine.total = -invoiceLine.total
    * set invoiceLine.subTotal = -invoiceLine.subTotal

    Given path 'invoice/invoice-lines', invoiceLineId2
    And request invoiceLine
    When method PUT
    Then status 204

    # 8. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 9. Check the budget encumbrance
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match response.budgets[0].encumbered == 0
