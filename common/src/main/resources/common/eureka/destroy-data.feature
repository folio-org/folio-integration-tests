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
    * def KeycloakMasterToken = keycloakResponse.response.access_token
    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    And header Authorization = 'Bearer ' + KeycloakMasterToken
    When method GET
    * def totalAmount = response.totalRecords

    Given path 'entitlements'
    And param query = 'tenantId==' + testTenantId
    And param limit = totalAmount
    And header Authorization = 'Bearer ' + KeycloakMasterToken
    When method GET

    * def applicationIds = karate.map(response.entitlements, x => x.applicationId)
    * def entitlementTamplate = read('classpath:common/eureka/samples/entitlement-entity.json')
    Given path 'entitlements'
    And param purge = true
    And request entitlementTamplate
    And header Authorization = 'Bearer ' + KeycloakMasterToken
    When method DELETE
    Then status 200

  @deleteTenant
  Scenario: delete tenant
    * print "---delete tenant---"
    Given call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(testTenantId)' }

