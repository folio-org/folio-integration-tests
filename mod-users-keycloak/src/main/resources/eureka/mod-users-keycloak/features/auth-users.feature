Feature: auth users

  Background:
    * url baseUrl

    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  @Positive
  Scenario: create auth user for existing folio user
    # Create a FOLIO user directly so it exists in mod-users but not yet in Keycloak.
    * configure headers = testAdminHeaders
    * def folioOnlyUserId = uuid()
    * def username = 'auth-user-' + nowMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(folioOnlyUserId)",
        "username": "#(username)",
        "active": true,
        "departments": [],
        "proxyFor": [],
        "type": "patron",
        "personal": {
          "firstName": "Karate",
          "lastName": "#('User ' + username)"
        }
      }
      """
    When method post
    Then status 201
    And match response.id == folioOnlyUserId

    # Verify the auth user does not exist
    * configure headers = testUserHeaders
    Given path 'users-keycloak', 'auth-users', folioOnlyUserId
    When method get
    Then status 404

    # Create the missing Keycloak auth user and verify it now exists.
    Given path 'users-keycloak', 'auth-users', folioOnlyUserId
    When method post
    Then status 201

    Given path 'users-keycloak', 'auth-users', folioOnlyUserId
    When method get
    Then status 204

    # Repeating the create call should be idempotent.
    Given path 'users-keycloak', 'auth-users', folioOnlyUserId
    When method post
    Then status 204

  @Negative
  Scenario: create auth user fails for folio user without username
    # Create a FOLIO user without username
    * configure headers = testAdminHeaders
    * def missingUsernameUserId = uuid()
    Given path 'users'
    And request
      """
      {
        "id": "#(missingUsernameUserId)",
        "active": true,
        "departments": [],
        "proxyFor": [],
        "type": "patron",
        "personal": {
          "firstName": "Karate",
          "lastName": "User without username"
        }
      }
      """
    When method post
    Then status 201
    And match response.id == missingUsernameUserId

    # Creating the auth user should fail because username is required for Keycloak.
    * configure headers = testUserHeaders
    Given path 'users-keycloak', 'auth-users', missingUsernameUserId
    When method post
    Then status 400
    And match response.errors[0].message contains 'User without username cannot be created in Keycloak'
    And match response.errors[0].code == 'user.absent-username'
    And match response.errors[0].type == 'RequestValidationException'
