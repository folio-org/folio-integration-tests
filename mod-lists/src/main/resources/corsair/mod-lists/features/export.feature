Feature: Scenarios that are primarily focused around exporting list data

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * def loanListId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'

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

  Scenario: Getting '404 Response' for invalid exportId
    * def invalidExportId = call uuid1
    Given path 'lists', loanListId, 'exports', invalidExportId
    When method GET
    Then status 404
    And match $.message == '#present'
    And match $.code == '#present'

  Scenario: Getting '404 Response' for invalid listId
    * def invalidListId = call uuid1
    * def invalidExportId = call uuid1
    Given path 'lists', invalidListId, 'exports', invalidExportId
    When method GET
    Then status 404
    And match $.message == '#present'
    And match $.code == '#present'

  Scenario: Export should fail if list is refreshing
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/user-list-request.json')
    * def postCall = call postList
    * def listId = postCall.listId

    Given path 'lists', listId, 'refresh'
    When method POST
    Then status 200
    And match $.status == 'IN_PROGRESS'

    Given path 'lists', listId, 'exports'
    When method POST
    Then status 400

    Given path 'lists', listId, 'refresh'
    When method DELETE
    Then status 204

  Scenario: Export test with instance and list using all columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/non-ecs-instance-list.json.json')
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
    And match $.fields == ['instance.hrid', 'instance.title', 'instance.instance_type_name', 'instance.id']

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200

  Scenario: Export test with instance and list using selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/non-ecs-instance-list.json')
    * def postCall = call postList
    * def listId = postCall.listId

    * call refreshList {listId: '#(listId)'}

    Given path 'lists', listId, 'exports'
    And request ['instance.hrid', 'instance.title', 'instance.id']
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
    And match $.fields == ['instance.hrid', 'instance.title', 'instance.id']
    And match $.fields !contains 'instance.instance_type_name'

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200