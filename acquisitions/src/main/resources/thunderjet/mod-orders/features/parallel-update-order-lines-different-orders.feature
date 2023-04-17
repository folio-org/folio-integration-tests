# For https://issues.folio.org/browse/MODFISTO-304
# This should be executed with at least 5 threads
Feature: Update order lines for different open orders in parallel (using the same fund), and check budget

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def orderId3 = callonce uuid5
    * def orderId4 = callonce uuid6
    * def poLineId1 = callonce uuid7
    * def poLineId2 = callonce uuid8
    * def poLineId3 = callonce uuid9
    * def poLineId4 = callonce uuid10

    * def createOrder = read('../reusable/create-order.feature')
    * def createOrderLine = read('../reusable/create-order-line.feature')
    * def openOrder = read('../reusable/open-order.feature')
    * def getOrderLine = read('../reusable/get-order-line.feature')

    * configure headers = headersAdmin
    * callonce createFund { id: '#(fundId)' }
    * callonce createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)' }
    * configure headers = headersUser

    * callonce createOrder { id: '#(orderId1)' }
    * callonce createOrder { id: '#(orderId2)' }
    * callonce createOrder { id: '#(orderId3)' }
    * callonce createOrder { id: '#(orderId4)' }

    * callonce createOrderLine { id: '#(poLineId1)', orderId: '#(orderId1)', fundId: '#(fundId)' }
    * callonce createOrderLine { id: '#(poLineId2)', orderId: '#(orderId2)', fundId: '#(fundId)' }
    * callonce createOrderLine { id: '#(poLineId3)', orderId: '#(orderId3)', fundId: '#(fundId)' }
    * callonce createOrderLine { id: '#(poLineId4)', orderId: '#(orderId4)', fundId: '#(fundId)' }

    * callonce openOrder { orderId: '#(orderId1)' }
    * callonce openOrder { orderId: '#(orderId2)' }
    * callonce openOrder { orderId: '#(orderId3)' }
    * callonce openOrder { orderId: '#(orderId4)' }

    * callonce getOrderLine { poLineId: '#(poLineId1)' }
    * set poLine.cost.listUnitPrice = 11
    * def poLine1 = poLine
    * callonce getOrderLine { poLineId: '#(poLineId2)' }
    * set poLine.cost.listUnitPrice = 12
    * def poLine2 = poLine
    * callonce getOrderLine { poLineId: '#(poLineId3)' }
    * set poLine.cost.listUnitPrice = 13
    * def poLine3 = poLine
    * callonce getOrderLine { poLineId: '#(poLineId4)' }
    * set poLine.cost.listUnitPrice = 14
    * def poLine4 = poLine


  Scenario: Update line 1
    * print "Update line 1 start"
    Given path 'orders/order-lines', poLine1.id
    And request poLine1
    When method PUT
    Then status 204
    * print "Update line 1 end"

  Scenario: Update line 2
    * print "Update line 2 start"
    Given path 'orders/order-lines', poLine2.id
    And request poLine2
    When method PUT
    Then status 204
    * print "Update line 2 end"

  Scenario: Update line 3
    * print "Update line 3 start"
    Given path 'orders/order-lines', poLine3.id
    And request poLine3
    When method PUT
    Then status 204
    * print "Update line 3 end"

  Scenario: Update line 4
    * print "Update line 4 start"
    Given path 'orders/order-lines', poLine4.id
    And request poLine4
    When method PUT
    Then status 204
    * print "Update line 4 end"

  Scenario: Check budget
    # Note: karate.afterFeature() does not report error count, so it's unusable.
    # Also in latest karate, if we call another feature with scenarios, they are not executed in parallel.
    # So we have to wait for the updates in a parallel thread before checking the budget.
    * call pause 2000

    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 950
    And match budget.expenditures == 0
    And match budget.encumbered == 50
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 50

