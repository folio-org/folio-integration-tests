Feature: add locations

  Background:
    * url baseUrl
    #* configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)' }


  Scenario: create service point
    Given path 'service-points'
    And request read(samplesPath + 'location-mapping/service-points-mainLibrary.json')
    When method POST
    Then status 201

  Scenario: create institution
    Given path 'location-units/institutions'
    And request read(samplesPath + 'location-mapping/institutions-ku.json')
    When method POST
    Then status 201

  Scenario: create campus
    Given path 'location-units/campuses'
    And request read(samplesPath + 'location-mapping/campuses-mainLibrary.json')
    When method POST
    Then status 201

  Scenario: create library
    Given path 'location-units/libraries'
    And request read(samplesPath + 'location-mapping/libraries-mainLibrary.json')
    When method POST
    Then status 201

  Scenario: create locations
    Given path 'locations'
    And request read(samplesPath + 'location-mapping/locations-mainLibrary.json')
    When method POST
    Then status 201