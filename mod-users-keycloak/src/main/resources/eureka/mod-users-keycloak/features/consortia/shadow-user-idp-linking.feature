Feature: automatic IdP linking for central shadow users

  Background:
    * url baseUrl
    * configure cookies = null
    * configure readTimeout = 600000
    * configure retry = { count: 10, interval: 15000 }
    * configure afterScenario =
      """
      function(){
        if (!karate.get('centralTenantId') || !karate.get('memberTenantId')) {
          return;
        }
        karate.call('classpath:eureka/mod-users-keycloak/features/consortia/destroy-data.feature', {
          centralTenantId: karate.get('centralTenantId'),
          memberTenantId: karate.get('memberTenantId')
        });
      }
      """

    * table modules
      | name                    |
      | 'mod-users-keycloak'    |
      | 'mod-login-keycloak'    |
      | 'mod-roles-keycloak'    |
      | 'mod-notify'            |
      | 'mod-consortia'         |

    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def setupConsortium = read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia')
    * def setupTenantForConsortia = read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia')
    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def keycloakMaster = read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')

  @Positive
  Scenario: creating a staff user in member tenant automatically creates a shadow user in central tenant and links the member tenant IdP

    * def suffix = uuid().replace(/-/g, '').substring(0, 10)

    * def centralTenant = 'consortium' + suffix
    * def centralTenantId = uuid()

    * def memberTenant = 'member' + suffix
    * def memberTenantId = uuid()

    * def consortiumId = uuid()

    * def consortiaAdmin = { id: '#(uuid())', username: 'consortia_admin', password: 'consortia_admin_password', tenant: '#(centralTenant)' }
    * def memberAdmin = { id: '#(uuid())', username: 'member_admin', password: 'member_admin_password', tenant: '#(memberTenant)' }

    * def memberTenantIdpAlias = memberTenant + '-keycloak-oidc'

    # Create the central and member tenants.
    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(memberTenant)', tenantId: '#(memberTenantId)', user: '#(memberAdmin)' }

    # Register both tenants in the consortium.
    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * configure cookies = null
    * call setupConsortium { tenant: '#(centralTenant)' }
    * call setupTenantForConsortia { tenant: '#(centralTenant)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(memberTenant)', isCentral: false, code: 'MEM' }
    * configure headers = null
    * configure cookies = null

    # Create the member-tenant user.
    * def memberToken = karate.call('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken', { tenant: memberTenant }).okapitoken
    * def userId = uuid()
    * def memberUsername = 'MemberUser' + nowMillis()
    * def expectedFederatedUsername = memberUsername.toLowerCase()

    Given path 'users-keycloak', 'users'
    And headers { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-tenant': '#(memberTenant)', 'x-okapi-token': '#(memberToken)' }
    And request
      """
      {
        "id": "#(userId)",
        "username": "#(memberUsername)",
        "active": true,
        "type": "staff",
        "personal": {
          "firstName": "Member",
          "lastName": "User"
        }
      }
      """
    When method post
    Then status 201
    And match response.id == userId
    And match response.username == memberUsername

    # Wait for consortium processing to create the shadow user in central tenant with the same UUID.
    * def centralToken = karate.call('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken', { tenant: centralTenant }).okapitoken

    Given path 'users-keycloak', 'users', userId
    And headers { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(centralToken)' }
    And retry until responseStatus == 200 && response.type == 'shadow'
    When method get
    Then status 200
    And match response.id == userId
    And match response.type == 'shadow'
    * def originalTenantId = response.customFields.originalTenantId ? response.customFields.originalTenantId : response.customFields.originaltenantid
    * match originalTenantId == memberTenant

    # Verify that the shadow user resolves to the real member-tenant user when `overrideUser=true`
    Given path 'users-keycloak', '_self'
    And headers { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-token': '#(centralToken)', 'x-okapi-user-id': '#(userId)' }
    And param overrideUser = true
    When method get
    Then status 200
    And match response.originalTenantId == memberTenant
    And match response.user.id == userId
    And match response.user.username == memberUsername
    And match response.user.type == 'staff'

    # Verify that the shadow user is linked to the member tenant IdP in keycloak
    * def keycloakMasterLogin = call keycloakMaster
    * def keycloakMasterToken = keycloakMasterLogin.response.access_token

    Given url baseKeycloakUrl
    And path 'admin', 'realms', centralTenant, 'users'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And param q = 'user_id:' + userId
    And param briefRepresentation = true
    And retry until response.length == 1
    When method get
    Then status 200
    * def centralKeycloakUserId = response[0].id

    Given url baseKeycloakUrl
    And path 'admin', 'realms', centralTenant, 'users', centralKeycloakUserId, 'federated-identity'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And retry until karate.filter(response, x => x.identityProvider == memberTenantIdpAlias).length == 1
    When method get
    Then status 200
    * def providerLinks = karate.filter(response, x => x.identityProvider == memberTenantIdpAlias)
    * match providerLinks[0] contains
      """
      {
        "identityProvider": "#(memberTenantIdpAlias)",
        "userId": "#(expectedFederatedUsername)",
        "userName": "#(expectedFederatedUsername)"
      }
      """
