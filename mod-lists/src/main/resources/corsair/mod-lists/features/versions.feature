Feature: Scenarios that are primarily focused around the list versioning feature

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: A nonexistent list should not return 404
    * def listId = 'f41cbebc-3e53-510d-a1dd-e8c4b95e76f7' // i don't exist

    Given path 'lists', listId, 'versions'
    When method GET
    Then status 404
    And match $.code == "read-list.not.found"

    Given path 'lists', listId, 'versions', 1
    When method GET
    Then status 404
    And match $.code == "read-list.not.found"

  Scenario: A newly created list should return all the versions
    * def listRequest = read('samples/user-list-request.json')
    * call postList

    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And match response == '#present'
    And match response[0].version == 1
    And match response[0].id == '#present'
    And match response[0].listId == listId
    And match response[0].name == 'Integration User Test List'
    And match response[0].description == 'User list for FQM integration tests'
    And match response[0].fqlQuery == "{\"$and\": [{\"users.username\" : {\"$eq\": \"integration_test_user_123\"}}]}"
    And match response[0].isActive == true
    And match response[0].isPrivate == false
    And assert response.length == 1

  Scenario: Each list update should create one historic version
    # create original
    * def listRequest =
      """
        {
          "name": "Test List ORIGINAL",
          "description": "description ORIGINAL",
          "entityTypeId": "0069cf6f-2833-46db-8a51-8934769b8289",
          "fqlQuery": "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query ORIGINAL\"}}]}",
          "isActive": "true",
          "isPrivate": "false"
        }
      """
    * call postList {listRequest: '#(listRequest)'}
    # create edit 1
    * remove listRequest.entityTypeId
    * set listRequest.version = 1 // should match current server-side version. will be incremented by server.
    * set listRequest.name = 'Test List EDIT 1'
    * set listRequest.description = 'description EDIT 1'
    * set listRequest.fqlQuery = "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 1\"}}]}"
    * set listRequest.isActive = 'false'
    * set listRequest.isPrivate = 'true'
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    # get newly created version
    Given path 'lists', listId, 'versions', 1
    When method GET
    Then status 200
    And match response.version == 1
    And match response.listId == listId
    And match response.name == 'Test List ORIGINAL'
    And match response.description == 'description ORIGINAL'
    And match response.fqlQuery == "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query ORIGINAL\"}}]}"
    And match response.isActive == true
    And match response.isPrivate == false
    And match response.updatedBy == '00000000-1111-5555-9999-999999999992'
    And match response.updatedByUsername contains 'test-user'
    And def version1 = response

    # 1 edit => 1 version
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 2
    And match response[0] == version1

    # create edit 2
    * set listRequest.version = 2
    * set listRequest.name = 'Test List EDIT 2'
    * set listRequest.description = 'description EDIT 2'
    * set listRequest.fqlQuery = "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 2\"}}]}"
    * set listRequest.isActive = 'true'
    * set listRequest.isPrivate = 'false'
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    # get newly created version
    Given path 'lists', listId, 'versions', 2
    When method GET
    Then status 200
    And match response.version == 2
    And match response.listId == listId
    And match response.name == 'Test List EDIT 1'
    And match response.description == 'description EDIT 1'
    And match response.fqlQuery == "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 1\"}}]}"
    And match response.isActive == false
    And match response.isPrivate == true
    And match response.updatedBy == '00000000-1111-5555-9999-999999999992'
    And match response.updatedByUsername contains 'test-user'
    And def version2 = response

    # 2 edits => 1 version
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 3
    And match response[0] == version1
    And match response[1] == version2

    # we are now admin user
    * configure headers = testAdminHeaders

    # create edit 3 as admin
    * set listRequest.version = 3
    * set listRequest.name = 'Test List EDIT 3'
    * set listRequest.description = 'description EDIT 3'
    * set listRequest.fqlQuery = "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 3\"}}]}"
    * set listRequest.isActive = 'true'
    * set listRequest.isPrivate = 'false'
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    # get newly created version
    Given path 'lists', listId, 'versions', 3
    When method GET
    Then status 200
    And match response.version == 3
    And match response.listId == listId
    And match response.name == 'Test List EDIT 2'
    And match response.description == 'description EDIT 2'
    And match response.fqlQuery == "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 2\"}}]}"
    And match response.isActive == true
    And match response.isPrivate == false
    # actually created by test-user; current (not this one) is test-admin.
    And match response.updatedBy == '00000000-1111-5555-9999-999999999992'
    And match response.updatedByUsername contains 'test-user'
    And def version3 = response

    # 3 edits => 1 version
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 4
    And match response[0] == version1
    And match response[1] == version2
    And match response[2] == version3

    # create edit 4 as admin
    * set listRequest.version = 4
    * set listRequest.name = 'Test List EDIT 4'
    * set listRequest.description = 'description EDIT 4'
    * set listRequest.fqlQuery = "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 4\"}}]}"
    * set listRequest.isActive = 'true'
    * set listRequest.isPrivate = 'false'
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    # get newly created version
    Given path 'lists', listId, 'versions', 4
    When method GET
    Then status 200
    And match response.version == 4
    And match response.listId == listId
    And match response.name == 'Test List EDIT 3'
    And match response.description == 'description EDIT 3'
    And match response.fqlQuery == "{\"$and\": [{\"users.username\" : {\"$eq\": \"test query EDIT 3\"}}]}"
    And match response.isActive == true
    And match response.isPrivate == false
    And match response.updatedBy == '00000000-1111-5555-9999-999999999991'
    And match response.updatedByUsername contains 'test-admin'
    And def version4 = response

    # 3 edits => 1 version
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 5
    And match response[0] == version1
    And match response[1] == version2
    And match response[2] == version3
    And match response[3] == version4

  Scenario: Versions should have the same access control as the original list
    # create original as admin
    * configure headers = testAdminHeaders
    * def listRequest = read('samples/user-list-request.json')
    * call postList {listRequest: '#(listRequest)'}

    # initial version is not private, so user can access
    * configure headers = testUserHeaders
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 1

    # set private so only admin can access
    * configure headers = testAdminHeaders
    * remove listRequest.entityTypeId
    * set listRequest.version = 1 // should match current server-side version. will be incremented by server.
    * set listRequest.isPrivate = 'true'
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    # admin can still access
    * configure headers = testAdminHeaders
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 2

    # user cannot access
    * configure headers = testUserHeaders
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 401
    And match $.code == "read-list.is.private"

    * configure headers = testUserHeaders
    Given path 'lists', listId, 'versions', 1
    When method GET
    Then status 401
    And match $.code == "read-list.is.private"

  Scenario: Deleting a list will also delete its versions
    * def listRequest = read('samples/user-list-request.json')
    * call postList {listRequest: '#(listRequest)'}

    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 1
    # same list, but counts as an edit
    * remove listRequest.entityTypeId
    * set listRequest.version = 1
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    Given path 'lists', listId, 'versions'
    When method GET
    Then status 200
    And assert response.length == 2

    Given path 'lists', listId, 'versions', 1
    When method GET
    Then status 200

    # delete list
    Given path 'lists', listId
    When method DELETE
    Then status 204

    # no longer exists
    Given path 'lists', listId, 'versions'
    When method GET
    Then status 404
    And match $.code == "read-list.not.found"

    Given path 'lists', listId, 'versions', 1
    When method GET
    Then status 404
    And match $.code == "read-list.not.found"
