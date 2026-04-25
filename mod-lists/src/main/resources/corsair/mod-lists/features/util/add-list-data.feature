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

    # Add statistical code types and values used by instance queries
    * def booksStatisticalCodeTypeId = '3abd6fc2-b3e4-4879-b1e1-78be41769fe3'
    * def booksStatisticalCodeId = 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    * def ptfStatisticalCodeTypeId = '721d77a6-b554-4f8f-900d-000000c0ffee'
    * def ptfStatisticalCodeId = '8d1f5e72-e0a4-42b1-9de9-2d9452ecc46d'
    * def booksStatisticalCodeTypeRequest = { id: '#(booksStatisticalCodeTypeId)', name: 'ARL (Collection stats)', source: 'folio' }
    * def ptfStatisticalCodeTypeRequest = { id: '#(ptfStatisticalCodeTypeId)', name: 'PTF', source: 'folio' }
    Given path '/statistical-code-types'
    And request booksStatisticalCodeTypeRequest
    When method POST
    Then status 201
    Given path '/statistical-code-types'
    And request ptfStatisticalCodeTypeRequest
    When method POST
    Then status 201
    * def booksStatisticalCodeRequest = { id: '#(booksStatisticalCodeId)', code: 'books', name: 'Book, print (books)', statisticalCodeTypeId: '#(booksStatisticalCodeTypeId)', source: 'UC' }
    * def ptfStatisticalCodeRequest = { id: '#(ptfStatisticalCodeId)', code: 'PTF5', name: 'PTF5', statisticalCodeTypeId: '#(ptfStatisticalCodeTypeId)', source: 'UC' }
    Given path '/statistical-codes'
    And request booksStatisticalCodeRequest
    When method POST
    Then status 201
    Given path '/statistical-codes'
    And request ptfStatisticalCodeRequest
    When method POST
    Then status 201

    # Add instances with different statistical codes so NOT IN list queries can return deterministic results
    * def instanceId = 'c8a1b47a-51f3-493b-9f9e-aaeb38ad804e'
    * def secondInstanceId = 'b7d8dd77-c3f3-4af0-b6f1-f77f7f3a1f01'
    * def instanceRequest = {id: '#(instanceId)', title: 'Some title', source: 'Local', instanceTypeId: '#(instanceTypeId)', languages: ['eng', 'fre'], statisticalCodeIds: ['#(booksStatisticalCodeId)']}
    Given path '/instance-storage/instances'
    And request instanceRequest
    When method POST
    Then status 201
    * def secondInstanceRequest = {id: '#(secondInstanceId)', title: 'Second statistical code instance', source: 'Local', instanceTypeId: '#(instanceTypeId)', languages: ['eng'], statisticalCodeIds: ['#(ptfStatisticalCodeId)']}
    Given path '/instance-storage/instances'
    And request secondInstanceRequest
    When method POST
    Then status 201

    # Wait until both instances are indexed
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords == 2
    When method GET
    Then status 200


    # This is a workaround due to the first refresh hanging when integration tests are run. Currently investigating why
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def dummyPostCall = callonce postList
    * def dummyListId = dummyPostCall.listId
    * callonce refreshList {listId: '#(dummyListId)'}
