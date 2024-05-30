Feature: Scenarios that are primarily focused around deleting lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Delete request should return 404 for an ID that does not exist
    * def invalidId = call uuid1
    Given path 'lists', invalidId
    When method DELETE
    Then status 404

  Scenario: Post list, refresh list, export list, delete list
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    * call refreshList {listId: '#(listId)'}

    Given path 'lists', listId, 'exports'
    When method POST
    Then status 201
    And match $.exportId == '#present'
    And match $.listId == listId
    And match $.status == 'IN_PROGRESS'
    * def exportId = $.exportId

    * def pollingAttempts = 0
    * def maxPollingAttempts = 100
    Given path 'lists', listId, 'exports', exportId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS')
    When method GET
    Then status 200
    And match $.exportId == exportId
    And match $.listId == listId
    And match $.status == 'SUCCESS'

    Given path 'lists', listId
    When method DELETE
    Then status 204

  Scenario: [FAT-11792] Verify GET /lists and /lists/{id}/* behave appropriately after soft deletion
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId
    When method DELETE
    Then status 204

    # no parameter should default to false
    Given path 'lists'
    When method GET
    Then status 200
    And match $.content == '#present'
    * assert response.content.every(list => list.isDeleted == false)
    # ensure it's not present
    * def deletedList = response.content.find(list => list.id == listId)
    * assert deletedList == null

    # not included
    Given path 'lists'
    And param includeDeleted = false
    When method GET
    Then status 200
    And match $.content == '#present'
    * assert response.content.every(list => list.isDeleted == false)
    # ensure it's not present
    * def deletedList = response.content.find(list => list.id == listId)
    * assert deletedList == null

    # included here
    Given path 'lists'
    And param includeDeleted = true
    When method GET
    Then status 200
    And match $.content == '#present'
    * def deletedList = response.content.find(list => list.id == listId)
    * assert deletedList.isDeleted == true

    # test sub-operations
    Given path 'lists', listId
    When method GET
    Then status 404

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 404

    Given path 'lists', listId, 'exports'
    When method POST
    Then status 404

    Given path 'lists', listId, 'contents'
    When method GET
    Then status 404

    Given path 'lists', listId, 'versions'
    When method GET
    Then status 404
