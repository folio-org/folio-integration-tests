Feature: Entity types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def simpleLocationsEntityTypeId = '74ddf1a6-19e0-4d63-baf0-cd2da9a46ca4'
    * def itemEntityTypeId = 'd0213d22-32cf-490f-9196-d81c3c66e53f'
    * def loanEntityTypeId = 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'
    * def locationsEntityTypeId = '74ddf1a6-19e0-4d63-baf0-cd2da9a46ca4'
    * def purchaseOrderLinesEntityTypeId = 'abc777d3-2a45-43e6-82cb-71e8c96d13d2'
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'

  Scenario: Get all entity types (no ids provided)
    Given path 'entity-types'
    When method GET
    Then status 200
    And match $.entityTypes[0] == '#present'
    And match $.entityTypes[1] == '#present'
    # double-hash present means NOT present (we want this to be missing since we didn't ask to include inaccessible)
    # https://stackoverflow.com/a/53872251/4236490
    And match $.entityTypes[0].missingPermissions == '##present'
    And match $.entityTypes[1].missingPermissions == '##present'
    And match $._version == '##present'
    And def numAccessible = response.entityTypes.length

    Given path 'entity-types'
    And params { includeInaccessible: true }
    When method GET
    Then status 200
    And match $.entityTypes[0] == '#present'
    # current tests grant user all permissions for all entity types
    # this should be changed to not include all entity types and ensure we're actually given
    # one that is inaccessible
    And assert response.entityTypes.length >= numAccessible

  Scenario: Get entity type for array with single valid id
    * def query = { ids: ['#(itemEntityTypeId)'] }
    Given path 'entity-types'
    And params query
    When method GET
    Then status 200
    And match $.entityTypes[0].id == itemEntityTypeId
    And match $.entityTypes[0].label == "Items"
    And match $._version == '##present'

  Scenario: Get entity types for array with multiple valid ids
    * def query = { ids: ['#(itemEntityTypeId)', '#(loanEntityTypeId)'] }
    Given path 'entity-types'
    And params query
    When method GET
    Then status 200
    * assert (response.entityTypes[0].label == 'Items' || response.entityTypes[0].label == 'Loans')
    * assert (response.entityTypes[1].label == 'Items' || response.entityTypes[1].label == 'Loans')

  Scenario: Get entity type for array with single invalid id (should return empty array)
    * def invalidId = call uuid1
    * def query = { ids: ['#(invalidId)'] }
    Given path 'entity-types'
    And params query
    When method GET
    Then status 200
    And match $.entityTypes == []

  Scenario: Get entity types for array with for multiple valid ids, single invalid id
    * def invalidId = call uuid1
    * def query = { ids: ['#(itemEntityTypeId)', '#(loanEntityTypeId)', '#(invalidId)'] }
    Given path 'entity-types'
    And params query
    When method GET
    Then status 200
    And match $.entityTypes.size() == 2
    * assert (response.entityTypes[0].label == 'Items' || response.entityTypes[0].label == 'Loans')
    * assert (response.entityTypes[1].label == 'Items' || response.entityTypes[1].label == 'Loans')

  Scenario: Get entity type for invalid ids array should return '400 Bad Request'
    * def query = { ids: [100, 200] }
    Given path 'entity-types'
    And params query
    When method GET
    Then status 400

  Scenario: Get simple entity type for a valid id
    Given path 'entity-types', simpleLocationsEntityTypeId
    When method GET
    Then status 200
    And match $.id == simpleLocationsEntityTypeId
    And match $.name == 'simple_location'
    And match $.columns == '#present'
    And match $.defaultSort == '#present'

  Scenario: Get complex entity type for a valid id
    Given path 'entity-types', itemEntityTypeId
    When method GET
    Then status 200
    And match $.id == itemEntityTypeId
    And match $.name == 'composite_item_details'
    And match $.columns == '#present'
    And match $.sources == '#present'

  Scenario: Get entity type for an invalid id should return '404 Not Found'
    * def invalidId = call uuid1
    Given path 'entity-types', invalidId
    When method GET
    Then status 404

  Scenario: Get details for entity-type providing entity-type-id
    Given path 'entity-types', loanEntityTypeId
    When method GET
    Then status 200
    And match $.id == loanEntityTypeId
    And match $.name == 'composite_loan_details'
    And match $.labelAlias == 'Loans'
    And match $.columns == '#present'
    And match $.columns[*].source[*].entityTypeId == '#present'
    And match $.columns[*].source[*].columnName == '#present'

  Scenario: Get column value for an entity-type
    Given path 'entity-types', locationsEntityTypeId
    When method GET
    Then status 200
    And match $.id == locationsEntityTypeId
    And match $.name == 'simple_location'
    And match $.labelAlias == 'Locations'
    And match $.columns == '#present'
    Given path 'entity-types', locationsEntityTypeId, 'field-values'
    And param field = 'name'
    When method GET
    Then status 200
    And match $.content[0].value == '#present'

  Scenario: Get column values for instance.languages
    Given path 'entity-types', instanceEntityTypeId, 'field-values'
    And param field = 'instance.languages'
    When method GET
    Then status 200
    And match $.content[0].value == '#present'

  Scenario: Get column name and value with search parameter
    * def fieldName = 'name'
    Given path 'entity-types', locationsEntityTypeId, 'field-values'
    And param field = fieldName
    And param search = 'Location'
    When method GET
    Then status 200
    * def label = $.content[0].label
    * match label contains 'Location 1'

  Scenario: Get column name and value microservice for invalid column name should return '404 Not Found' Response
    * def fieldName  = 'invalid_column_name'
    Given path 'entity-types', loanEntityTypeId, 'field-values'
    And param field = fieldName
    When method GET
    Then status 404

  Scenario: Get column name and value microservice for invalid entity-type-id should return '404 Not Found' Response
    * def fieldName  = 'invalid_column_name'
    * def invalidId = call uuid1
    Given path 'entity-types', invalidId, 'field-values'
    And param field = fieldName
    When method GET
    Then status 404

  Scenario: Refresh materialized view for tenant
    Given path 'entity-types', 'materialized-views', 'refresh'
    When method POST
    Then status 200

  Scenario: Ensure all entity type and field names are localized
    Given path 'entity-types'
    When method GET
    Then status 200

    # calls this feature on each entity type summary
    * call read('entity-type-localized.feature') response.entityTypes
