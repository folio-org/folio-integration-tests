@ignore
Feature: Open order
  # parameters: orderId

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'
    * remove orderResponse.poLines

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204
