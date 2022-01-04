Feature: Tests for filter terms

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario: Can search by languages filter
    Given path '/search/instances'
    And param query = 'languages=="eng"'
    When method GET
    Then status 200
    Then match response.totalRecords == 2

  Scenario: Can search by item status filter
    Given path '/search/instances'
    And param query = 'items.status.name=="Available"'
    And param expandAll = true
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].items[0].id == '7212ba6a-8dcf-45a1-be9a-ffaa847c4423'

  Scenario: Should expand all
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And param expandAll = true
    When method GET
    Then status 200
    And def record = response.instances[0]
    Then match record.identifiers != undefined
    Then match record.subjects != undefined
    Then match record.hrid != undefined

  Scenario: Should search all records with limit
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And param limit = 1
    When method GET
    Then status 200
    Then match response.instances.length == 1

  Scenario: Should search all records with offset
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    When method GET
    Then status 200
    And def totalRecords = response.totalRecords

    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And param offset = totalRecords - 1
    When method GET
    Then status 200
    Then match response.instances.length == 1
