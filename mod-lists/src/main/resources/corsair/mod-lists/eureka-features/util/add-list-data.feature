Feature: Add FQM query data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Add sample data needed for FQM queries
    # Add users
    * def userRequest = read('classpath:corsair/mod-lists/features/samples/user-request.json')
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * userRequest.username = 'integration_test_user_456'
    * userRequest.id = '00000000-1111-2222-9999-44444444442'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    * userRequest.username = 'integration_test_other_user'
    * userRequest.id = '00000000-1111-2222-9999-44444444443'
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201

    # This is a workaround due to the first refresh hanging when integration tests are run. Currently investigating why
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list-request.json')
    * def dummyPostCall = callonce postList
    * def dummyListId = dummyPostCall.listId
    * callonce refreshList {listId: '#(dummyListId)'}