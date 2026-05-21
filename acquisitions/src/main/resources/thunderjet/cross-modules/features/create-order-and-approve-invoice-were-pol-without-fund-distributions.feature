Feature: Create order and approve invoice were pol without fund distributions

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Create order and approve invoice were pol without fund distributions
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineIdWithTwoFD = call uuid
    * def invoiceId = call uuid
    * def invoiceLineIdWithTwoFD = call uuid

    # 1. Prepare finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

    # 2. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create order line without fund distribution
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = orderLineIdWithTwoFD
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = 100.03
    * set orderLine.cost.exchangeRate = 1.03
    * remove orderLine.fundDistribution

    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    # 4. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Check budget after open order
    * def expectedEncumbered = 0.0

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 10000 - expectedEncumbered
    And match budget.expenditures == 0
    And match budget.encumbered == expectedEncumbered
    And match budget.awaitingPayment == 0
    And match budget.unavailable == expectedEncumbered

    # 6. Check encumbrances
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and fromFundId==' + fundId + ' and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 7. Create invoice
    * def v = call createInvoice { id: '#(invoiceId)', exchangeRate: 1.03 }

    # 8. Get order line with fund distribution
    Given path 'orders/order-lines', orderLineIdWithTwoFD
    When method GET
    Then status 200

    * def lineAmount = response.cost.listUnitPrice

    # 9. Create invoice line
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineIdWithTwoFD)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', total: '#(lineAmount)' }

    # 10. Approve invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 11. check budget after approving invoice
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].awaitingPayment == 100.03

    # 12. Check pending payments
    Given path 'finance/transactions'
    And param query = 'transactionType==Pending payment and fromFundId==' + fundId + ' and sourceInvoiceId=='+ invoiceId
    When method GET
    Then status 200
    And match $.transactions[0].amount == 100.03

    # 13. Pay invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # 14. Check payment amount
    Given path 'finance/transactions'
    And param query = 'transactionType==Payment and fromFundId==' + fundId + ' and sourceInvoiceId=='+ invoiceId
    When method GET
    Then status 200
    And match $.transactions[0].amount == 100.03

    # 15. Check budget expenditures
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200
    And match $.budgets[0].expenditures == 100.03
