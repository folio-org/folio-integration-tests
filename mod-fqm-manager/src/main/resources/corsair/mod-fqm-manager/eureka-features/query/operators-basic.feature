Feature: Query with basic operators
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'

  Scenario: Run query with $eq operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$eq\":\"integration_test_user_123\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content[0]["users.id"] == '#present'
    And match $.content[0]["users.username"] == "integration_test_user_123"
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $ne operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$ne\":\"integration_test_user_456\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $gt operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.created_date\": {\"$gt\":\"2020-01-01\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $lt operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.created_date\": {\"$lt\":\"2040-01-01\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $in operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$in\":[\"integration_test_user_123\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $nin operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$nin\":[\"integration_test_user_456\", \"other_user\"]}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex starts_with operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$regex\":\"^integration_test\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    And match $.content contains deep {"users.username": 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with $regex contains operator and check results
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$regex\":\"test_user\"}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": 'integration_test_user_123'}
    And match $.content contains deep {"users.username": 'integration_test_user_456'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = true' operator and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.middle_name\": {\"$empty\":true}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.middle_name": null}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0

  Scenario: Run query with '$empty = false' operator and check results (MODFQMMGR-119)
    * def queryRequest = { entityTypeId: '#(userEntityTypeId)' , fqlQuery: '{\"users.username\": {\"$empty\": false}}' }
    * def queryCall = call postQuery
    * def queryId = queryCall.queryId

    Given path 'query', queryId
    And params {includeResults: true, limit: 100, offset:0}
    When method GET
    Then status 200
    And match $.content contains deep {"users.username": '#present'}
    * def totalRecords = parseInt(response.totalRecords)
    * assert totalRecords > 0
