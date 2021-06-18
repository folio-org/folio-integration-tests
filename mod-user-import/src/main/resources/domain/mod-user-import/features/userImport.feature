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
  Scenario: Import new users with JSON users array and check JSON response
    Given path 'user-import'
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

  Scenario: Verify user was imported successfully by getting the user and checking its properties
    Given path 'users'
    And param query = "barcode==" + barcode
    When method GET
    Then status 200
    And assert response.users[0].barcode == barcode
    And assert response.users[0].username == userName
    And assert response.totalRecords == 1
    # Assign the user id to a variable for use in subsequent scenarios.
    * def userId = response.users[0].id
    * print userId

  # Update a set set of users as defined in a JSON array by posting to the endpoint.
  Scenario: Import updated users with JSON users array and check JSON response
    Given path 'user-import'
    And request
    """
    {
      "users": [
        {
          "id": "#(userId)",
          "externalSystemId": "anyExternalSystemId",
          "barcode": "#(barcode)",
          "username": "TheAmazingJackHandy",
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
    And match response.createdRecords == 0
    And match response.updatedRecords == 1
    And match response.failedRecords == 0
    And match response.totalRecords == 1

  Scenario: Verify JSON user update for a given user by checking updated property
    Given path 'users'
    And param query = "barcode==" + barcode
    When method GET
    Then status 200
    And assert response.users[0].barcode == barcode
    And assert response.users[0].username == "TheAmazingJackHandy"
    And assert response.totalRecords == 1

