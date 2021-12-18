Feature: User import

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def userGroup = "undergrad"
    * def groupDescription = "Undergraduate users."
    # usersToImport is defined in karate-config.js.
    * set usersToImport.users[0].patronGroup = userGroup
    * def barcode = usersToImport.users[0].barcode
    # Define a property that will be changed to test updates.
    * def changedProperty = "TheAmazingJackHandy"
    # Define the external system id. This is a concatenation of the sourceType and the externalSystemId in the user.
    * def externalSystemId = usersToImport.sourceType + "_" + usersToImport.users[0].externalSystemId
    # Define an object that we can match against to check inserts and updates.
    * def importedUser =
    """
    {
      id: #uuid,
      externalSystemId: #(externalSystemId),
      username: #(username),
      patronGroup: "#uuid",
      active: true,
      barcode: #(barcode),
      departments: #[0],
      proxyFor: #[0],
      personal: #object,
      enrollmentDate: #string,
      expirationDate: #string,
      createdDate: #string,
      updatedDate: #string,
      metadata: #object
    }
    """

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
      "desc": #(groupDescription),
    }
    """
    When method POST
    Then status 201
    And match response == { group: #(userGroup), desc: #(groupDescription), id: #uuid, metadata: #object }

  Scenario: Get groups for tenant and verify
    Given path 'groups'
    When method GET
    Then status 200
    And match response == { usergroups: #array, totalRecords: 1 }
    And match response.usergroups[0] == { group: #(userGroup), desc: #(groupDescription), id: #uuid, metadata: #object }

  Scenario: Import with JSON users array and check JSON response
    Given path 'user-import'
    And request usersToImport
    When method POST
    Then status 200
    And match response == { message: #string, createdRecords: 1, updatedRecords: 0, failedRecords: 0, totalRecords: 1, failedUsers: #[0] }

  Scenario: Verify JSON user import for a given user
    # Set the username property since it is a parameter to importedUser.
    * def username = usersToImport.users[0].username
    Given path 'users'
    And param query = 'barcode=="' + barcode + '"'
    When method GET
    Then status 200
    And match response == { users: #array, totalRecords: 1, resultInfo: #object }
    And match response.users[0] == importedUser

  Scenario: Update with JSON users array and check JSON response
    # NOTE The update is performed using the externalSystemId as the key.
    * set usersToImport.users[0].username = changedProperty
    # Perform the update.
    Given path 'user-import'
    And request usersToImport
    When method POST
    Then status 200
    And match response == { message: #string, createdRecords: 0, updatedRecords: 1, failedRecords: 0, totalRecords: 1, failedUsers: #[0] }

  Scenario: Verify JSON user import for a given user
    # The username will be our updated property.
    * def username = changedProperty
    Given path 'users'
    And param query = 'barcode=="' + barcode + '"'
    When method GET
    Then status 200
    And match response == { users: #array, totalRecords: 1, resultInfo: #object }
    And match response.users[0] == importedUser
