# Created for MODORDERS-626
Feature: Unopen and change fund distribution

  Background:
    * url baseUrl
    * print karate.info.scenarioName

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def unopenOrder = read('classpath:thunderjet/mod-orders/reusable/unopen-order.feature')

  @Positive
  Scenario: Unopen and change fund distribution
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print '1. Create a fund and budget'
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active' }]}

    * print '2. Create a composite order'
    * def v = call createOrder { id: '#(orderId)',vendor: '#(globalVendorId)', orderType: 'One-Time' }

    * print '3. Create an order line'
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '5. Unopen the order'
    * def v = call unopenOrder { orderId: '#(orderId)' }

    * print '6. Change the expense class'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    * print '7. Open the order again'
    * def v = call openOrder { orderId: '#(orderId)' }
