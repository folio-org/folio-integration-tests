Feature: Tests for filter terms

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}

  Scenario Outline: Can search by various filters
    Given path '/search/instances'
    And param query = '<field>==<value>'
    And param expandAll = true
    When method GET
    Then status 200
    Then match response.totalRecords == <totalRecords>
    Examples:
      | field                                | value                                                                          | totalRecords |
      | languages                            | eng                                                                            | 2            |
      | item.status.name                     | Available                                                                      | 14           |
      | items.status.name                    | Available                                                                      | 14           |
      | classifications.classificationTypeId | 42471af9-7d25-4f3a-bf78-60d29dcf463b                                           | 3            |
      | classifications.classificationTypeId | ce176ace-a53e-4b4d-aa89-725ed7b2edac                                           | 2            |
      | classifications.classificationTypeId | (42471af9-7d25-4f3a-bf78-60d29dcf463b or ce176ace-a53e-4b4d-aa89-725ed7b2edac) | 4            |

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

  Scenario: Can search by createdDate filter
    Given path '/search/instances'
    And param query = 'metadata.createdDate>=2021-03-14'
    And param expandAll = true
    When method GET
    Then status 200
    And response.totalRecords == 17

    Given path '/search/instances'
    And param query = 'metadata.createdDate<2021-03-14'
    And param expandAll = true
    When method GET
    Then status 200
    And response.totalRecords == 0

  Scenario: Can search by updatedDate filter
    Given path '/search/instances'
    And param query = 'metadata.updatedDate>=2021-03-14'
    And param expandAll = true
    When method GET
    Then status 200
    And response.totalRecords == 17

    Given path '/search/instances'
    And param query = 'metadata.updatedDate<2021-03-14'
    And param expandAll = true
    When method GET
    Then status 200
    And response.totalRecords == 0