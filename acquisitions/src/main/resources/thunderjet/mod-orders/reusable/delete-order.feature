Feature: Delete order
  # parameters: orderId

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Delete order
    Given path '/orders/composite-orders', orderId
    When method DELETE
    Then status 204
