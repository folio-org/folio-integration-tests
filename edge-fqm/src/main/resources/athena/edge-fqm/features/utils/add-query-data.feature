Feature: Add FQM query data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Add sample data needed for FQM queries
    # Add institution
    * def institutionId = call uuid1
    * def institutionRequest = {id: '#(institutionId)', name: 'Main Institution', code: 'MI'}
    Given path '/location-units/institutions'
    And request institutionRequest
    When method POST
    Then status 201

    # Add campus
    * def campusId = call uuid1
    * def campusRequest = {id: '#(campusId)', institutionId: '#(institutionId)', name: 'Main Campus', code: 'MC'}
    Given path '/location-units/campuses'
    And request campusRequest
    When method POST
    Then status 201

    # Add library
    * def libraryId = call uuid1
    * def libraryRequest = {id: '#(libraryId)', campusId: '#(campusId)', name: 'Main Campus', code: 'MC'}
    Given path '/location-units/libraries'
    And request libraryRequest
    When method POST
    Then status 201

    # Add location
    * def servicePointId = call uuid1
    * def permanentLocationId = call uuid1
    * def locationRequest = {id:  '#(permanentLocationId)', name: 'Location 1', code: 'loc1', primaryServicePoint: '#(servicePointId)', libraryId:  '#(libraryId)', campusId:  '#(campusId)', institutionId: '#(institutionId)', servicePointIds:  ['#(servicePointId)']}
    Given path '/locations'
    And request locationRequest
    When method POST
    Then status 201