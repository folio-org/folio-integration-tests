Feature: Validate Boolean Columns
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }
    * karate.set('failedFields', [])

  Scenario: Validate a boolean column
    * print 'Validating boolean column:', columnName, 'with value:', fieldValue

    # Check if the field value is not null
    * match fieldValue != null

    # Check if the field value is a boolean (true or false)
    * match fieldValue == true || fieldValue == false

    # Construct the FQL query JSON properly
    * def fqlQuery = '{"' + columnName + '": {"$eq": ' + fieldValue + '}}'

    # Debugging - Print the final request body
    * print 'Final Request Body:', { entityTypeId: entityTypeId, fqlQuery: fqlQuery }

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
    And print response
      # Using ternary-like syntax for conditional assignment
    * def statusMessage = response.status == 'FAILED' ? 'Field failed:' : 'Field succeeded:'
    * if (response.status == 'FAILED') karate.appendTo('failedFields',columnName)
    * print statusMessage, columnName
    And print karate.get('failedFields')
