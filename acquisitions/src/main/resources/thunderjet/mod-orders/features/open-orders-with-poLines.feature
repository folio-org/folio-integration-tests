# For MODORDERS-1226
Feature: Open Orders with PoLines

  Background:
    * url baseUrl
    * print karate.info.scenarioName
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid

    * configure headers = headersAdmin
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

  @Positive
  Scenario: Open Orders with PoLines
    * def orderId = call uuid

    * print '1. Create composite order'
    * def v = call createOrder { id: '#(orderId)' }

    * print '2. Create order lines'
    * table statusTable
      | paymentStatus      | receiptStatus      |
      | 'Awaiting Payment' | 'Awaiting Receipt' |
    * def v = call createOrderLine statusTable

    * print '3. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

  @Negative
  Scenario: Open Orders with PoLines - Throw Exception
    * def orderId = call uuid

    * print '1. Create composite order'
    * def v = call createOrder { id: '#(orderId)' }

    * print '2. Open the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove order.poLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 422

    And match each $.errors[*].code == 'compositeOrderMissingPoLines'
    And match each $.errors[*].message == 'Composite order is missing poLines for Open operations'
    And match $.errors[*].paremeters == []
    And match $.total_records == 1

