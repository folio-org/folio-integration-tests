Feature: Validate Column Helper

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Validate column
    * def column = karate.get('column')
    * def sampleRow = karate.get('sampleRow')
    * def entityTypeId = karate.get('entityTypeId')

    # Capture columnName and fieldValue
    * def columnName = column.name
    * def fieldValue = sampleRow[column.name]

    * def dataTypeToFeature = { stringType: 'validate-string-column.feature', booleanType: 'validate-boolean-column.feature', integerType: 'validate-integerType-column.feature', numberType: 'validate-numberType-column.feature', rangedUUIDType: 'validate-rangedUUIDType-column.feature', dateType: 'validate-dateType-column.feature'}
    * def feature = dataTypeToFeature[column.dataType.dataType]
    * if (feature) karate.call(feature, { column: column, sampleRow: sampleRow, entityTypeId: entityTypeId, columnName: columnName, fieldValue: fieldValue })