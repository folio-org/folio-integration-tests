Feature: Validate String Columns
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Validate a string column
    * print 'Validating string column:', columnName, 'with value:', fieldValue

    # Check if the field value is not null or empty
    * match fieldValue != null
    * match fieldValue != ""

    # Perform additional checks on the field value (e.g., length, format, etc.)
    * assert fieldValue.length() > 0

    # Construct the FQL query JSON properly
    * def fqlQuery = '{"' + columnName + '": {"$eq": "' + fieldValue + '"}}'

    # Debugging - Print the final request body
    * print 'Final Request Body:', { entityTypeId: entityTypeId, fqlQuery: fqlQuery }


#    # Post the query for the valid field value
#    Given path 'query'
#    And request { entityTypeId: '#(entityTypeId)', fqlQuery: '#(fqlQueryString)' }
#    When method POST
#    Then status 201
#    And match $.queryId == '#present'
#
#    # Use queryId for polling the result
#    * def queryId = $.queryId
#    * def pollingAttempts = 0
#    * def maxPollingAttempts = 1
#    Given path 'query/' + queryId
#    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS')
#    When method GET
#    Then status 200
#    And match response.data contains { '#(columnName)': '#(fieldValue)' }

#    * def invalidInputs = [null, 12345, '!@#$$%']
#    * karate.forEach(invalidInputs, function(input) {karate.call('validate-invalid-inputs.feature', {input: input, entityTypeId: entityTypeId, column: column})})

