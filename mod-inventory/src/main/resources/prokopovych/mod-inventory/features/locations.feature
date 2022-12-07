Feature: inventory

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def samplesPath = 'classpath:prokopovych/mod-inventory/samples/'

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

