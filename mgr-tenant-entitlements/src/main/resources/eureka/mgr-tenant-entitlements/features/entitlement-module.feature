Feature: module entitlements (entitlement-module)

  # GET /entitlements/modules/{moduleId} tells which tenants a module is entitled for. Two dedicated tenants are
  # entitled to the same application, so the shared module is reported for both.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def support = 'classpath:eureka/mgr-tenant-entitlements/util/entitlement-test-support.feature'
    * def appName = 'app-platform-minimal'
    * def setupOne = callonce read(support + '@createEntitledTenant') { masterToken: '#(masterToken)', applicationName: '#(appName)', tenantPrefix: 'entmodone' }
    * def setupTwo = callonce read(support + '@createEntitledTenant') { masterToken: '#(masterToken)', applicationName: '#(appName)', tenantPrefix: 'entmodtwo' }
    * def tenantOneId = setupOne.tenantId
    * def tenantTwoId = setupTwo.tenantId
    * def applicationId = setupOne.applicationId
    * configure afterFeature = function() { karate.call(support + '@deleteEntitledTenant', { masterToken: masterToken, tenantId: tenantOneId }); karate.call(support + '@deleteEntitledTenant', { masterToken: masterToken, tenantId: tenantTwoId }) }

  @Positive
  Scenario: a module shared by two entitled tenants is reported for both
    # The environment is shared, so other tenants may be entitled to the same module: assert on our tenants only.
    Given path 'entitlements'
    And param query = 'tenantId==' + tenantOneId
    And param includeModules = true
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.entitlements == '#[1]'
    * def moduleId = response.entitlements[0].modules[0]

    Given path 'entitlements', 'modules', moduleId
    And param limit = 500
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * assert response.totalRecords >= 2
    * assert response.entitlements.length == response.totalRecords
    * def tenantIds = karate.map(response.entitlements, e => e.tenantId)
    * match tenantIds contains '#(tenantOneId)'
    * match tenantIds contains '#(tenantTwoId)'
    * def ours = karate.filter(response.entitlements, e => e.tenantId == tenantOneId || e.tenantId == tenantTwoId)
    * match ours == '#[2]'
    * match each ours contains { applicationId: '#(applicationId)' }

  @Positive
  Scenario: module entitlements can be paged and are sorted by tenant
    Given path 'entitlements'
    And param query = 'tenantId==' + tenantOneId
    And param includeModules = true
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * def moduleId = response.entitlements[0].modules[0]

    Given path 'entitlements', 'modules', moduleId
    And param limit = 500
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * def total = response.totalRecords
    * assert total >= 2
    * def allTenantIds = karate.map(response.entitlements, e => e.tenantId)
    * def sortedTenantIds = karate.sort(allTenantIds, x => x)
    * match allTenantIds == sortedTenantIds

    Given path 'entitlements', 'modules', moduleId
    And param limit = 1
    And param offset = 0
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.totalRecords == total
    * match response.entitlements == '#[1]'
    * match response.entitlements[0].tenantId == allTenantIds[0]

    Given path 'entitlements', 'modules', moduleId
    And param limit = 1
    And param offset = 1
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.totalRecords == total
    * match response.entitlements == '#[1]'
    * match response.entitlements[0].tenantId == allTenantIds[1]
