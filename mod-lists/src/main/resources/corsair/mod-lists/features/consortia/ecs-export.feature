Feature: Scenarios that are primarily focused around exporting list data for ecs

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * configure retry = { interval: 15000, count: 10 }
    * def loanListId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'

  @Positive
  Scenario: Test export list
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list-request.json')
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

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200