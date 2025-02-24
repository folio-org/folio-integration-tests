Feature: Validate Columns for Entity Types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Validate columns for an entity type
    # Debugging - Print the received entityTypeId
    * print 'Validating entity type ID:', entityTypeId

    Given path 'entity-types/' + entityTypeId
    When method GET
    Then status 200
    And match response.columns != null

    # Extract columns
    * def columns = response.columns
      # Generate a mock sample row based on column names
    * def sampleRow = {}
#    * eval karate.forEach(columns, function(column) { var mockValue = column.dataType.dataType == 'stringType' ? 'SampleString' : column.dataType.dataType == 'booleanType' ? true : column.dataType.dataType == 'integerType' ? 123 : null; sampleRow[column.name] = mockValue;})
#    * print 'Mocked Sample Row:', sampleRow
#    * eval karate.forEach(columns, function(column) { if (column.dataType.dataType == 'stringType') karate.call('validate-column-helper.feature', { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId }) })
    * eval karate.forEach(columns, function(column) { sampleRow[column.name] = column.dataType.dataType == 'stringType' ? 'SampleString' : column.dataType.dataType == 'booleanType' ? true : null; })
    * print 'Mocked Sample Row:', sampleRow
    * eval karate.forEach(columns, function(column) { if (['stringType', 'booleanType'].includes(column.dataType.dataType)) karate.call('validate-column-helper.feature', { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId }) })


