Feature: Validate Invalid Inputs for String Columns
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*' }

  Scenario: Handle invalid input gracefully
    * def input = karate.get('input')
  try {
    Given path 'query'
    And request { entityTypeId: '#(entityTypeId)', fqlQuery: '{\"#(column.name)\": {\"$eq\": \"#(input)\"}}' }
    When method POST
    Then status 201
    And match $.queryId == '#present'
  } catch (e) {
  print 'Invalid input encountered: ' + input
        # Handle invalid input by expecting a failure status or specific error message
    And status 400
  }
