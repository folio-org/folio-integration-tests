Feature: Test user business logic

  Background:
    * call login testUser
    * url baseUrl
    * configure headers = { 'X-Okapi-Tenant': '#(testTenant)', 'x-okapi-tenant': '#(testTenant)', 'Authtoken-Refresh-Cache': 'true' , 'Accept': '*/*' ,'x-okapi-token': '#(okapitoken)' }
    * def testUserId = java.lang.System.getProperty('mod-users-bl-testUserId')

  Scenario: Can login after password change
    * configure lowerCaseResponseHeaders = true
    * def newPassword = "Taxfw7rd1!"

    # Login the test admin. This user was created in users-bl-junit.feature.
    Given path 'bl-users/login'
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 200
    And match header access-control-allow-methods contains "POST"

    Given path 'bl-users/login'
    And request
    """
    {
      "username": "#(testAdmin.name)",
      "password": "#(testAdmin.password)"
    }
    """
    When method POST
    Then status 201
    # Grab some variables from the response.
    * def userId = response.user.id
    # Do some validation on the response.
    And match response.user.id == '#uuid'
    And match response.user.username == testAdmin.name
    And match response.user.active == true

    # Update the user's password.
    Given path 'bl-users/settings/myprofile/password'
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 200
    And match header access-control-allow-methods contains "POST"

    Given path 'bl-users/settings/myprofile/password'
    And request
    """
    {
      "userId": "#(userId)",
      "username": "#(testAdmin.name)",
      "password": "#(testAdmin.password)",
      "newPassword": "#(newPassword)"
    }
    """
    When method POST
    Then status 204

    # Login with the new password.
    Given path 'bl-users/login'
    And request
    """
    {
      "username": "#(testAdmin.name)",
      "password": "#(newPassword)"
    }
    """
    When method POST
    Then status 201

  Scenario: Logged in user includes additional information about permissions etc

    Given path 'bl-users/_self'
    When method GET
    Then status 200
    And match response.user.active == true
    And match response.user.personal.firstName == 'Karate'
    And match response.user.username == 'test-user'

  Scenario:  Can fetch open transactions associated with a user by username

    Given path 'bl-users/by-username/' + 'test-user'
    When method GET
    Then status 200
    And match response.user.active == true
    And match response.user.personal.firstName == 'Karate'
    And match response.user.username == 'test-user'

  Scenario: Can fetch open transactions associated with a user by ID

    Given path 'bl-users/by-id/' + testUserId
    When method GET
    Then status 200
    And match response.user.active == true
    And match response.user.personal.firstName == 'Karate'
    And match response.user.username == 'test-user'

  Scenario: Return an object listing number of open transactions that are associated to the user referenced by the user's username
    # creating owner & fine is only for opening & testing a transaction for testUser user.
    Given path 'owners'
    And request
    """
    {
     "owner": "testOwner",
     "desc": "for Testing",
     "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f"
    }
    """
    When method POST
    Then status 201

    Given path 'accounts'
    And request
    """
    {
     "ownerId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
     "feeFineId": "6312d173-f0cf-40f6-b27d-9fa8feaf332f",
     "amount": 15,
     "paymentStatus": {
     "name": "Outstanding"
     },
     "status": {
     "name": "Open"
     },
     "remaining": 5,
     "feeFineType": "printing card",
     "feeFineOwner": "owner",
     "userId": "#(testUserId)",
     "id": "6312d172-f0cf-40f6-b27d-9fa8feaf333f"
    }
    """
    When method POST
    Then status 201

    Given path 'bl-users/by-username/test-user/open-transactions'
    When method GET
    Then status 200
    And match response.hasOpenTransactions == true
    And match response.feesFines == 1

  Scenario: Return an object listing number of open transactions that are associated to the user referenced by the user's id

    # creating proxy
    Given path 'groups'
    And request
    """
    {
      "group": "TestGroup",
      "desc": "For Testing",
      "expirationOffsetInDays": "60",
      "id": "7312d172-f0cf-40f6-b27d-9fa8feaf333f"
    }
    """
    When method POST
    Then status 201

    Given path 'users'
    And request
    """
    {
     "active": true,
     "personal": {
      "firstName": "TestFirstName",
      "preferredContactTypeId": "002",
      "lastName": "TestLastName",
      "preferredFirstName": "Snap",
      "email": "test@mail.com"
      },
     "patronGroup": "7312d172-f0cf-40f6-b27d-9fa8feaf333f",
     "barcode": "12311",
     "id": "7312d172-f0cf-40f7-b27d-9fa8feaf333f",
     "username": "testingUser",
     "departments": []
    }
    """
    When method POST
    Then status 201

    Given path 'proxiesfor'
    And request
    """
    {
     "accrueTo":"Sponsor",
     "notificationsTo":"Sponsor",
     "requestForSponsor":"Yes",
     "status":"Active",
     "proxyUserId":"7312d172-f0cf-40f7-b27d-9fa8feaf333f",
     "userId":"#(testUserId)"
    }
    """
    When method POST
    Then status 201

    Given path 'bl-users/by-id', testUserId, 'open-transactions'
    When method GET
    Then status 200
    And match response.hasOpenTransactions == true
    And match response.feesFines == 1
    And match response.proxies == 1

  Scenario: Disallow deletion of user with open transactions

    Given path 'bl-users/by-id', testUserId
    When method DELETE
    Then status 409
    And match response.hasOpenTransactions == true
    And match response.feesFines == 1
    And match response.proxies == 1
