Feature: Scenarios that are primarily focused around creating lists

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def itemListId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def loanListId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'

  Scenario: Post and get new list
    * def listRequest = read('samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.name == listRequest.name
    And match $.userFriendlyQuery == '(users.username == integration_test_user_123)'

  Scenario: Posting list request missing required arguments should return '400 Bad Request'
    * def listRequest = read('samples/invalid-list-request.json')
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 400
