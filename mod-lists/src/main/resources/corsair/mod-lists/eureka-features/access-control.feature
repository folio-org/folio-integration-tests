Feature: Scenarios that are primarily focused around list access control

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  Scenario: Post private list, confirm that it is only available to the user who created it
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/private-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId
    #    * configure afterScenario = () => karate.call("delete-list.feature", {listId: listId})

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.name == listRequest.name

    * call refreshList { listId : '#(listId)'}

    Given path 'lists', listId, 'contents'
    When method GET
    Then status 200

    * callonce login testUser2
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'lists', listId
    When method GET
    Then status 401

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 401

    Given path 'lists', listId, 'contents'
    When method GET
    Then status 401
    * configure headers = testUserHeaders
