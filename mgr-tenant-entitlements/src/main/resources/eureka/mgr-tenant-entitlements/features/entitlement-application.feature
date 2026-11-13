Feature: entitled applications of a tenant (entitlement-application)

  # GET /entitlements/{tenantName}/applications is what the sidecar bootstrap and mgr-applications consume to learn
  # which application descriptors a tenant is entitled to. The data comes from the entitlement DB (mgr-tenant-entitlements),
  # the tenant lookup (mgr-tenants) and the descriptors (mgr-applications).

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def support = 'classpath:eureka/mgr-tenant-entitlements/util/entitlement-test-support.feature'
    * def firstApp = 'app-platform-minimal'
    * def secondApp = 'app-licenses'
    * def setup = callonce read(support + '@createEntitledTenant') { masterToken: '#(masterToken)', applicationName: '#(firstApp)', tenantPrefix: 'entapp' }
    * def tenantId = setup.tenantId
    * def tenantName = setup.tenantName
    * def firstAppId = setup.applicationId
    * configure afterFeature = function() { karate.call(support + '@deleteEntitledTenant', { masterToken: masterToken, tenantId: tenantId }) }
    * def moduleIdsOf = function(descriptor) { return karate.map(descriptor.modules, m => m.id ? m.id : m.name + '-' + m.version) }

  @Positive
  Scenario: list application descriptors of a tenant entitled to one application
    Given path 'entitlements', tenantName, 'applications'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And header X-Okapi-Tenant = tenantName
    When method get
    Then status 200
    * match response.totalRecords == 1
    * match response.applicationDescriptors == '#[1]'
    * match response.applicationDescriptors[0].id == firstAppId
    * match response.applicationDescriptors[0].modules == '#[_ > 0]'

  @Positive
  Scenario: application descriptor modules match the module entitlements of the tenant
    Given path 'entitlements'
    And param query = 'tenantId==' + tenantId
    And param includeModules = true
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.entitlements == '#[1]'
    * def entitledModuleIds = response.entitlements[0].modules

    Given path 'entitlements', tenantName, 'applications'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And header X-Okapi-Tenant = tenantName
    When method get
    Then status 200
    * def descriptorModuleIds = moduleIdsOf(response.applicationDescriptors[0])
    * match descriptorModuleIds contains only '#(entitledModuleIds)'

  @Positive
  Scenario: a newly entitled application is returned immediately and the result can be paged
    * call read(support + '@entitleApplication') { masterToken: '#(masterToken)', tenantId: '#(tenantId)', applicationName: '#(secondApp)' }

    Given path 'entitlements', tenantName, 'applications'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And header X-Okapi-Tenant = tenantName
    When method get
    Then status 200
    * match response.totalRecords == 2
    * def names = karate.map(response.applicationDescriptors, d => d.name)
    * match names contains only ['#(firstApp)', '#(secondApp)']
    * def allIds = karate.map(response.applicationDescriptors, d => d.id)

    Given path 'entitlements', tenantName, 'applications'
    And param limit = 1
    And param offset = 0
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And header X-Okapi-Tenant = tenantName
    When method get
    Then status 200
    * match response.totalRecords == 2
    * match response.applicationDescriptors == '#[1]'
    * def pageOneId = response.applicationDescriptors[0].id

    Given path 'entitlements', tenantName, 'applications'
    And param limit = 1
    And param offset = 1
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And header X-Okapi-Tenant = tenantName
    When method get
    Then status 200
    * match response.applicationDescriptors == '#[1]'
    * def pageTwoId = response.applicationDescriptors[0].id
    * def pagedIds = ['#(pageOneId)', '#(pageTwoId)']
    * match pagedIds contains only '#(allIds)'
