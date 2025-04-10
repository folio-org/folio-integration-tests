Feature: Validate String Columns
  Background:
    * url baseUrl
#    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Validate a string column
    # Check if the field value is not null or empty
    * match fieldValue != null
    * match fieldValue != ""

    # Perform additional checks on the field value (e.g., length, format, etc.)
    * assert fieldValue.length() > 0

    # Construct the FQL query JSON properly
    * def fqlQuery = '{"' + columnName + '": {"$eq": "' + fieldValue + '"}}'
    # Post the query for the valid field value
    Given path 'query'
    And request { entityTypeId: '#(entityTypeId)', fqlQuery: '#(fqlQuery)' }
    When method POST
    Then status 201
    And match $.queryId == '#present'

    # Use queryId for polling the result
    * def queryId = $.queryId
    * def pollingAttempts = 0
    * def maxPollingAttempts = 1
    Given path 'query/' + queryId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS' || response.status == 'FAILED')
    When method GET
    Then status 200

    # Check if the status is FAILED and immediately fail the test
    * def statusMessage = response.status == 'FAILED' ? 'Field failed:' : 'Field succeeded:'
    * def action = response.status == 'FAILED' ? karate.fail('Field failed: ' + columnName) : print('Field succeeded:', columnName)

    # Print the result
    * print statusMessage, columnName
