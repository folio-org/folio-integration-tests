Feature: List App list tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def itemListId = '605a345f-f456-4ab2-8968-22f49cf1fbb6'
    * def loanListId = '97f5829f-1510-47bc-8454-ae7fa849baef'

  Scenario: Get all lists for a tenant (ids not provided)
    Given path 'lists'
    When method GET
    Then status 200
    And match $.content == '#present'
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords >= 2

  Scenario: Get all lists for tenant (empty ids)
    * def parameters = {ids: [''] }
    Given path 'lists'
    And params parameters
    When method GET
    Then status 200
    And match $.content == '#present'
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords >= 2


  Scenario: Get all lists for tenant with updatedAsOf query parameter
    * def updatedTime = {updatedAsOf: "2022-09-27T20:47:51.886+00:00"}
    Given path 'lists'
    And params updatedTime
    When method GET
    Then status 200
    And match $.content == '#present'
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords >= 2

  Scenario: Post and get new list
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists/' + listId
    When method GET
    Then status 200
    And match $.name == listRequest.name
    And match $.userFriendlyQuery == '(username == integration_test_user_123)'

  Scenario: Get all lists for tenant with private query parameter
    * def listRequest = read('samples/private-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
    * def parameters = {private: true}
    Given path 'lists'
    And params parameters
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.content[0].isPrivate == true

  Scenario: Get all lists for tenant with active query parameter
#    * configure afterScenario = () => karate.call('delete-list.feature', {listId: listId})
    * def listRequest = read('samples/private-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
    * def parameters = {active: true}
    Given path 'lists'
    And params parameters
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.content[0].isActive == true

  Scenario: Get lists for multiple ids
    * def loanListName = 'Inactive patrons with open loans'
    * def itemListName = 'Missing items'
    * def query = { ids: ['#(itemListId)', '#(loanListId)'] }
    Given path 'lists'
    And params query
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.totalRecords == 2
    * assert (response.content[0].name == itemListName || response.content[0].name == loanListName)
    * assert (response.content[1].name == itemListName || response.content[1].name == loanListName)

  Scenario: Get lists for invalid ids array should return '400 Bad Request'
    * def invalidId = call uuid1
    * def query = { ids: 100 }
    Given path 'lists'
    And params query
    When method GET
    Then status 400

  Scenario: Get lists for non-existent list id array should return no list summaries
    * def invalidId = call uuid1
    * def query = { ids: '#(invalidId)'}
    Given path 'lists'
    And params query
    When method GET
    Then status 200
    And match $.content == '#notpresent'

  Scenario: Get single list
    Given path 'lists/' + itemListId
    When method GET
    Then status 200
    And match $.name == 'Missing items'

  Scenario: Get list for id that is not present
    * def invalidId = call uuid1
    Given path 'lists/' + invalidId
    When method GET
    Then status 404

  Scenario: Get contents of a list, ensure different results for different offsets
    * def listRequest = read('samples/user-list-request.json')
    * listRequest.fqlQuery = '{\"$and\": [{\"username\" : {\"$regex\": \"^integration_test_user\"}}]}'
    * def postCall = call postList
    * def listId = postCall.listId

    * call refreshList { listId : '#(listId)'}

    * def query = { offset: 0, size: 2 }
    Given path 'lists/' + listId + '/contents'
    And params query
    When method GET
    Then status 200
    And match $.content == '#present'
    And match $.content.length() == 2
    And match $.content[0] == '#present'
    And match $.content[1] == '#present'
    And match $.totalRecords == '#present'
    * def firstItem = $.content[0]
    * def lastItem = $.content[1]

    * def query = { offset: 1, size: 2 }
    Given path 'lists/' + listId + '/contents'
    And params query
    When method GET
    Then status 200
    And match $.content[0] == lastItem
    And match $.content[1] == '#notpresent'

  Scenario: Get contents of a list with size 0 should return '400 Bad Request'
    * call refreshList {listId: '#(itemListId)'}
    * def query = { offset: 0, size: 0 }
    Given path 'lists/' + itemListId + '/contents'
    And params query
    When method GET
    Then status 400

  Scenario: Get contents of a list with negative offset should return '400 Bad Request'
    * call refreshList {listId: '#(itemListId)'}
    * def query = { offset: -1, size: 0 }
    Given path 'lists/' + itemListId + '/contents'
    And params query
    When method GET
    Then status 400

  Scenario: Get contents of a list that is not present should return '404 Not Found'
    * def invalidId = call uuid1
    * def query = { offset: 0, size: 100 }
    Given path 'lists/' + invalidId + '/contents'
    And params query
    When method GET
    Then status 404

  Scenario: Posting list request missing required arguments should return '400 Bad Request'
    * def listRequest = read('samples/invalid-list-request.json')
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 400

  Scenario: Add record, refresh list, see that refresh count has increased. Remove record and see that count decreased again
    * def userRequest = read('samples/user-request.json')
    * userRequest.id = '00000000-1111-2222-9999-44444444444'
    * userRequest.username = 'integration_test_user_789'
    * def listRequest = read('samples/user-list-request.json')
    * listRequest.fqlQuery = '{\"$and\": [{\"username\" : {\"$regex\": \"integration_test_user\"}}]}'
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 201
    * def listId = $.id

    # Refresh list
    * call refreshList {listId: '#(listId)'}

    # get list contents, note number of items
    * def query = {offset: 0, size: 100 }
    Given path 'lists/' + listId + '/contents'
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
    Given path 'lists/' + listId + '/contents'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == totalRecords + 1

    # Delete user
    Given path 'users/' + userId
    When method DELETE
    Then status 204

    # Refresh list
    * call refreshList {listId: '#(listId)'}

    # Check that list has one less item (back to normal)
    Given path 'lists/' + listId + '/contents'
    And params query
    When method GET
    Then status 200
    And match $.totalRecords == totalRecords

  Scenario: Update list with a PUT request and confirm that it is updated
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists/' + listId
    When method GET
    Then status 200
    And match $.name == listRequest.name
    * def version = 1

    Given path 'lists/' + listId
    And request {name: 'Updated Integration Test List', isActive:  'true', isPrivate: 'false', version: 1, fqlQuery: "{\"username\": {\"$eq\": \"user1\"}}"}
    When method PUT
    Then status 200
    And match $.userFriendlyQuery == '#present'

    Given path 'lists/' + listId
    When method GET
    Then status 200
    And match $.name == 'Updated Integration Test List'
    And match $.version ==  version + 1

  Scenario: Post list refresh should fail if list is already refreshing
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists/' + listId + '/refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists/' + listId + '/refresh'
    When method POST
    Then status 400

    Given path 'lists/' + listId + '/refresh'
    When method DELETE
    Then status 204

  Scenario: Post list refresh should fail for inactive list
    * def listRequest = read('samples/private-list-request.json')
    * listRequest.isActive = 'false'
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists/' + listId + '/refresh'
    When method POST
    Then status 400

  Scenario: Delete request should return 404 for id that does not exist
    * def invalidId = call uuid1
    Given path 'lists/' + invalidId
    When method DELETE
    Then status 404

  Scenario: Put request should return 404 for list id that does not exist
    * def listRequest = read('samples/user-list-request.json')
    * def invalidId = call uuid1
    Given path 'lists/' + invalidId
    And request listRequest
    When method PUT
    Then status 400

  Scenario: Test export list
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    * call refreshList {listId: '#(listId)'}

    Given path 'lists/' + listId + '/exports'
    When method POST
    Then status 201
    And match $.exportId == '#present'
    And match $.listId == listId
    And match $.status == 'IN_PROGRESS'
    * def exportId = $.exportId

    * def pollingAttempts = 0
    * def maxPollingAttempts = 10
    Given path 'lists/' + listId + '/exports/' + exportId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS')
    When method GET
    Then status 200
    And match $.exportId == exportId
    And match $.listId == listId
    And match $.status == 'SUCCESS'

    Given path 'lists/' + listId + '/exports/' + exportId + '/download'
    When method GET
    Then status 200

  Scenario: Getting '404 Response' for invalid exportId
    * def invalidExportId = call uuid1
    Given path 'lists/' + loanListId + '/exports/' + invalidExportId
    When method GET
    Then status 404
    And match $.message == '#present'
    And match $.code == '#present'

  Scenario: Getting '404 Response' for invalid listId
    * def invalidListId = call uuid1
    * def invalidExportId = call uuid1
    Given path 'lists/' + invalidListId + '/exports/' + invalidExportId
    When method GET
    Then status 404
    And match $.message == '#present'
    And match $.code == '#present'

  Scenario: Cancel a refresh
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists/' + listId + '/refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists/' + listId
    When method GET
    Then status 200
    And match $.inProgressRefresh == '#present'

    Given path 'lists/' + listId + '/refresh'
    When method DELETE
    Then status 204

    Given path 'lists/' + listId
    When method GET
    Then status 200
    And match $.inProgressRefresh == '#notpresent'

  Scenario: Export should fail if list is refreshing
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
#    * configure afterScenario = () => karate.call("delete-list.feature", {listId: listId})

    Given path 'lists/' + listId + '/refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists/' + listId + '/exports'
    When method POST
    Then status 400

    Given path 'lists/' + listId + '/refresh'
    When method DELETE
    Then status 204

  Scenario: Post list, refresh list, export list, delete list
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
#    * configure afterScenario = () => karate.call("delete-list.feature", {listId: listId})

    * call refreshList {listId: '#(listId)'}

    Given path 'lists/' + listId + '/exports'
    When method POST
    Then status 201
    And match $.exportId == '#present'
    And match $.listId == listId
    And match $.status == 'IN_PROGRESS'
    * def exportId = $.exportId

    * def pollingAttempts = 0
    * def maxPollingAttempts = 10
    Given path 'lists/' + listId + '/exports/' + exportId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS')
    When method GET
    Then status 200
    And match $.exportId == exportId
    And match $.listId == listId
    And match $.status == 'SUCCESS'

    Scenario: Post private list, confirm that it is only available to the user who created it
    * def listRequest = read('samples/private-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
#    * configure afterScenario = () => karate.call("delete-list.feature", {listId: listId})

    Given path 'lists/' + listId
    When method GET
    Then status 200
    And match $.name == listRequest.name

    * call refreshList { listId : '#(listId)'}

    Given path 'lists/' + listId + '/contents'
    When method GET
    Then status 200

    * callonce login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given path 'lists/' + listId
    When method GET
    Then status 401

    Given path 'lists/' + listId + '/refresh'
    When method POST
    Then status 401

    Given path 'lists/' + listId + '/contents'
    When method GET
    Then status 401
    * configure headers = testUserHeaders