Feature: Scenarios that are primarily focused around creating lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def itemListId = '605a345f-f456-4ab2-8968-22f49cf1fbb6'
    * def loanListId = '97f5829f-1510-47bc-8454-ae7fa849baef'

  Scenario: Post and get new list
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.name == listRequest.name
    And match $.userFriendlyQuery == '(username == integration_test_user_123)'

  Scenario: Posting list request missing required arguments should return '400 Bad Request'
    * def listRequest = read('samples/invalid-list-request.json')
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 400
