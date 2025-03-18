Feature: Validate Columns for Entity Types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Validate columns for an entity type
    Given path 'entity-types/' + entityTypeId
    When method GET
    Then status 200
    And match response.columns != null

    # Extract columns
    * def columns = response.columns
      # Generate a mock sample row based on column names
    * def sampleRow = {}
    * eval karate.forEach(columns, function(column) { sampleRow[column.name] = column.dataType.dataType == 'stringType' ? 'SampleString' : column.dataType.dataType == 'booleanType' ? 'true' : column.dataType.dataType == 'numberType' ? 123.45 : column.dataType.dataType == 'integerType' ? 100 : column.dataType.dataType == 'dateType' ? '2025-03-14' : column.dataType.dataType == 'rangedUUIDType' ? '123e4567-e89b-12d3-a456-426614174000' : null; })
    * print 'Mocked Sample Row:', sampleRow
    * eval karate.forEach(columns, function(column) { if (['stringType', 'booleanType', 'numberType', 'integerType', 'dateType', 'rangedUUIDType'].includes(column.dataType.dataType)) karate.call('validate-column-helper.feature', { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId }) })



