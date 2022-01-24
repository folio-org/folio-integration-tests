Feature: Test user business logic

  Background:
    * call login testAdmin
    * url baseUrl
    * configure headers = { 'X-Okapi-Tenant': '#(testTenant)', 'Authtoken-Refresh-Cache': 'true' , 'Accept': '*/*' ,'x-okapi-token': '#(okapitoken)' }

  Scenario: Set the right permissions for the admin user.
    Given call read("configurePermissions.feature")

  Scenario: Login, validate the response, change password, login with new
    * configure lowerCaseResponseHeaders = true
    * def newPassword = "Passw0rd1;"

    # Login the test user. This user was created in common/setup-users.feature.
    Given path 'bl-users/login'
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"

    Given path 'bl-users/login'
    And request
    """
    {
      "username": "#(testUser.name)",
      "password": "#(testUser.password)"
    }
    """
    When method POST
    Then status 201
    # Grab some variables from the response.
    * def token = responseHeaders['x-okapi-token'][0]
    * def userId = response.user.id
    # Do some validation on the response.
    And match response.user.id == '#uuid'
    And match response.user.username == testUser.name
    And match response.user.active == true
    And match response.permissions.id == '#uuid'
    And match response.permissions.permissions == '#array'

    # Update the user's password.
    Given path 'bl-users/settings/myprofile/password'
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"

    Given path 'bl-users/settings/myprofile/password'
    And header x-okapi-token = token
    And request
    """
    {
      "userId": "#(userId)",
      "username": "#(testUser.name)",
      "password": "#(testUser.password)",
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
      "username": "#(testUser.name)",
      "password": "#(newPassword)"
    }
    """
    When method POST
    Then status 201
    And match responseHeaders contains { 'x-okapi-token': '#present' }

  Scenario: Return a composite object for the currently logged in user

    Given path 'bl-users/_self'
    When method GET
    Then status 200
    And match response.user.active == true
    And match response.user.personal.firstName == 'Admin'
    And match response.user.username == 'test-admin'
    And match response.permissions.permissions contains [ 'perms.all' , 'okapi.readonly' , 'okapi.all', 'configuration.all' ]

  Scenario:  Return a composite object referenced by the user's username

    Given path 'bl-users/by-username/' + 'test-admin'
    When method GET
    Then status 200
    And match response.user.active == true
    And match response.user.personal.firstName == 'Admin'
    And match response.user.username == 'test-admin'
    And match response.permissions.permissions contains [ 'users-bl.item.get' , 'users-bl.transactions.get' , 'users-bl.item.delete' ]

  Scenario: Return a composite object referenced by the user's id

    Given path 'bl-users/by-id/' + '00000000-1111-5555-9999-999999999991'
    When method GET
    Then status 200
    And match response.user.active == true
    And match response.user.personal.firstName == 'Admin'
    And match response.user.username == 'test-admin'
    And match response.permissions.permissions contains [ 'user-settings.custom-fields.all' , 'login.all' , 'perms.users.assign.immutable' ]

  Scenario: Return an object listing number of open transactions that are associated to the user referenced by the user's username
    # creating owner & fine is only for opening & testing a transaction for testAdmin user.
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
     "userId": "00000000-1111-5555-9999-999999999991",
     "id": "6312d172-f0cf-40f6-b27d-9fa8feaf333f"
    }
    """
    When method POST
    Then status 201

    Given path 'bl-users/by-username/test-admin/open-transactions'
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
     "userId":"00000000-1111-5555-9999-999999999991"
    }
    """
    When method POST
    Then status 201

    Given path 'bl-users/by-id/00000000-1111-5555-9999-999999999991/open-transactions'
    When method GET
    Then status 200
    And match response.hasOpenTransactions == true
    And match response.feesFines == 1
    And match response.proxies == 1

  Scenario: Disallow deletion of user with open transactions.

    Given path 'bl-users/by-id/00000000-1111-5555-9999-999999999991'
    When method DELETE
    Then status 409
    And match response.hasOpenTransactions == true
    And match response.feesFines == 1
    And match response.proxies == 1
