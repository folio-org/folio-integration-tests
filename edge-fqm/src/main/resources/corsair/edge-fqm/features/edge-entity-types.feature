Feature: Entity types

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*' }
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def userEntityTypeId = 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'
    * def holdingsEntityTypeId = '8418e512-feac-4a6a-a56d-9006aab31e33'

  Scenario: Get all entity types (no ids provided) and ensure no headers are exposed
    Given url edgeUrl
    And path 'entity-types'
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.[0] == '#present'
    And match $.[1] == '#present'
    And match $.[2] == '#present'
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

  @ignore
  Scenario: Get column value for an entity-type
    Given url edgeUrl
    And path 'entity-types/' + userEntityTypeId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.id == userEntityTypeId
    And match $.name == 'composite_user_details'
    And match $.labelAlias == 'Users'
    And match $.columns == '#present'
    Given path 'entity-types/' + userEntityTypeId + '/columns/users.username/values'
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.content[0].value == '#present'

  Scenario: Edge API should return exact same content as mod-fqm-manager API
    Given url edgeUrl
    And path 'entity-types'
    And param apikey = apikey
    When method GET
    Then status 200
    * def edgeResponse = $

    * call login admin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    Given url baseUrl
    And path 'entity-types'
    When method GET
    Then status 200
    And match response == edgeResponse