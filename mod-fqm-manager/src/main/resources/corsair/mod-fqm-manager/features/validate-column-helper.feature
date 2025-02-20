Feature: Validate Column Helper

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Validate string column
    * def column = karate.get('column')
    * def sampleRow = karate.get('sampleRow')
    * def entityTypeId = karate.get('entityTypeId')

    # Capture columnName and fieldValue
    * def columnName = column.name
    * def fieldValue = sampleRow[column.name]

    # Debugging prints
    * print 'Passing to validate-string-column.feature:', { columnName: columnName, fieldValue: fieldValue, entityTypeId: entityTypeId }
    * print 'Passing to validate-boolean-column.feature:', { columnName: columnName, fieldValue: fieldValue, entityTypeId: entityTypeId }


    # Call validate-string-column.feature with the captured data
#    * karate.call('validate-string-column.feature', { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId, columnName: columnName, fieldValue: fieldValue})
    * column.dataType.dataType == 'stringType' ? karate.call('validate-string-column.feature', { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId, columnName: columnName, fieldValue: fieldValue }) : (column.dataType.dataType == 'booleanType' ? karate.call('validate-boolean-column.feature', { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId, columnName: columnName, fieldValue: fieldValue }) : karate.log('Unsupported data type: ' + column.dataType.dataType))


