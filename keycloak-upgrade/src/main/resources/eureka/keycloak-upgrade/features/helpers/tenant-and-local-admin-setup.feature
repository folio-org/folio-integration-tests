Feature: Keycloak upgrade consortia tenant setup

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * configure retry = { count: 40, interval: 15000 }
    * def queryParam = function(field, values) { return '(' + field + '==(' + values.map(x => '"' + x + '"').join(' or ') + '))' }

    * table requiredModulesForConsortia
      | name                     |
      | 'mod-tags'               |
      | 'mod-users-bl'           |
      | 'mod-password-validator' |
      | 'folio_users'            |
      | 'mod-consortia-keycloak' |

    * table requiredCapabilitiesForConsortia
      | name                                                  |
      | 'consortia.consortia-configuration.item.post'         |
      | 'consortia.consortia-configuration.item.delete'       |
      | 'consortia.consortium.item.post'                      |
      | 'consortia.consortium.item.put'                       |
      | 'consortia.consortium.item.get'                       |
      | 'consortia.create-primary-affiliations.item.post'     |
      | 'consortia.custom-login.item.post'                    |
      | 'consortia.identity-provider.item.post'               |
      | 'consortia.identity-provider.item.delete'             |
      | 'consortia.inventory.local.sharing-instances.execute' |
      | 'consortia.inventory.update-ownership.item.post'      |
      | 'consortia.publications.item.post'                    |
      | 'consortia.publications.item.delete'                  |
      | 'consortia.publications.item.get'                     |
      | 'consortia.publications-results.item.get'             |
      | 'consortia.sharing-instances.collection.get'          |
      | 'consortia.sharing-instances.item.post'               |
      | 'consortia.sharing-instances.item.get'                |
      | 'consortia.sharing-policies.item.post'                |
      | 'consortia.sharing-policies.item.delete'              |
      | 'consortia.sharing-roles-all.item.post'               |
      | 'consortia.sharing-roles-all.item.delete'             |
      | 'consortia.sharing-roles-capabilities.item.post'      |
      | 'consortia.sharing-roles-capabilities.item.delete'    |
      | 'consortia.sharing-roles-capability-sets.item.post'   |
      | 'consortia.sharing-roles-capability-sets.item.delete' |
      | 'consortia.sharing-roles.item.post'                   |
      | 'consortia.sharing-roles.item.delete'                 |
      | 'consortia.sharing-settings.item.post'                |
      | 'consortia.sharing-settings.item.delete'              |
      | 'consortia.sync-primary-affiliations.item.post'       |
      | 'consortia.tenants.item.post'                         |
      | 'consortia.tenants.item.delete'                       |
      | 'consortia.tenants.item.put'                          |
      | 'consortia.tenants.item.get'                          |
      | 'consortia.user-tenants.collection.get'               |
      | 'consortia.user-tenants.item.post'                    |
      | 'consortia.user-tenants.item.delete'                  |
      | 'consortia.user-tenants.item.get'                     |
      | 'tags.collection.get'                                 |
      | 'tags.item.post'                                      |
      | 'tags.item.delete'                                    |
      | 'tags.item.put'                                       |
      | 'tags.item.get'                                       |

  @SetupTenant
  Scenario: create tenant, enable applications, create admin, and assign capabilities
    * def description = 'tenant_description'
    * def oldModules = modules
    * def modules = modules.concat(requiredModulesForConsortia)
    * def oldPermissions = (typeof userPermissions !== 'undefined') ? userPermissions : []
    * def userPermissions = requiredCapabilitiesForConsortia.concat(oldPermissions)

    # Create the tenant and enable required applications.
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenant)' }
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@InstallApplications') { tenantId: '#(tenantId)', modules: '#(modules)' }

    # Create a local admin and grant the capabilities needed by consortia setup and verification.
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@PostAdmin') { tenant: '#(tenant)', user: '#(user)' }
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@PutCaps') { tenant: '#(tenant)', user: '#(user)', userPermissions: '#(userPermissions)' }

    * def userPermissions = oldPermissions
    * def modules = oldModules

  @InstallApplications
  Scenario: enable applications in tenant
    * def testTenantId = tenantId
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    * call read('classpath:common/eureka/application.feature@applicationSearch') { modules: '#(modules)' }
    * def entitlementTemplate = read('classpath:common/eureka/samples/entitlement-entity.json')
    * def loadReferenceRecords = karate.get('tenantParams', { loadReferenceData: false }).loadReferenceData
    * def centralTenantIdValue = karate.get('centralTenantId')
    * def tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords + (centralTenantIdValue ? ',centralTenantId=' + centralTenantIdValue : '')

    Given path 'entitlements'
    And param tenantParameters = tenantParameters
    And param async = true
    And param purgeOnRollback = false
    And request entitlementTemplate
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And header x-okapi-token = keycloakMasterToken
    When method POST
    * def flowId = response.flowId

    * configure retry = { count: 40, interval: 30000 }
    Given path 'entitlement-flows', flowId
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And retry until response.status == 'finished' || response.status == 'cancelled' || response.status == 'cancellation_failed' || response.status == 'failed'
    When method GET
    * def failCondition = response.status
    * if (failCondition == 'cancelled' || failCondition == 'cancellation_failed' || failCondition == 'failed') karate.fail('Entitlement creation failed.')

  @SetupConsortia
  Scenario: create consortium record
    * def consortiumName = tenant + 'name for test'

    Given path 'consortia'
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    When method POST
    * def createStatus = responseStatus
    * if (createStatus != 201 && createStatus != 409) karate.fail('Failed to create consortium. Status: ' + createStatus)
    * def consortiumRecord = createStatus == 201 ? response : { id: consortiumId, name: consortiumName }
    And match consortiumRecord == { id: '#(consortiumId)', name: '#(consortiumName)' }

  @SetupTenantForConsortia
  Scenario: create tenant for consortium
    * def name = tenant + ' tenants name'

    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    And request { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)' }
    When method POST
    * def createStatus = responseStatus
    * if (createStatus != 201 && createStatus != 409) karate.fail('Failed to create consortium tenant ' + tenant + '. Status: ' + createStatus)
    * def tenantRecord = createStatus == 201 ? response : karate.call('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@GetTenantForConsortia', { tenant: tenant }).response
    And match tenantRecord contains { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)', isDeleted: false }

    # Wait until mod-consortia finishes setup for both newly-created and already-existing tenants.
    * call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@WaitTenantConsortiaSetup') { tenant: '#(tenant)' }

  @GetTenantForConsortia
  Scenario: get consortium tenant record
    Given path 'consortia', consortiumId, 'tenants', tenant
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    When method GET
    Then status 200

  @WaitTenantConsortiaSetup
  Scenario: wait for consortium tenant setup to complete
    Given path 'consortia', consortiumId, 'tenants', tenant
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == tenant

  @getAuthorizationToken
  Scenario: get module token for tenant
    * configure headers = null
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    * def m2mClientId = karate.get('m2mClientId', 'sidecar-module-access-client')

    Given url baseKeycloakUrl
    And path 'admin', 'realms', tenant, 'clients'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    Then status 200
    * def client = response.filter(x => x.clientId == m2mClientId)[0]
    * if (client == null) karate.fail('Missing Keycloak client ' + m2mClientId + ' in tenant ' + tenant)
    * def clientId = client.id

    Given url baseKeycloakUrl
    And path 'admin', 'realms', tenant, 'clients', clientId, 'client-secret'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    Then status 200
    * def sidecarSecret = response.value

    * configure headers = null
    Given url baseKeycloakUrl
    And path 'realms', tenant, 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = m2mClientId
    And form field client_secret = sidecarSecret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * def okapitoken = response.access_token
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

  @PostAdmin
  Scenario: create an admin with credentials
    * def tokenResult = call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@getAuthorizationToken') { tenant: '#(tenant)' }
    * def okapitoken = tokenResult.okapitoken

    Given path 'users'
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And request
      """
      {
        id: '#(user.id)',
        username: '#(user.username)',
        active: true,
        barcode: '#(uuid())',
        externalSystemId: '#(uuid())',
        personal: {
          email: 'admin@gmail.com',
          firstName: 'admin first name',
          lastName: 'admin last name',
          preferredContactTypeId: '002',
          phone: '#(user.phone)',
          mobilePhone: '#(user.mobilePhone)'
        }
      }
      """
    When method POST
    Then status 201

    Given path 'authn', 'credentials'
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And request { username: '#(user.username)', password: '#(user.password)', userId: '#(user.id)' }
    When method POST
    Then status 201

  @PostUser
  Scenario: create a user with credentials
    * def tokenResult = call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@getAuthorizationToken') { tenant: '#(tenant)' }
    * def okapitoken = tokenResult.okapitoken

    Given path 'users'
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And request
      """
      {
        id: '#(user.id)',
        username: '#(user.username)',
        active: true,
        barcode: '#(uuid())',
        externalSystemId: '#(uuid())',
        type: '#(user.type)',
        personal: {
          email: 'user@gmail.com',
          firstName: 'user first name',
          lastName: 'user last name',
          preferredContactTypeId: '002',
          phone: '#(user.phone)',
          mobilePhone: '#(user.mobilePhone)'
        }
      }
      """
    When method POST
    Then status 201

    Given path 'authn', 'credentials'
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And request { username: '#(user.username)', password: '#(user.password)', userId: '#(user.id)' }
    When method POST
    Then status 201

  @PutCaps
  Scenario: assign capabilities to user
    * def tokenResult = call read('classpath:eureka/keycloak-upgrade/features/helpers/tenant-and-local-admin-setup.feature@getAuthorizationToken') { tenant: '#(tenant)' }
    * def okapitoken = tokenResult.okapitoken
    * def permissions = $userPermissions[*].name

    Given path 'capabilities'
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And param query = queryParam('permission', permissions)
    And param limit = permissions.length
    And retry until response.capabilities && response.capabilities.length == permissions.length
    When method GET
    Then status 200
    * def capabilityIds = karate.map(response.capabilities, x => x.id)
    * if (capabilityIds.length != permissions.length) karate.fail('Not all capabilities found. Expected ' + permissions.length + ', found ' + capabilityIds.length)

    Given path 'users', 'capabilities'
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And request { userId: '#(user.id)', capabilityIds: '#(capabilityIds)' }
    When method POST
    Then status 201
