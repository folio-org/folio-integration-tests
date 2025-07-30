Feature: Validate Integer Columns

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  Scenario: Validate an integer column
    # Check if the field value is not null
    * match fieldValue != null

    # Check if the field value is an integer
    * match fieldValue == '#number'
#    * match fieldValue % 1 == 0

    # Construct the FQL query JSON properly
    * def fqlQuery = '{"' + columnName + '": {"$eq": "' + fieldValue + '"}, "_version": "' + fqmVersion + '"}'

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
