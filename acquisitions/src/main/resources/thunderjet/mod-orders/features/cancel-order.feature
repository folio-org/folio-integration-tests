Feature: Cancel order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

  @Positive
  Scenario: Cancel order
    # Generate unique UUIDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    * print '2. Create composite order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * print '3. Create order lines'
    * table statusTable
      | paymentStatus          | receiptStatus          | checkinItems |
      | 'Awaiting Payment'     | 'Partially Received'   | false        |
      | 'Payment Not Required' | 'Awaiting Receipt'     | false        |
      | 'Fully Paid'           | 'Receipt Not Required' | true         |
      | 'Partially Paid'       | 'Fully Received'       | false        |
    * def v = call createOrderLine statusTable

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '5. Cancel the order'
    * def v = call cancelOrder { orderId: '#(orderId)' }

    * print '6. Check the order lines after cancelling the order'
    * configure headers = headersAdmin
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 1000
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0

    * print '7. Check the budget after cancelling the order'
    * configure headers = headersUser
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def poLines = $.poLines
    * def line1 = poLines[0]
    * match line1.paymentStatus == 'Cancelled'
    * match line1.receiptStatus == 'Cancelled'
    * def line2 = poLines[1]
    * match line2.paymentStatus == 'Payment Not Required'
    * match line2.receiptStatus == 'Cancelled'
    * def line3 = poLines[2]
    * match line3.paymentStatus == 'Fully Paid'
    * match line3.receiptStatus == 'Receipt Not Required'
    * def line4 = poLines[3]
    * match line4.paymentStatus == 'Cancelled'
    * match line4.receiptStatus == 'Fully Received'