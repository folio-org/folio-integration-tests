Feature: Query migration and versioning
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Get FQL version
    Given path 'fqm', 'version'
    When method GET
    Then status 200
    And def version = response

    Given path 'entity-types'
    When method GET
    Then status 200
    And match $._version == version

  Scenario: Migrate query for users
    * def migrateRequest = { entityTypeId: '0069cf6f-2833-46db-8a51-8934769b8289' , fqlQuery: '{\"user_active\": {\"$eq\":\"true\"}}', fields : '[\"user_active\"]'}
    Given path 'fqm', 'migrate'
    And request migrateRequest
    When method POST
    Then status 200
    And match response.entityTypeId == 'ddc93926-d15a-4a45-9d9c-93eadc3d9bbf'
    # ignore _version content, just make sure it's present
    * def testQueryMigrated = function(x) { const q = JSON.parse(x); const _version = q._version; delete q._version; return JSON.stringify(q) === JSON.stringify({"users.active":{"$eq":"true"}}) && /\d+/.test(_version); }
    * assert testQueryMigrated(response.fqlQuery)
    And match response.fields == ['["user_active"]']
    And match response.warnings == []

  Scenario: Migrate query for loans
    * def migrateRequest = { entityTypeId: '4e09d89a-44ed-418e-a9cc-820dfb27bf3a' , fqlQuery: '{\"return_date\": {\"$leq\":\"2024-01-01\"}}', fields : '[\"user_last_name\"]'}
    Given path 'fqm', 'migrate'
    And request migrateRequest
    When method POST
    Then status 200
    And match response.entityTypeId == 'd6729885-f2fb-4dc7-b7d0-a865a7f461e4'
    # ignore _version content, just make sure it's present
    * def testQueryMigrated = function(x) { const q = JSON.parse(x); const _version = q._version; delete q._version; return JSON.stringify(q) === JSON.stringify({"return_date":{"$leq":"2024-01-01"}}) && /\d+/.test(_version); }
    * assert testQueryMigrated(response.fqlQuery)
    And match response.warnings == []

  Scenario: Migrate queries with warning
    * def migrateRequest = { entityTypeId: '146dfba5-cdc9-45f5-a8a1-3fdc454c9ae2' , fqlQuery: '{\"loan_status\": {\"$ne\":\"zz\"}}', fields : '[\"loan_status\"]'}
    Given path 'fqm', 'migrate'
    And request migrateRequest
    When method POST
    Then status 200
    And match response.entityTypeId == 'deadbeef-dead-dead-dead-deaddeadbeef'
    # ignore _version content, just make sure it's present
    * def testQueryMigrated = function(x) { const q = JSON.parse(x); const _version = q._version; delete q._version; return JSON.stringify(q) === JSON.stringify({}) && /\d+/.test(_version); }
    * assert testQueryMigrated(response.fqlQuery)
    And match response.fields == []
    And match response.warnings[0].description == 'Record type drv_loan_status is no longer available. You may be able to use simple_loans instead. For reference, your original query was {"loan_status":{"$ne":"zz"}}.'
    And match response.warnings[0].type == 'REMOVED_ENTITY'
