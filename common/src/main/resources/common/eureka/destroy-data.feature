Feature: destroy data for tenant

  Background:
    # never delete diku tenant that dev teams use for manual tests on https://folio-snapshot.dev.folio.org/ and other environments
    * match testUser.tenant != 'diku'

    * url baseUrl
    * configure readTimeout = 3000000
    * configure retry = { count: 5, interval: 5000 }


  Scenario: delete entitlement
    * print "---destroy entitlement---"
    * call read('classpath:common/eureka/application.feature@applicationsearch')
    * def entitlementTamplate = read('classpath:common/samples/entitlement-entity.json')
    Given path 'entitlements'
    And request entitlementTamplate
    When method DELETE
    Then status 200

  Scenario: delete tenant
    * print "---delete tenant---"
    Given call read('classpath:common/tenant.feature@delete') { tenantId: '#(testTenantId)' }

