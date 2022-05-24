Feature: setup user data feature

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)' }

  @PostInstance
  Scenario: POST inventory
    Given path 'inventory'
    Given path 'instances'
    And request instance
    When method POST
    Then status 201

  @PostHoldings
  Scenario: POST holdings
    Given path 'holdings-storage'
    Given path 'holdings'
    And request holdings
    When method POST
    Then status 201

  @PostItems
  Scenario: POST Items
    Given path 'inventory'
    Given path 'items'
    And request item
    When method POST
    Then status 201