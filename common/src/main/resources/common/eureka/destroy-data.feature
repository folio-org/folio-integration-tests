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
    * def applicationIds = karate.map(response.entitlements, x => x.applicationId)
    * def entitlementTemplate = read('classpath:common/eureka/samples/entitlement-entity.json')

    * eval
    """
    if (applicationIds.length > 0) {
      var response = karate.http('https://' + baseUrl) // Use your project's base URL variable
        .path('entitlements')
        .param('purge', true)
        .header('Authorization', 'Bearer ' + keycloakMasterToken)
        .body(entitlementTemplate)
        .delete();
      if (res.status != 200) {
        karate.fail('Delete entitlements has failed with status: ' + response.status);
      } else {
        karate.log('Deleted entitlements result:', response.status, 'count:', applicationIds.length);
      }
    } else {
      karate.log('No entitlements were found to delete');
    }
    """

  @deleteTenant
  Scenario: delete tenant
    * print "---delete tenant---"
    Given call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(testTenantId)' }

