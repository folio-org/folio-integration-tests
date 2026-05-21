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
    * def createInstitutionResult = call read('classpath:volaris/mod-dcb/reusable/create-institution.feature') { name: 'ECS Shadow Institution Test', code: '#(shadowInstCode)', isShadow: true }
    And match createInstitutionResult.response.isShadow == true
    * def shadowInstitutionId = createInstitutionResult.response.id

    * def createCampusResult = call read('classpath:volaris/mod-dcb/reusable/create-campus.feature') { name: 'ECS Shadow Campus Test', code: '#(shadowCampCode)', institutionId: '#(shadowInstitutionId)', isShadow: true }
    And match createCampusResult.response.isShadow == true
    * def shadowCampusId = createCampusResult.response.id

    * def createLibraryResult = call read('classpath:volaris/mod-dcb/reusable/create-library.feature') { name: 'ECS Shadow Library Test', code: '#(shadowLibCode)', campusId: '#(shadowCampusId)', isShadow: true }
    And match createLibraryResult.response.isShadow == true
    * def shadowLibraryId = createLibraryResult.response.id

    * def createLocationResult = call read('classpath:volaris/mod-dcb/reusable/create-location.feature') { name: 'ECS Shadow Location Test', code: '#(shadowLocCode)', institutionId: '#(shadowInstitutionId)', campusId: '#(shadowCampusId)', libraryId: '#(shadowLibraryId)', servicePointId: '#(servicePointId)', isShadow: true }
    And match createLocationResult.response.isShadow == true
