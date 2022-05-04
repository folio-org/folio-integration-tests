@parallel=false
Feature: Cancel order

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

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }


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


  Scenario Outline: Create a po line with paymentStatus=<paymentStatus> and receiptStatus=<receiptStatus>
    * copy poLine = orderLineTemplate
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = '<paymentStatus>'
    * set poLine.receiptStatus = '<receiptStatus>'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    Examples:
      | paymentStatus        | receiptStatus        |
      | Awaiting Payment     | Partially Received   |
      | Payment Not Required | Awaiting Receipt     |
      | Fully Paid           | Receipt Not Required |
      | Partially Paid       | Fully Received       |


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


  Scenario: Cancel the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Closed'
    * set order.closeReason = { reason: 'Cancelled' }

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


  Scenario: Check the po lines after cancelling the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def poLines = $.compositePoLines
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


  Scenario: check the budget after cancelling the order
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
