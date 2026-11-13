@ignore
Feature: shared setup and teardown helpers for entitlement read/validation features

  # Reuses the submit/wait helpers of entitle-module-without-provides.feature.
  # Every caller gets a dedicated tenant, so features never depend on entitlements created by other features.

  @ignore @createEntitledTenant
  Scenario: create a tenant and entitle it to an application, waiting for the flow to finish
    * def masterToken = __arg.masterToken
    * def appName = __arg.applicationName
    * def tenantId = uuid()
    * def tenantName = __arg.tenantPrefix + nowMillis()
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    Given url baseUrl
    And path 'applications'
    And param query = '(name=="' + appName + '")'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.applicationDescriptors != '#[0]'
    * def applicationId = response.applicationDescriptors[0].id

    * def entitled = call read('classpath:eureka/mgr-tenant-entitlements/util/entitlement-flow-support.feature@submitEntitle') { tenantId: '#(tenantId)', applicationId: '#(applicationId)', masterToken: '#(masterToken)' }
    * match entitled.flowResponse.status == 'finished'

  @ignore @entitleApplication
  Scenario: entitle an already created tenant to one more application by name
    * def masterToken = __arg.masterToken
    Given url baseUrl
    And path 'applications'
    And param query = '(name=="' + __arg.applicationName + '")'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.applicationDescriptors != '#[0]'
    * def applicationId = response.applicationDescriptors[0].id

    * def entitled = call read('classpath:eureka/mgr-tenant-entitlements/util/entitlement-flow-support.feature@submitEntitle') { tenantId: '#(__arg.tenantId)', applicationId: '#(applicationId)', masterToken: '#(masterToken)' }
    * match entitled.flowResponse.status == 'finished'

  @ignore @deleteEntitledTenant
  Scenario: revoke every application the tenant is entitled to with purge and delete the tenant
    * def masterToken = __arg.masterToken
    Given url baseUrl
    And path 'entitlements'
    And param query = 'tenantId==' + __arg.tenantId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    # app-platform-minimal is revoked last because the other applications depend on it.
    * def allIds = karate.map(response.entitlements, e => e.applicationId)
    * def applicationIds = karate.filter(allIds, id => !id.startsWith('app-platform-minimal')).concat(karate.filter(allIds, id => id.startsWith('app-platform-minimal')))
    * def revokeOne = function(appId) { karate.call('classpath:eureka/mgr-tenant-entitlements/util/entitlement-flow-support.feature@submitRevoke', { tenantId: __arg.tenantId, applicationId: appId, masterToken: masterToken }) }
    * karate.forEach(applicationIds, revokeOne)
    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(__arg.tenantId)' }

  @ignore @findApplicationId
  Scenario: find the id of an application by name
    * def masterToken = __arg.masterToken
    Given url baseUrl
    And path 'applications'
    And param query = '(name=="' + __arg.applicationName + '")'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.applicationDescriptors != '#[0]'
    * def applicationId = response.applicationDescriptors[0].id

  @ignore @validateEntitlement
  Scenario: call POST /entitlements/validate and check the status code
    # Args: masterToken, type (entitle|upgrade|revoke|state), tenantId, applications,
    #       validator (optional: all validators run when absent), expectedStatus (default 204).
    # Returns the response so callers can assert on error bodies.
    * def expectedStatus = __arg.expectedStatus ? __arg.expectedStatus : 204
    * def validator = __arg.validator ? __arg.validator : null
    Given url baseUrl
    And path 'entitlements', 'validate'
    And param entitlementRequestType = __arg.type
    And param validator = validator
    And header Authorization = 'Bearer ' + __arg.masterToken
    And header X-Okapi-Token = __arg.masterToken
    And request { tenantId: '#(__arg.tenantId)', applications: '#(__arg.applications)' }
    When method post
    Then assert responseStatus == expectedStatus

  @ignore @getTenantToken
  Scenario: get an access token of the tenant's module-access client
    # Args: tenantName. Returns accessToken. Mirrors setup-users.feature@getAuthorizationToken for an arbitrary tenant.
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    * def m2mClientId = karate.get('m2mClientId', 'sidecar-module-access-client')

    Given url baseKeycloakUrl
    And path 'admin', 'realms', __arg.tenantName, 'clients'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method get
    Then status 200
    * def clientUuid = karate.filter(response, x => x.clientId == m2mClientId)[0].id

    Given url baseKeycloakUrl
    And path 'admin', 'realms', __arg.tenantName, 'clients', clientUuid, 'client-secret'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method get
    Then status 200
    * def clientSecret = response.value

    Given url baseKeycloakUrl
    And path 'realms', __arg.tenantName, 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = m2mClientId
    And form field client_secret = clientSecret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * def accessToken = response.access_token

  @ignore @awaitTenantAccess
  Scenario: call a real module (mod-roles-keycloak GET /capabilities) through the gateway as the tenant until it is served or blocked
    # Args: tenantName, token, expectServed (true = HTTP 200 expected, false = anything else expected).
    # The sidecars learn about entitlement changes from Kafka, so the result is polled instead of checked once.
    * def expectServed = __arg.expectServed
    * configure retry = { count: 12, interval: 5000 }
    Given url baseUrl
    And path 'capabilities'
    And param limit = 1
    And header x-okapi-tenant = __arg.tenantName
    And header x-okapi-token = __arg.token
    And retry until (responseStatus == 200) == expectServed
    When method get
    * def status = responseStatus
    # The status and body show which layer answered (Kong: no route matched, sidecar: tenant not enabled).
    * karate.log('tenant access probe: tenant =', __arg.tenantName, 'expectServed =', expectServed, 'status =', status, 'body =', response)
    Then assert (status == 200) == expectServed
