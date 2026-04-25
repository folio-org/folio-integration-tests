Feature: Scenarios that are primarily focused around exporting list data for ECS TODO: UPDATE

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders
    * configure retry = { interval: 15000, count: 10 }

  @smoke
  Scenario: Test export list
    # Parameters expected:
    # - listFile: path to the list JSON file
    # - fields: (optional) array of field names. If not provided, all columns will be fetched dynamically
    # - ecsField: (optional) ecs-only field to check for presence in export

    * def listRequest = read('classpath:corsair/mod-lists/features/samples/' + listFile)
    * def postCall = call postList
    * def listId = postCall.listId
    * def entityTypeId = postCall.entityTypeId

    # Refresh list with retry logic
    * call refreshList {listId: '#(listId)'}

    Given path 'lists', listId
    When method GET
    Then status 200
    * def refreshStatus = response.successRefresh != null ? 'SUCCESS' : 'FAILED'

    # Retry if failed
    * if (refreshStatus == 'FAILED') karate.call('classpath:corsair/mod-lists/features/util/refresh-list.feature', { listId: listId })

    Given path 'lists', listId
    When method GET
    Then status 200
    * if (refreshStatus == 'FAILED') refreshStatus = response.successRefresh != null ? 'SUCCESS' : 'FAILED'


    # If 'fields' is provided, use it. Otherwise, fetch all columns from entity-types
    * def providedFields = karate.get('fields')
    * def columnsResponse = providedFields == null ? karate.call('classpath:corsair/mod-lists/features/util/get-all-columns.feature', { entityTypeId: entityTypeId }) : null
    * def requestFields = providedFields != null ? providedFields : columnsResponse.allColumnNames

    # Export the list
    Given path 'lists', listId, 'exports'
    And request requestFields
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
    And match $.fields == requestFields
    * def ecsFieldProvided = karate.get('ecsField')
    * if (ecsFieldProvided != null) karate.match("$.fields contains '" + ecsField + "'")

    Given path 'lists', listId, 'exports', exportId, 'download'
    When method GET
    Then status 200

