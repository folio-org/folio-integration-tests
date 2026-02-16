Feature: Scenarios that are primarily focused around refreshing lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Post list refresh should fail if list is already refreshing
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 400

    Given path 'lists', listId, 'refresh'
    When method DELETE
    Then status 204

  Scenario: Post list refresh should fail for inactive list
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/private-list-request.json')
    * listRequest.isActive = 'false'
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 400

  Scenario: Cancel a refresh
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.inProgressRefresh == '#present'

    Given path 'lists', listId, 'refresh'
    When method DELETE
    Then status 204

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.inProgressRefresh == '#notpresent'

  Scenario: Add record, refresh list, see that refresh count has increased. Remove record and see that count decreased again
    * def userRequest = read('classpath:corsair/mod-lists/features/samples/user-request.json')
    * userRequest.id = '00000000-1111-2222-9999-44444444444'
    * userRequest.username = 'integration_test_user_789'
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * listRequest.fqlQuery = '{\"$and\": [{\"users.username\" : {\"$regex\": \"integration_test_user\"}}]}'
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 201
    * def listId = $.id

    # Refresh list
    * call refreshList {listId: '#(listId)'}

    # get list contents, note number of items
    * def query = {offset: 0, size: 100 }
    Given path 'lists', listId, 'contents'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == '#present'
    * def totalRecords = $.totalRecords

    # Add a new user
    Given path 'users'
    And request userRequest
    When method POST
    Then status 201
    * def userId = $.id

    # Refresh list
    * call refreshList {listId: '#(listId)'}

    # Check that list has one extra item
    * def query = {offset: 0, size: 100 }
    Given path 'lists', listId, 'contents'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == totalRecords + 1

    # Delete user
    Given path 'users', userId
    When method DELETE
    Then status 204

    # Refresh list
    * call refreshList {listId: '#(listId)'}

    # Check that list has one less item (back to normal)
    Given path 'lists', listId, 'contents'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == totalRecords
