@parallel=false
Feature: ECS | Shadow locations created via API are not displayed across applications

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


  @C1003527
  Scenario: Shadow locations are not returned by default across location endpoints
    # GET /locations without includeShadowLocations excludes shadow locations
    Given path '/locations'
    And param query = 'code=="ecs-shadow-loc-test"'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # GET /locations with includeShadowLocations=true returns shadow locations
    Given path '/locations'
    And param query = 'code=="ecs-shadow-loc-test"'
    And param includeShadowLocations = true
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.locations[0].isShadow == true

    # GET /search/consortium/locations excludes shadow locations
    Given path '/search/consortium/locations'
    And param limit = 10000
    When method GET
    Then status 200
    And match response.locations[*].name !contains 'ECS Shadow Location Test'
    And match response.locations[*].name !contains 'ECS-SHADOW-AGT'

    # GET /search/consortium/campuses excludes shadow campuses
    Given path '/search/consortium/campuses'
    And param limit = 1000
    When method GET
    Then status 200
    And match response.campuses[*].name !contains 'ECS Shadow Campus Test'
    And match response.campuses[*].name !contains 'ECS-SHADOW-AGT'

    # GET /search/consortium/libraries excludes shadow libraries
    Given path '/search/consortium/libraries'
    And param limit = 1000
    When method GET
    Then status 200
    And match response.libraries[*].name !contains 'ECS Shadow Library Test'
    And match response.libraries[*].name !contains 'ECS-SHADOW-AGT'

    # GET /search/consortium/institutions excludes shadow institutions
    Given path '/search/consortium/institutions'
    And param limit = 1000
    When method GET
    Then status 200
    And match response.institutions[*].name !contains 'ECS Shadow Institution Test'
    And match response.institutions[*].name !contains 'ECS-SHADOW-AGT'

    # GET /location-units/institutions excludes shadow by default, includes with param
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
