Feature: users

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

    * callonce login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

    * configure headers = testUserHeaders
    * def expectedPermissions = read('classpath:eureka/mod-users-keycloak/data/test-user-permissions.json')

  @Positive
  Scenario: get self user and fetch the same user by id
    # Resolve the current test user from the authenticated token.
    Given path 'users-keycloak', '_self'
    When method get
    Then status 200
    * def userId = response.user.id
    * match response.permissions.userId == userId
    * match response.permissions.permissions contains only expectedPermissions
    * match response.user.active == true
    * match response.user.id == userId
    * match response.user.type == 'patron'
    * match response.user.username == testUser.name

    # Verify the same user can be fetched by id.
    Given path 'users-keycloak', 'users', userId
    When method get
    Then status 200
    And match response.id == userId
    And match response.username == testUser.name

  @Positive
  Scenario: update user by id
    # Create a dedicated user so the update flow does not mutate shared test data.
    * def userId = uuid()
    * def createdUsername = 'users-update-' + nowMillis()
    Given path 'users-keycloak', 'users'
    And request
      """
      {
        "id": "#(userId)",
        "username": "#(createdUsername)",
        "active": true,
        "departments": [],
        "proxyFor": [],
        "type": "patron",
        "personal": {
          "firstName": "Karate",
          "lastName": "#('User ' + createdUsername)"
        }
      }
      """
    When method post
    Then status 201
    * def createdUser = response

    # Update a couple of fields and verify they are persisted.
    * def updatedUsername = createdUsername + '-updated'
    * set createdUser.username = updatedUsername
    * set createdUser.personal.lastName = 'Updated User'
    Given path 'users-keycloak', 'users', userId
    And request createdUser
    When method put
    Then status 204

    Given path 'users-keycloak', 'users', userId
    When method get
    Then status 200
    And match response.id == userId
    And match response.username == updatedUsername
    And match response.personal.lastName == 'Updated User'

  @Positive
  Scenario: delete user by id
    # Create a user.
    * def userId = uuid()
    * def username = 'users-delete-' + nowMillis()
    Given path 'users-keycloak', 'users'
    And request
      """
      {
        "id": "#(userId)",
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

    # Verify that user is creatd in mod-users
    * configure headers = testAdminHeaders
    Given path 'users', userId
    When method get
    Then status 200
    And match response.id == userId
    And match response.username == username

    # Delete the user and verify it is no longer returned by id.
    * configure headers = testUserHeaders
    Given path 'users-keycloak', 'users', userId
    When method delete
    Then status 204

    Given path 'users-keycloak', 'users', userId
    When method get
    Then status 404

    # Verify that user is deleted from mod-users also
    * configure headers = testAdminHeaders
    Given path 'users', userId
    When method get
    Then status 404
