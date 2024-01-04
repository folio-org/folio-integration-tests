Feature: Scenarios that are primarily focused around updating/editing lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Update list with a PUT request and confirm that it is updated
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.name == listRequest.name
    * def version = 1

    * def listRequest = {name: 'Updated Integration Test List', isActive:  'true', isPrivate: 'false', version: 1, fqlQuery: "{\"username\": {\"$eq\": \"user1\"}}"}
    * call updateList {listId: '#(listId)', listRequest: '#(listRequest)'}

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.name == 'Updated Integration Test List'
    And match $.version ==  version + 1

  Scenario: Put request should return 404 for list id that does not exist
    * def listRequest = read('samples/user-list-request.json')
    * def invalidId = call uuid1
    Given path 'lists', invalidId
    And request listRequest
    When method PUT
    Then status 400
