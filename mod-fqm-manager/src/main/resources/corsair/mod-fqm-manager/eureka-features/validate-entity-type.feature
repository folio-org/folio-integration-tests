Feature: Validate all Entity types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Get all entity types (no ids provided)
    Given path 'entity-types'
    When method GET
    Then status 200
    And match $.entityTypes[0] == '#present'
    And match $.entityTypes[1] == '#present'

    And match response.entityTypes != null
     # Extract entity type IDs correctly
    * def entityTypeIds = karate.map(response.entityTypes, function(entity) { return entity.id })
    # Call validate-entity-columns.feature for each entityTypeId
    * eval karate.forEach(entityTypeIds, function(entityTypeId) { karate.call('validate-entity-columns.feature', { entityTypeId: entityTypeId }) })

