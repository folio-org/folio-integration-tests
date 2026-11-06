Feature: users migration

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }

  @Positive
  Scenario: migrated user gets the current tenant in the Keycloak tenant_name attribute
    # Create a FOLIO user directly so it exists in mod-users but not in Keycloak.
    # A shadow user is migrated without any mod-permissions record.
    * configure headers = testAdminHeaders
    * def folioOnlyUserId = uuid()
    * def username = 'migration-user-' + nowMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(folioOnlyUserId)",
        "username": "#(username)",
        "active": true,
        "departments": [],
        "proxyFor": [],
        "type": "shadow",
        "personal": {
          "firstName": "Karate",
          "lastName": "#('User ' + username)"
        }
      }
      """
    When method post
    Then status 201

    # Run the migration and wait until the job is finished.
    * configure headers = testUserHeaders
    Given path 'users-keycloak', 'migrations'
    When method post
    Then status 201
    * def migrationId = response.id

    * configure retry = { count: 20, interval: 3000 }
    Given path 'users-keycloak', 'migrations', migrationId
    And retry until response.status == 'finished'
    When method get
    Then status 200

    # Keycloak is the only place where tenant_name can be read: no FOLIO endpoint returns it.
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token

    Given url baseKeycloakUrl
    And path 'admin', 'realms', testTenant, 'users'
    And param username = username
    And param exact = true
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method get
    Then status 200
    And match response == '#[1]'
    And match response[0].username == username
    And match response[0].attributes.user_id == ['#(folioOnlyUserId)']
    And match response[0].attributes.tenant_name == ['#(testTenant)']

    # Clean up: delete the migration job and the user (removes it from mod-users and Keycloak).
    * url baseUrl
    * configure headers = testUserHeaders
    Given path 'users-keycloak', 'migrations', migrationId
    When method delete
    Then status 204

    Given path 'users-keycloak', 'users', folioOnlyUserId
    When method delete
    Then status 204
