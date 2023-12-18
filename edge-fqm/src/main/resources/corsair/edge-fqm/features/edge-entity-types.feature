Feature: Entity types

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*' }
    * def itemEntityTypeId = '0cb79a4c-f7eb-4941-a104-745224ae0292'
    * def userEntityTypeId = '0069cf6f-2833-46db-8a51-8934769b8289'

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
    And path 'entity-types/' + itemEntityTypeId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.id == itemEntityTypeId
    And match $.name == 'drv_item_details'
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
    * def userRequest = read('samples/user-request.json')
    Given url edgeUrl
    And path 'entity-types/' + userEntityTypeId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.id == userEntityTypeId
    And match $.name == 'drv_user_details'
    And match $.labelAlias == 'Users'
    And match $.columns == '#present'
    Given path 'entity-types/' + userEntityTypeId + '/columns/username/values'
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