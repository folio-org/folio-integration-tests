Feature: inventory

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant': '#(testUser.tenant)', 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def samplesPath = 'classpath:folijet/mod-inventory/samples/'

  Scenario: create service point
    Given path 'service-points'
    And request read(samplesPath + 'service-points-online.json')
    When method POST
    Then status 201

  Scenario: create institution
    Given path 'location-units/institutions'
    And request read(samplesPath + 'institutions-ku.json')
    When method POST
    Then status 201

  Scenario: create campus
    Given path 'location-units/campuses'
    And request read(samplesPath + 'campuses-online.json')
    When method POST
    Then status 201

  Scenario: create library
    Given path 'location-units/libraries'
    And request read(samplesPath + 'libraries-online.json')
    When method POST
    Then status 201

  Scenario: create locations
    Given path 'locations'
    And request read(samplesPath + 'locations-onlinecampus.json')
    When method POST
    Then status 201

  Scenario: create and fetch shadow location and location-units
    Given path 'location-units/institutions'
    And request read(samplesPath + 'shadow-institution.json')
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request read(samplesPath + 'shadow-campus.json')
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request read(samplesPath + 'shadow-library.json')
    When method POST
    Then status 201

    Given path 'locations'
    And request read(samplesPath + 'shadow-location.json')
    When method POST
    Then status 201

    Given path 'locations'
    When method GET
    Then status 200
    And match response.totalRecords == 1

    Given path 'locations'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.locations.code == ['E', 'shadow-loc']
