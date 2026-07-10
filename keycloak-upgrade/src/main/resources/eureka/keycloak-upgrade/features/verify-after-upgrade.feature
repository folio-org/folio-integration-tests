Feature: verify data after Keycloak upgrade

  Background:
    * url baseUrl
    * configure cookies = null
    * configure retry = { count: 20, interval: 5000 }

  Scenario: verify pre-upgrade tenant data through FOLIO APIs after restart
    # Verify the pre-upgrade user can still authenticate through the FOLIO login API.
    * configure cookies = null
    Given path 'authn', 'login'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    And request { username: '#(testUser.name)', password: '#(testUser.password)' }
    When method post
    Then status 201
    And match response contains { okapiToken: '#string', refreshToken: '#string' }
    And match responseCookies contains { folioAccessToken: '#present', folioRefreshToken: '#present' }
    * def loginToken = response.okapiToken
    * def refreshToken = responseCookies.folioRefreshToken.value
    * def jwt = decodeJwtPayload(loginToken)
    And match jwt.sub == testUser.name
    And match jwt.user_id == '#uuid'
    And match jwt.azp == '#string'
    * def testUserId = jwt.user_id

    # Verify cross-module access resolution through sidecars:
    # users-keycloak returns user data and effective permissions resolved from roles-keycloak.
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(loginToken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'users-keycloak', '_self'
    When method get
    Then status 200
    And match response.user.id == testUserId
    And match response.user.username == testUser.name
    And match response.permissions.permissions contains upgradeRolePermission

    # Verify the pre-upgrade user can still be read by id.
    Given path 'users-keycloak', 'users', testUserId
    When method get
    Then status 200
    And match response.id == testUserId
    And match response.username == testUser.name

    # Verify the pre-upgrade role fixture still exists.
    Given path 'roles'
    And param query = 'name=="' + upgradeRoleName + '"'
    When method get
    Then status 200
    And match response.roles == '#[1]'
    * def upgradeRoleId = response.roles[0].id

    # Verify the role still has the capability assigned before the upgrade.
    Given path 'roles', upgradeRoleId, 'capabilities'
    When method get
    Then status 200
    And match response.capabilities[*].permission contains upgradeRolePermission

    # Verify effective permissions still include access contributed by the pre-upgrade role.
    Given path 'permissions', 'users', testUserId
    When method get
    Then status 200
    And match response.permissions contains upgradeRolePermission

    # Verify refresh-token rotation still works after the upgrade.
    * configure headers = null
    * configure cookies = null
    Given url baseUrl
    And path 'authn', 'refresh'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = refreshToken
    When method post
    Then status 201
    And match responseCookies.folioAccessToken == '#present'
    And match responseCookies.folioRefreshToken == '#present'
    * def refreshedToken = responseCookies.folioAccessToken.value
    * def refreshedJwt = decodeJwtPayload(refreshedToken)
    And match refreshedJwt.sub == testUser.name
    And match refreshedJwt.user_id == testUserId

    # Verify the refreshed access token can be used against FOLIO APIs.
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(refreshedToken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'users-keycloak', 'users', testUserId
    When method get
    Then status 200
    And match response.username == testUser.name

    # Verify tenant metadata can still be updated through the FOLIO tenant manager API.
    * configure headers = null
    * configure cookies = null
    # Use the manager token only to authorize the FOLIO tenant manager request.
    * def managerTokenResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def managerToken = managerTokenResponse.response.access_token

    # Read the existing tenant before updating it.
    Given path 'tenants', testTenantId
    And header Authorization = 'Bearer ' + managerToken
    When method get
    Then status 200
    And match response.id == testTenantId
    And match response.name == testTenant
    * def tenant = response
    * def updatedDescription = 'Updated by Keycloak upgrade IT ' + uuid()
    * set tenant.description = updatedDescription

    # Update only the tenant description and verify the update response.
    Given path 'tenants', testTenantId
    And header Authorization = 'Bearer ' + managerToken
    And header Content-Type = 'application/json'
    And request tenant
    When method put
    Then status 200
    And match response.description == updatedDescription

    # Read the tenant again to confirm the description was persisted.
    Given path 'tenants', testTenantId
    And header Authorization = 'Bearer ' + managerToken
    When method get
    Then status 200
    And match response.description == updatedDescription
