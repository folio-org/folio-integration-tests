Feature: Search resource
  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 2000 }

  @searchLinkedDataWork
  Scenario: Search work resource
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0  && response.content[0].instances.length > 0
    When method GET
    Then status 200
    * def response = $

  @searchInventoryInstance
  Scenario: Search inventory
    Given path 'search/instances'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def response = $

  @searchAuthority
  Scenario: Search authority
    Given path 'browse/authorities'
    And param query = query
    And param limit = 10
    And param precedingRecordsCount = 5
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def response = $