Feature: Scenarios that are primarily focused around creating lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Post and get new list
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.name == listRequest.name

  Scenario: Posting list request missing required arguments should return '400 Bad Request'
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/invalid-list-request.json')
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 400
