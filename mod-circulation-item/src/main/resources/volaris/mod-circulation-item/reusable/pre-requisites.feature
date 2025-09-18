Feature: Circulation Item - create prerequisite data

  Background:
    * url baseUrl
    * def user = testUser
    * callonce login user
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser


  @CreateDummyLocation
  Scenario: Create a dummy Location
    * def randomStr = call random_string
    * def locationName = 'DUMMY_KARATE_LOC_NAME' + randomStr
    * def locationCode = 'DUMMY_KARATE_LOC_CODE' + randomStr
    * def institutionId = '9d1b77e5-f02e-4b7f-b296-3f2042ddac54'
    * def campusId = '9d1b77e6-f02e-4b7f-b296-3f2042ddac54'
    * def libraryId = '9d1b77e7-f02e-4b7f-b296-3f2042ddac54'
    * def servicePointId = '9d1b77e8-f02e-4b7f-b296-3f2042ddac54'
    * def locationRequest = read('classpath:volaris/mod-circulation-item/features/samples/create-location.json')

    Given path '/locations'
    And request locationRequest
    When method POST
    Then status 201