@ignore
Feature: Get order line
  # parameters: poLineId
  # returns: poLine

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Get order line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
