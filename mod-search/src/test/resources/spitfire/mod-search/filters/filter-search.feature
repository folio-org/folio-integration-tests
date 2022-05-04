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
    And param query = 'item.status.name=="Available"'
    And param expandAll = true
    When method GET
    Then status 200
    Then match response.totalRecords == 14

  Scenario: Can search by items status filter
    Given path '/search/instances'
    And param query = 'items.status.name=="Available"'
    And param expandAll = true
    When method GET
    Then status 200
    Then match response.totalRecords == 14

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
    Then assert response.instances.length == 1

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
    Then assert response.instances.length == 1
