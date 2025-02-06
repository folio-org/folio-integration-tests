Feature: Validate Columns for Entity Types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Validate columns for an entity type
    Given path 'entity-types/' + 'id'

    And headers authHeader
    When method GET
    Then status 200
    And match response.columns != null

#  # Validate each column in the entity type
#    * def columns = response.columns
#    * def sampleRow = call read('get-sample-row.feature') { entityTypeId: '<id>' }
#
#    * eval karate.forEach(columns, function(column) {
#  if (column.dataType.dataType == 'stringType') {
#  karate.call('validate-string-column.feature', { column: column, sampleRow: sampleRow });
#  } else if (column.dataType.dataType == 'booleanType') {
#  karate.call('validate-boolean-column.feature', { column: column, sampleRow: sampleRow });
#  }
#    # Add more conditions for other data types
#  })
