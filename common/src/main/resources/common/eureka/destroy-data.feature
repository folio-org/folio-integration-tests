Feature: destroy data for tenant

  Background:
    # never delete diku tenant that dev teams use for manual tests on https://folio-snapshot.dev.folio.org/ and other environments
    * match testUser.tenant != 'diku'

    * url baseUrl
    * configure readTimeout = 3000000
    * configure retry = { count: 5, interval: 5000 }

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

    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    And param limit = totalAmount
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    * def applicationIds = response || response.entitlements ? karate.map(response.entitlements, x => x.applicationId) : []
    * if (applicationIds && applicationIds.length > 0) karate.call('classpath:common/eureka/destroy-data.feature@performDeleteEntitlement', { testTenantId: testTenantId, applicationIds: applicationIds })

  # This is needed to make DELETE /entitlements idempotent because it's not at the moment and fails on empty applicationIds
  @ignore
  @performDeleteEntitlement
  Scenario: perform delete entitlement
    * print "---perform delete entitlement---"
    * def entitlementTemplate = read('classpath:common/eureka/samples/entitlement-entity.json')
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    Given path 'entitlements'
    And param purge = true
    And request entitlementTemplate
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And retry until responseStatus == 200
    When method DELETE
    Then status 200

  @deleteTenant
  Scenario: delete tenant
    * print "---delete tenant---"
    Given call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(testTenantId)' }



