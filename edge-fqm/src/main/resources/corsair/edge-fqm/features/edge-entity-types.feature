Feature: Entity types

  Background:
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*' }
    * def locationsEntityTypeId = '74ddf1a6-19e0-4d63-baf0-cd2da9a46ca4'
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'

  Scenario: Get all entity types (no ids provided) and ensure no headers are exposed
    Given url edgeUrl
    And path 'entity-types'
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.entityTypes[0] == '#present'
    And match $.entityTypes[1] == '#present'
    And match $.entityTypes[2] == '#present'
    And match karate.keysOf(responseHeaders) !contains 'x-okapi-token'

  Scenario: Get entity with invalid API key should return 401 error
    Given url edgeUrl
    And path 'entity-types'
    And param apikey = 'invalidApiKey'
    When method GET
    Then status 401

  Scenario: Get entity type for invalid ids array should return '400 Bad Request'
    * def query = { ids: [100, 200], apikey: '#(apikey)' }
    Given url edgeUrl
    And path 'entity-types'
    And params query
    When method GET
    Then status 400

  Scenario: Get entity type for a valid id
    Given url edgeUrl
    And path 'entity-types/' + holdingsEntityTypeId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.id == holdingsEntityTypeId
    And match $.name == 'composite_holdings_record'
    And match $.columns == '#present'
    And match $.defaultSort == '#present'

  Scenario: Get entity type for an invalid id should return '404 Not Found'
    * def invalidId = '0cb79a4c-f7eb-4941-a104-745224ae0297'
    Given url edgeUrl
    And param apikey = apikey
    And path 'entity-types/' + invalidId
    When method GET
    Then status 404

  Scenario: Get column value for an entity-type
    Given url edgeUrl
    And path 'entity-types/' + locationsEntityTypeId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.id == locationsEntityTypeId
    And match $.name == 'simple_location'
    And match $.labelAlias == 'Locations'
    And match $.columns == '#present'
    Given path 'entity-types/' + locationsEntityTypeId + '/columns/name/values'
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.content[0].value == '#present'

  Scenario: Edge API should return exact same entity type list as mod-fqm-manager API
    Given url edgeUrl
    And path 'entity-types'
    And param apikey = apikey
    When method GET
    Then status 200
    * def edgeResponse = $
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)', 'Accept': '*/*' }
    Given url baseUrl
    And path 'entity-types'
    When method GET
    Then status 200
    And match response == edgeResponse
