Feature: seed data before Keycloak upgrade

  Background:
    * url baseUrl
    * configure cookies = null
    * configure retry = { count: 20, interval: 5000 }

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |

    * table userPermissions
      | name                                          |
      | 'login.item.post'                             |
      | 'auth.token.post'                             |
      | 'auth.refreshtoken.post'                      |
      | 'auth.token.sign.post'                        |
      | 'auth.token.refresh.post'                     |
      | 'users.item.get'                              |
      | 'users-keycloak.item.get'                     |
      | 'roles.item.get'                              |
      | 'roles.item.delete'                           |
      | 'roles.item.post'                             |
      | 'roles.collection.get'                        |
      | 'roles.users.item.get'                        |
      | 'roles.users.item.post'                       |
      | 'roles.users.collection.get'                  |
      | 'capabilities.item.get'                       |
      | 'capabilities.collection.get'                 |
      | 'role-capabilities.collection.post'           |
      | 'role-capabilities.collection.get'            |
      | 'permissions.users.item.get'                  |

  Scenario: create tenant, user credentials, consortia affiliation, and role data before upgrade
    # Seed central/member tenants and the consortia affiliation fixture used by post-upgrade verification.
    * call read('classpath:eureka/keycloak-upgrade/features/seed-consortia-before-upgrade.feature')

    # Create the test user, assign credentials, and grant the permissions needed for verification.
    * configure headers = null
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    * call read('classpath:common/eureka/setup-users.feature@createTestUser')
    * call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials')
    * call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')
    * def testUserId = karate.get('userId')

    # Verify the user can authenticate before the Keycloak upgrade.
    Given path 'authn', 'login'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    And request { username: '#(testUser.name)', password: '#(testUser.password)' }
    When method post
    Then status 201
    And match response.okapiToken == '#string'
    And match response.refreshToken == '#string'
    And match responseCookies contains { folioAccessToken: '#present', folioRefreshToken: '#present' }
    * def userToken = response.okapiToken
    * def jwt = decodeJwtPayload(userToken)
    And match jwt.sub == testUser.name
    And match jwt.user_id == testUserId

    # Resolve a known capability that will be attached to a role before the upgrade.
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(userToken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'capabilities'
    And param query = 'permission=="' + upgradeRolePermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def upgradeCapability = response.capabilities[0]

    # Create a durable role fixture that should survive the Keycloak upgrade.
    Given path 'roles'
    And request { name: '#(upgradeRoleName)', description: '#(upgradeRoleDescription)', type: 'REGULAR' }
    When method post
    Then status 201
    And match response.name == upgradeRoleName
    * def upgradeRoleId = response.id

    # Attach the capability to the role so post-upgrade access resolution can be verified.
    Given path 'roles', 'capabilities'
    And request { roleId: '#(upgradeRoleId)', capabilityIds: ['#(upgradeCapability.id)'] }
    When method post
    Then status 201
    And match response.roleCapabilities[*].capabilityId contains upgradeCapability.id

    # Assign the role to the test user before the upgrade.
    Given path 'roles', 'users'
    And request { userId: '#(testUserId)', roleIds: ['#(upgradeRoleId)'] }
    When method post
    Then status 201
    And match response.userRoles[*].roleId contains upgradeRoleId

    # Confirm effective permissions include the role capability before the upgrade.
    Given path 'permissions', 'users', testUserId
    When method get
    Then status 200
    And match response.permissions contains upgradeRolePermission

    # Verify module-to-module authentication can read the seeded user before the upgrade.
    * configure headers = null
    * configure cookies = null
    * call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    * def m2mToken = karate.get('accessToken')
    Given url baseUrl
    And path 'users-keycloak', 'users', testUserId
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(m2mToken)' }
    When method get
    Then status 200
    And match response.id == testUserId
    And match response.username == testUser.name
