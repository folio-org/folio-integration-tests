@parallel=false
Feature: ECS | Shadow locations created via /refresh and /locations are not displayed

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
    * def shadowAgencyCode = 'ECS-SHADOW-AGT'


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


  @C1003527
  Scenario: GET /locations with includeShadowLocations=true returns shadow locations with isShadow true
    Given path '/locations'
    And param query = 'code=="ecs-shadow-loc-test"'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.locations[0].isShadow == true

    Given path '/locations'
    And param query = 'code=="ECS-SHADOW-AGT"'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.locations[0].isShadow == true


  @C1003527
  Scenario: GET /locations without includeShadowLocations param excludes shadow locations
    Given path '/locations'
    And param query = 'code=="ecs-shadow-loc-test"'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path '/locations'
    And param query = 'code=="ECS-SHADOW-AGT"'
    When method GET
    Then status 200
    And match response.totalRecords == 0


  @C1003527
  Scenario: GET /location-units endpoints exclude shadow records by default
    Given path '/location-units/institutions'
    And param query = 'code=="ecs-shadow-inst-test"'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path '/location-units/institutions'
    And param query = 'code=="ecs-shadow-inst-test"'
    And param includeShadow = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.locinsts[0].isShadow == true

    Given path '/location-units/campuses'
    And param query = 'code=="ecs-shadow-camp-test"'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path '/location-units/campuses'
    And param query = 'code=="ecs-shadow-camp-test"'
    And param includeShadow = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.loccamps[0].isShadow == true

    Given path '/location-units/libraries'
    And param query = 'code=="ecs-shadow-lib-test"'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path '/location-units/libraries'
    And param query = 'code=="ecs-shadow-lib-test"'
    And param includeShadow = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.loclibs[0].isShadow == true
