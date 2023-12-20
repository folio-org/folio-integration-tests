Feature: Scenarios that are primarily focused around deleting lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Delete request should return 404 for id that does not exist
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
    * def maxPollingAttempts = 10
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
