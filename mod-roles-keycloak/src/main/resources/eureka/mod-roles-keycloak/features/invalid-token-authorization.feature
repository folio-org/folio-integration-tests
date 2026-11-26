Feature: Sidecar authorization for invalid tokens

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = testUserHeaders

  @Negative
  Scenario: reading roles with a Keycloak-invalidated token returns unauthorized
    * def subjectUserName = 'invalid-token-user-' + nowMillis()
    * def subjectUserPassword = generatePassword(subjectUserName)
    * def subjectUserPermissions = ([{ name: 'roles.collection.get' }])
    * def createUserResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPassword: subjectUserPassword, userPermissions: subjectUserPermissions }))
    * def subjectUserId = createUserResult.userId
    * def subjectUser = { tenant: '#(testTenant)', name: '#(subjectUserName)', password: '#(subjectUserPassword)' }

    # Obtain a valid signed token without authorizing it for the target endpoint, which would populate the sidecar cache.
    * configure headers = null
    * def loginResult = call login subjectUser
    * def invalidatedToken = loginResult.okapitoken
    * configure headers = testUserHeaders

    # Invalidate the user session directly in Keycloak so the test does not depend on mod-login-keycloak logout behavior.
    * configure headers = null
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * configure headers = testUserHeaders
    * def keycloakMasterToken = keycloakResponse.response.access_token
    * url baseKeycloakUrl
    * configure headers = null
    Given path 'admin', 'realms', testTenant, 'users'
    And param username = subjectUserName
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method get
    Then status 200
    * def kcUserId = response[0].id

    Given path 'admin', 'realms', testTenant, 'users', kcUserId, 'logout'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method post
    Then status 204

    # The token still has a valid signature and expiry, so the sidecar reaches Keycloak UMA authorization.
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(invalidatedToken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'roles'
    When method get
    Then status 401
    And match response.total_records == 1
    And match response.errors == '#[1]'
    And match response.errors[0] contains { type: 'UnauthorizedException', code: 'authorization_error', message: 'Unauthorized' }

    # Remove the scenario-specific user.
    * configure headers = null
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'users-keycloak', 'users', subjectUserId
    When method delete
    Then status 204
