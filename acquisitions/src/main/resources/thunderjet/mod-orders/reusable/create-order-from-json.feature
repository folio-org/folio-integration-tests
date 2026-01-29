@ignore
Feature: Create order from JSON
  # parameters: order

  Background:
    * url baseUrl

  Scenario: Create order from JSON
    Given path 'orders/composite-orders'
    And request order
    When method POST
    Then status 201
