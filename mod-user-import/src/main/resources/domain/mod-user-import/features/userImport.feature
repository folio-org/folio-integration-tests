Feature: User import

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    # The userId will be used to test updating the user once the id is available after insert.
    * def userId = ""
    * def userGroup = "undergrad"
    # usersToImport is defined in karate-config.js.
    * set usersToImport.users[0].patronGroup = userGroup
    * def barcode = usersToImport.users[0].barcode
    # Define a property that will be changed to test updates.
    * def changedProperty = "TheAmazingJackHandy"

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
      "group": "#(userGroup)",
      "desc": "A user group.",
    }
    """
    When method POST
    Then status 201
    Then match response.group == userGroup

  Scenario: Get groups for tenant and verify
    Given path 'groups'
    When method GET
    Then status 200
    And assert response.usergroups.length == 1
    And assert response.totalRecords == 1

  # Import a set of users as defined in a JSON array by posting to the endpoint.
  Scenario: Import new users with JSON users array and check JSON response
    Given path 'user-import'
    And request usersToImport
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
    And assert response.users[0].username == usersToImport.users[0].username
    And assert response.totalRecords == 1
    # Assign the user id for use in subsequent scenarios. The id is created when the user is inserted.
    * def userId = response.users[0].id
    * print userId

  # Update the test users array with some new properties, including the id which will cause the update to happen.
  Scenario: Import updated users with a changed JSON users array and check JSON response
    * set usersToImport.users[0].id = userId;
    * set usersToImport.users[0].username = changedProperty
    Given path 'user-import'
    And request usersToImport
    When method POST
    Then status 200
    And match response.createdRecords == 0
    And match response.updatedRecords == 1
    And match response.failedRecords == 0
    And match response.totalRecords == 1

  Scenario: Verify JSON user update for a given user by checking the updated property
    Given path 'users'
    And param query = "barcode==" + barcode
    When method GET
    Then status 200
    And assert response.users[0].barcode == barcode
    And assert response.users[0].username == changedProperty
    And assert response.totalRecords == 1
