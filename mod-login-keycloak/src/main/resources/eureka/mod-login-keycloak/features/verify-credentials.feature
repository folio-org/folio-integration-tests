Feature: verify credentials lifecycle

  Background:
    * url baseUrl
    * configure cookies = null
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: verify credentials can be created, updated, checked, and deleted for a newly created user

    # Create a new user
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    * def credentialsUserName = 'credentials-user-' + uuid()
    * def initialPassword = 'InitialPassword123!'
    * def updatedPassword = 'UpdatedPassword123!'

    Given path 'users-keycloak', 'users'
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And request
      """
      {
        "username": "#(credentialsUserName)",
        "active": true,
        "type": "patron",
        "personal": {
          "firstName": "Karate",
          "lastName": "#('User ' + credentialsUserName)"
        }
      }
      """
    When method post
    Then status 201
    * def credentialsUserId = response.id

    # Confirm that the new user has no credentials
    Given path 'authn/credentials-existence'
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And param userId = credentialsUserId
    When method get
    Then status 200
    And match response == { credentialsExist: false }

    # Create the initial credentials for the user.
    Given path 'authn/credentials'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And request { username: '#(credentialsUserName)', userId: '#(credentialsUserId)', password: '#(initialPassword)' }
    When method post
    Then status 201

    # Verify credential is assigned
    Given path 'authn/credentials-existence'
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And param userId = credentialsUserId
    And retry until responseStatus == 200 && response.credentialsExist == true
    When method get
    Then status 200
    And match response == { credentialsExist: true }

    # Verify that the user can log in with the initial password.
    * def initialPasswordLogin = call loginWithExpiry { username: '#(credentialsUserName)', password: '#(initialPassword)' }
    And match initialPasswordLogin.loginStatus == 201

    # Update user's password.
    Given path 'authn/update'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And request { username: '#(credentialsUserName)', password: '#(initialPassword)', newPassword: '#(updatedPassword)' }
    When method post
    Then status 204

    # Verify that the old password is rejected after the password update.
    * def oldPasswordLogin = call loginWithExpiry { username: '#(credentialsUserName)', password: '#(initialPassword)' }
    And match oldPasswordLogin.loginStatus == 401

    # Verify that the new password now works.
    * def updatedPasswordLogin = call loginWithExpiry { username: '#(credentialsUserName)', password: '#(updatedPassword)' }
    And match updatedPasswordLogin.loginStatus == 201

    # Delete the user's credentials.
    Given path 'authn/credentials'
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And param userId = credentialsUserId
    When method delete
    Then status 204

    # Verify credential is deleted
    Given path 'authn/credentials-existence'
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(accessToken)' }
    And param userId = credentialsUserId
    And retry until responseStatus == 200 && response.credentialsExist == false
    When method get
    Then status 200
    And match response == { credentialsExist: false }

    # Verify that login fails once the credentials are deleted.
    * def deletedCredentialsLogin = call loginWithExpiry { username: '#(credentialsUserName)', password: '#(updatedPassword)' }
    And match deletedCredentialsLogin.loginStatus == 401
