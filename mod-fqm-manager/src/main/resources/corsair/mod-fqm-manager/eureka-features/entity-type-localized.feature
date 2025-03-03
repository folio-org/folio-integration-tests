Feature: Check that an entity type is localized
  Background:
    * url baseUrl
    * callonce login testUser
    * def testTenant = 'testtenanttymofii'
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Get and verify localization of an entity type
    Given path 'entity-types', id
    When method GET
    Then status 200

    # This prefix indicates something that was not translated due to a missing translation
    # Just checking against the JSON blob is cheap and handles any nesting, values, etc.
    * string json = response
    And match json !contains 'mod-fqm-manager.entityType'
