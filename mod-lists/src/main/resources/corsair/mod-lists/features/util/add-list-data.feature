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

    # Add instance type
    * def instanceTypeId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804f'
    * def instanceTypeRequest = {id: '#(instanceTypeId)', 'name': 'still image', "code": 'sti', "source": 'rdacarrier'}
    Given path '/instance-types'
    And request instanceTypeRequest
    When method POST
    Then status 201

    # Add instance
    * def instanceId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804e'
    * def instanceRequest = {id: '#(instanceId)', title: 'Some title', source: 'Local', instanceTypeId: '#(instanceTypeId)', languages: ['eng', 'fre']}
    Given path '/instance-storage/instances'
    And request instanceRequest
    When method POST
    Then status 201

    # Wait until last instance is indexed
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200


    # This is a workaround due to the first refresh hanging when integration tests are run. Currently investigating why
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def dummyPostCall = callonce postList
    * def dummyListId = dummyPostCall.listId
    * callonce refreshList {listId: '#(dummyListId)'}