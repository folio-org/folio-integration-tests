Feature: destroy data for tenant

  Background:
    # never delete diku tenant that dev teams use for manual tests on https://folio-snapshot.dev.folio.org/ and other environments
    * match testUser.tenant != 'diku'

    * url baseUrl
    * configure readTimeout = 3000000
    # max polling time: ~10 minutes (40 retries x 15s)
    * configure retry = { count: 40, interval: 15000 }

  @destroyEntitlement
  Scenario: delete entitlement
    * print "---destroy entitlement---"
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    * def totalAmount = response.totalRecords
    * if (totalAmount < 1) karate.abort()

    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    And param limit = totalAmount
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    * def applicationIds = karate.map(response.entitlements, x => x.applicationId)
    * if (applicationIds.length < 1) karate.abort()
    * def entitlementTemplate = read('classpath:common/eureka/samples/entitlement-entity.json')

    Given path 'entitlements'
    And param purge = true
    And param async = true
    And request entitlementTemplate
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And header X-Okapi-Token = keycloakMasterToken
    When method DELETE
    Then status 200
    * def flowId = response.flowId

    Given path 'entitlement-flows', flowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + keycloakMasterToken
    * retry until response.status == "finished" || response.status == "cancelled" || response.status == "cancellation_failed" || response.status == "failed"
    When method GET

  @deleteTenant
  Scenario: delete tenant
    * print "---delete tenant---"
    Given call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(testTenantId)' }
