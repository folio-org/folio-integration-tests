@parallel=false
Feature: ECS | Refresh DCB shadow locations

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }
    * configure headers = headersAdmin
    * callonce variables

    * def shadowAgencyCode = 'ECS-SHADOW-AGT'


  @C958452
  Scenario: Create shadow location via /refresh endpoint (agency-based)
    Given path '/dcb/shadow-locations/refresh'
    And request { agencies: [ { name: 'ECS Shadow Agency Test', code: '#(shadowAgencyCode)' } ] }
    When method POST
    Then status 201
    And match $.locations[*].code contains only ['#(shadowAgencyCode)']
    And match $.locations[*].status contains only ['SUCCESS']
    And match $['location-units'].institutions[*].code contains only ['#(shadowAgencyCode)']
    And match $['location-units'].institutions[*].status contains only ['SUCCESS']
    And match $['location-units'].campuses[*].code contains only ['#(shadowAgencyCode)']
    And match $['location-units'].campuses[*].status contains only ['SUCCESS']
    And match $['location-units'].libraries[*].code contains only ['#(shadowAgencyCode)']
    And match $['location-units'].libraries[*].status contains only ['SUCCESS']

    Given path '/locations'
    And param query = 'code=="ECS-SHADOW-AGT"'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.locations[0].isShadow == true
