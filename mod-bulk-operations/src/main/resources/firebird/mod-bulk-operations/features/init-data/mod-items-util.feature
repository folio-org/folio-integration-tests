Feature: setup user data feature

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)' }

  @PostServicePoint
  Scenario: Create service point
    Given path 'service-points'
    And request servicePoint
    When method POST
    Then status 201

  @PostInstitution
  Scenario: POST institution
    Given path 'location-units/institutions'
    And request institution
    When method POST
    Then status 201

  @PostCampus
  Scenario: POST campus
    Given path 'location-units/campuses'
    And request campus
    When method POST
    Then status 201

  @PostLibrary
  Scenario: POST library
    Given path 'location-units/libraries'
    And request library
    When method POST
    Then status 201

  @PostLocation
  Scenario: POST location
    Given path 'locations'
    And request location
    When method POST
    Then status 201

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
