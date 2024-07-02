Feature: Query
  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*' }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'

  Scenario: Post query with invalid fql query should return 400 error without exposing headers
    Given url edgeUrl
    And path 'query'
    And param apikey = apikey
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$xy\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 400
    And match $.message == '#present'
    And match $.parameters[0].value == "Condition {\"$xy\":[\"missing\",\"lost\"]} contains an invalid operator"
    And match karate.keysOf(responseHeaders) !contains 'x-okapi-token'

  Scenario: Post query with invalid API key should return 401 error
    Given url edgeUrl
    And path 'query'
    And param apikey = 'invalidApiKey'
    And request { entityTypeId: '#(itemEntityTypeId)', fqlQuery: '{\"items.status_name\": {\"$xy\": [\"missing\", \"lost\"]}}' }
    When method POST
    Then status 401

  Scenario: Post query with missing fql query should return 400 error
    Given url edgeUrl
    And path 'query'
    And param apikey = apikey
    And request { entityTypeId: '#(itemEntityTypeId)' }
    When method POST
    Then status 400

  Scenario: Post query without required parameters should return 400 error
    Given url edgeUrl
    And path 'query'
    And param apikey = apikey
    When method POST
    Then status 400

  Scenario: Get query with invalid queryId should return 400 error
    * def invalidId = call uuid1
    Given url edgeUrl
    And path 'query/' + invalidId
    And param apikey = apikey
    When method GET
    Then status 404

  Scenario: Get query results with entity-type-id and query as parameter
    * configure readTimeout = 60000
    Given url edgeUrl
    And path 'query'
    And params {entityTypeId: '#(userEntityTypeId)', query: '{\"users.username\": {\"$regex\": \"t\"}}', fields: ['users.id', 'users.username'], apikey: '#(apikey)'}
    When method GET
    Then status 200
    And match $.content[0] == '#present'

  Scenario: Get and compare query results from edge-fqm API and mod-fqm-manager API
    Given url edgeUrl
    And path 'query'
    And request { entityTypeId: '#(userEntityTypeId)', fqlQuery: '{\"users.username\": {\"$eq\": \"diku_admin\"}}' }
    And param apikey = apikey
    When method POST
    Then status 201

    * def queryId = $.queryId
    * def pollingAttempts = 0
    * def maxPollingAttempts = 3
    Given path 'query/' + queryId
    And params {includeResults: true, apikey: '#(apikey)'}
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS')
    When method GET
    Then status 200
    And match $.queryId == queryId
    And match $.fqlQuery == '{\"users.username\": {\"$eq\": \"diku_admin\"}}'
    And match $.entityTypeId == '#(userEntityTypeId)'
    And match $.status == 'SUCCESS'
    And match $.totalRecords == '#present'
    And match $.content[0].username == 'diku_admin'
    * def edgeResponse = $

    * call login admin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given url baseUrl
    And path 'query/' + queryId
    And params {includeResults: true}
    When method GET
    Then status 200
    And match response == edgeResponse