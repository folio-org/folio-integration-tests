Feature: Get all columns for an entity type
  Background:
    * url baseUrl

  Scenario: Get all columns
    Given path 'entity-types', entityTypeId
    When method GET
    Then status 200
    And match $.columns == '#present'
    * def allColumns = $.columns
    * def allColumnNames = karate.map(allColumns, function(col){ return col.name })

