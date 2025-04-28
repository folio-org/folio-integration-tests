Feature: Scenarios that are primarily focused around exporting instance list data for ecs

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * configure retry = { interval: 15000, count: 10 }
    * def loanListId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'

  @Positive
  Scenario: Test export list with all columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/instance-list.json')
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
    And match $.fields == ['instance.hrid', 'instance.title', 'instance.instance_type_name', 'instance.shared', 'instance.tenant_id', 'instance.id']

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200

  @Positive
  Scenario: Test export list with selected columns
    * def listRequest = read('classpath:corsair/mod-lists/features/samples/instance-list.json')
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
    And match $.fields == ['instance.hrid', 'instance.title', 'instance.id','instance.tenant_id']
    And match $.fields !contains 'instance.instance_type_name'

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200