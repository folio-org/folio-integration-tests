# Created for MODORDERS-1167
Feature: Open and unopen order

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
  Scenario: Open and unopen one-time order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print '1. Create a fund and budget'
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active' }] }

    * print '2. Create a composite one-time order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)',vendor: '#(globalVendorId)', orderType: 'One-Time' }

    * print '3. Create an order line'
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '5. Check order line status after opening'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == 'Awaiting Payment'
    And match response.receiptStatus == 'Awaiting Receipt'

    * print '6. Unopen the order'
    * def v = call unopenOrder { orderId: '#(orderId)' }

    * print '7. Check order line status after unopening'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == 'Pending'
    And match response.receiptStatus == 'Pending'

  @Positive
  Scenario: Open and unopen ongoing order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print '1. Create a fund and budget'
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 1000, 'statusExpenseClasses': [{'expenseClassId': '#(globalPrnExpenseClassId)','status': 'Active' }]}

    * print '2. Create a composite ongoing order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)',vendor: '#(globalVendorId)', orderType: 'Ongoing', "ongoing": {"interval" : 123, "isSubscription" : true, "renewalDate" : "2022-05-08T00:00:00.000+00:00"}}

    * print '3. Create an order line'
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '5. Check order line status after opening'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == 'Ongoing'
    And match response.receiptStatus == 'Ongoing'

    * print '6. Unopen the order'
    * def v = call unopenOrder { orderId: '#(orderId)' }

    * print '7. Check order line status after unopening'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == 'Pending'
    And match response.receiptStatus == 'Pending'


