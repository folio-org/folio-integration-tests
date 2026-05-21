# For MODORDERS-638
Feature: Pay invoice with new expense class

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Pay invoice with new expense class
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line without using an expense class
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Add an expense class to the budget
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = $

    * set budget.statusExpenseClasses = [ { expenseClassId: '#(globalElecExpenseClassId)' } ]

    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    # 6. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 7. Add an invoice line with the expense class
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', total: 10 }

    # 8. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 9. Add the expense class to the order line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].expenseClassId = globalElecExpenseClassId

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 10. Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }
