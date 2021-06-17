Feature: User import

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Import without users
    Given path 'user-import'
    And header Content-Type = 'application/json'
    And header X-Okapi-Url = baseUrl
    And request
    """
    {
      "totalRecords": 0,
      "users": []
    }
    """
    When method POST
    Then status 200

  # Import a set of users as defined in a JSON array by posting to the endpoint.
  @Undefined
  Scenario: Import with JSON users array and check JSON response
    * print 'undefined'
    # TODO Check the user import response. Do the following properties have the correct value in the JSON response:
    # * createdRecords
    # * updatedRecords
    # * failedRecords
    # * totalRecords
    # * ?

  # Fetch a given user that was imported from JSON array and see if properties match the user's properties in the array.
  @Undefined
  Scenario: Verify JSON user import for a given user
    * print 'undefined'

  # Update a set set of users as defined in a JSON array by posting to the endpoint.
  @Undefined
  Scenario: Update with JSON users array and check JSON response
    * print 'undefined'
    # TODO Check the user update response. Do the following properties have the correct value in the JSON response:
    # * createdRecords
    # * updatedRecords
    # * failedRecords
    # * totalRecords
    # * ?

  # Fetch a given user that was updated from the JSON array and see if properties match the original user's properties.
  @Undefined
  Scenario: Verify JSON user import for a given user
    * print 'undefined'


