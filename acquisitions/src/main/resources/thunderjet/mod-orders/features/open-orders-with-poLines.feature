# For https://folio-org.atlassian.net/browse/MODORDERS-1226
Feature: Open Orders with PoLines

  Background:
    * url baseUrl
    * print karate.info.scenarioName

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    # Define reusable functions
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

  @Positive
  Scenario: Open Orders with PoLines
   # Generate unique UUIDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    * print '2. Create composite order'
    * def v = call createOrder { id: '#(orderId)' }

    * print '3. Create order lines'
    * table statusTable
      | paymentStatus          | receiptStatus          |
      | 'Awaiting Payment'     | 'Awaiting Receipt'     |
    * def v = call createOrderLine statusTable

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

  @Negative
  Scenario: Open Orders with PoLines - Throw Exception
    # Generate unique UUIDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    * print '2. Create composite order'
    * def v = call createOrder { id: '#(orderId)' }

    * print '3. Open the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove order.compositePoLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 422

    And match each $.errors[*].code == 'compositeOrderMissingPoLines'
    And match each $.errors[*].message == 'Composite order is missing poLines for Open operations'
    And match $.errors[*].paremeters == []
    And match $.total_records == 1

