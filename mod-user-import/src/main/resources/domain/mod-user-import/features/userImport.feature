Feature: User import

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def userName = "Jack_Handey"
    * def barcode = "1231233425"
    * def userGroup = "undergrad"

  Scenario: Import without users
    Given path 'user-import'
    And request
    """
    {
      "totalRecords": 0,
      "users": []
    }
    """
    When method POST
    Then status 200

  Scenario: Get users for tenant
    Given path 'users'
    When method GET
    Then status 200

  # Importing a user requires that the group associated with the user already be created.
  Scenario: Add user group for tenant
    Given path 'groups'
    And request
    """
    {
      "group": "undergrad",
      "desc": "A undergrad user group.",
    }
    """
    When method POST
    Then status 201
    Then match response.group == userGroup

  Scenario: Get groups for tenant
    Given path 'groups'
    When method GET
    Then status 200
    And assert response.usergroups.length == 1
    And assert response.totalRecords == 1

  # Import a set of users as defined in a JSON array by posting to the endpoint.
  Scenario: Import with JSON users array and check JSON response
    Given path 'user-import'
    # NOTE in a successful user create in the rest assured tests the userId is not provided (is null in generateUser).
    And request
    """
    {
      "users": [
        {
          "externalSystemId": "anyExternalSystemId",
          "barcode": "#(barcode)",
          "username": "#(userName)",
          "active": true,
          "patronGroup": "#(userGroup)",
          "personal": {
            "lastName": "Handey",
            "firstName": "Jack",
            "email": "jack@handey.org",
            "preferredContactTypeId": "email"
          }
        }
      ],
      "totalRecords": 1,
    }
    """
    When method POST
    Then status 200
    And match response.createdRecords == 1
    And match response.updatedRecords == 0
    And match response.failedRecords == 0
    And match response.totalRecords == 1

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


