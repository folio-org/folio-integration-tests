Feature: Export a list
  Background:
    * url baseUrl

  Scenario: Export a list
    * def postCall = call postList
    * def listId = postCall.listId
    * def entityTypeId = postCall.entityTypeId

    * call refreshList {listId: '#(listId)'}

    # If 'fields' is provided, use it. Otherwise, fetch all columns from entity-types
    * def providedFields = karate.get('fields')
    * def columnsResponse = providedFields == null ? karate.call('classpath:corsair/mod-lists/features/util/get-all-columns.feature', { entityTypeId: entityTypeId }) : null
    * def allFields = columnsResponse != null ? columnsResponse.allColumnNames : null
    * def requestBody = providedFields != null ? providedFields : allFields

    Given path 'lists', listId, 'exports'
    And request requestBody
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