Feature: tenant access to modules follows entitlement and revoke

  # Two tenants are entitled to the same application and mod-roles-keycloak is called through Kong as each of them.
  # After a revoke the revoked tenant must stop being served while the other one is still served.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def support = 'classpath:eureka/mgr-tenant-entitlements/util/entitlement-test-support.feature'
    * def flowSupport = 'classpath:eureka/mgr-tenant-entitlements/util/entitlement-flow-support.feature'
    * def appName = 'app-platform-minimal'
    * def setupA = callonce read(support + '@createEntitledTenant') { masterToken: '#(masterToken)', applicationName: '#(appName)', tenantPrefix: 'entroutea' }
    * def setupB = callonce read(support + '@createEntitledTenant') { masterToken: '#(masterToken)', applicationName: '#(appName)', tenantPrefix: 'entrouteb' }
    * def tenantAId = setupA.tenantId
    * def tenantAName = setupA.tenantName
    * def tenantBId = setupB.tenantId
    * def tenantBName = setupB.tenantName
    * def applicationId = setupA.applicationId
    * configure afterFeature = function() { karate.call(support + '@deleteEntitledTenant', { masterToken: masterToken, tenantId: tenantAId }); karate.call(support + '@deleteEntitledTenant', { masterToken: masterToken, tenantId: tenantBId }) }

  @Positive
  Scenario: tenants entitled to an application are served by its modules through the gateway
    * def tokenAResult = call read(support + '@getTenantToken') { tenantName: '#(tenantAName)' }
    * def tokenA = tokenAResult.accessToken
    * def tokenBResult = call read(support + '@getTenantToken') { tenantName: '#(tenantBName)' }
    * def tokenB = tokenBResult.accessToken
    * call read(support + '@awaitTenantAccess') { tenantName: '#(tenantAName)', token: '#(tokenA)', expectServed: true }
    * call read(support + '@awaitTenantAccess') { tenantName: '#(tenantBName)', token: '#(tokenB)', expectServed: true }

  @Positive
  Scenario: revoking one tenant stops serving it while another tenant keeps being served
    * def tokenAResult = call read(support + '@getTenantToken') { tenantName: '#(tenantAName)' }
    * def tokenA = tokenAResult.accessToken
    * def tokenBResult = call read(support + '@getTenantToken') { tenantName: '#(tenantBName)' }
    * def tokenB = tokenBResult.accessToken
    * call read(support + '@awaitTenantAccess') { tenantName: '#(tenantAName)', token: '#(tokenA)', expectServed: true }

    * def revoked = call read(flowSupport + '@submitRevoke') { tenantId: '#(tenantAId)', applicationId: '#(applicationId)', masterToken: '#(masterToken)' }
    * match revoked.flowResponse.status == 'finished'

    # The revoke took minutes and tokens are short-lived: fetch fresh ones so an expired token (401) cannot pass for
    # a disabled tenant. The revoked tenant is no longer served, while the other tenant still is.
    * def freshTokenAResult = call read(support + '@getTenantToken') { tenantName: '#(tenantAName)' }
    * def freshTokenA = freshTokenAResult.accessToken
    * def freshTokenBResult = call read(support + '@getTenantToken') { tenantName: '#(tenantBName)' }
    * def freshTokenB = freshTokenBResult.accessToken
    * call read(support + '@awaitTenantAccess') { tenantName: '#(tenantAName)', token: '#(freshTokenA)', expectServed: false }
    * call read(support + '@awaitTenantAccess') { tenantName: '#(tenantBName)', token: '#(freshTokenB)', expectServed: true }

    Given path 'entitlements'
    And param query = 'tenantId==' + tenantAId
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * match response.totalRecords == 0

    # Revoking the last remaining tenant of the feature stops serving it as well.
    * def revokedB = call read(flowSupport + '@submitRevoke') { tenantId: '#(tenantBId)', applicationId: '#(applicationId)', masterToken: '#(masterToken)' }
    * match revokedB.flowResponse.status == 'finished'
    * def lastTokenBResult = call read(support + '@getTenantToken') { tenantName: '#(tenantBName)' }
    * def lastTokenB = lastTokenBResult.accessToken
    * call read(support + '@awaitTenantAccess') { tenantName: '#(tenantBName)', token: '#(lastTokenB)', expectServed: false }
