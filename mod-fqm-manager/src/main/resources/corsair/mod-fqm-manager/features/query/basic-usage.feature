Feature: Basic query operations
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'

  Scenario: Post query
    * print '## Create query'
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    And match $.queryId == '#present'

  Scenario: Get query results with query id
    * print '## Create query'
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    * def queryId = $.queryId
    * print '## Get query results'
    Given path 'query/' + queryId
    When method GET
    Then status 200
    And match $.queryId == queryId
    And match $.fqlQuery == '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}'
    And match $.entityTypeId == '#present'
    And match $.status == '#present'
    And match $.totalRecords == '#present'

  Scenario: Cancel query
    * print '## Create query'
    Given path 'query'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$in\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 201
    * def queryId = $.queryId
    * print '## Cancel query'
    Given path 'query/' + queryId
    When method DELETE
    Then status 204
    * print '## Verify the query was cancelled'
    Given path 'query/' + queryId
    When method GET
    Then assert (responseStatus == 200 && response.status == "CANCELLED") || responseStatus == 404

  Scenario: Purge queries for a tenant
    Given path 'query/purge'
    When method POST
    Then status 200

  Scenario: Get query results with entity-type-id and query as parameter
    * configure readTimeout = 60000
    Given path 'query'
    And params {entityTypeId: '#(userEntityTypeId)', query: '{\"users.username\": {\"$eq\": \"integration_test_user_123\"}}', fields: ['users.id', 'users.username']}
    When method GET
    Then status 200
    And match $.content[0]["users.username"] == 'integration_test_user_123'
