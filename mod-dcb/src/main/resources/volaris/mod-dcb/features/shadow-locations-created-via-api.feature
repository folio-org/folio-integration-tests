@parallel=false
Feature: ECS | Shadow locations created via API

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }
    * configure headers = headersAdmin
    * callonce variables

    * def shadowInstCode = 'ecs-shadow-inst-test'
    * def shadowCampCode = 'ecs-shadow-camp-test'
    * def shadowLibCode = 'ecs-shadow-lib-test'
    * def shadowLocCode = 'ecs-shadow-loc-test'


  @C1003528
  Scenario: Create shadow location institution, campus, library, and location via API with isShadow true
    Given path '/location-units/institutions'
    And request { name: 'ECS Shadow Institution Test', code: '#(shadowInstCode)', isShadow: true }
    When method POST
    Then status 201
    And match response.isShadow == true
    * def shadowInstitutionId = response.id

    Given path '/location-units/campuses'
    And request { name: 'ECS Shadow Campus Test', code: '#(shadowCampCode)', institutionId: '#(shadowInstitutionId)', isShadow: true }
    When method POST
    Then status 201
    And match response.isShadow == true
    * def shadowCampusId = response.id

    Given path '/location-units/libraries'
    And request { name: 'ECS Shadow Library Test', code: '#(shadowLibCode)', campusId: '#(shadowCampusId)', isShadow: true }
    When method POST
    Then status 201
    And match response.isShadow == true
    * def shadowLibraryId = response.id

    Given path '/locations'
    And request
      """
      {
        "isActive": true,
        "institutionId": "#(shadowInstitutionId)",
        "campusId": "#(shadowCampusId)",
        "libraryId": "#(shadowLibraryId)",
        "servicePointIds": ["#(servicePointId)"],
        "name": "ECS Shadow Location Test",
        "code": "#(shadowLocCode)",
        "discoveryDisplayName": "ECS Shadow Location Test",
        "details": {},
        "primaryServicePoint": "#(servicePointId)",
        "isShadow": true
      }
      """
    When method POST
    Then status 201
    And match response.isShadow == true
