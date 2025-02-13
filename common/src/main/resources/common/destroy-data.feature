Feature: destroy data for tenant

  Background:
    # never delete diku tenant that dev teams use for manual tests on https://folio-snapshot.dev.folio.org/ and other environments
    * match testUser.tenant != 'diku'

    * url baseUrl
    * configure readTimeout = 3000000
    * configure retry = { count: 5, interval: 5000 }
    * call login admin
    * call read('classpath:common/application.feature@applicationsearch')

#  Scenario: finishScenario
#    * print ' --*******************************-- starting destroy-data.feature --*******************************-- '
#    * def actual = { name: 'viktor' }
#    * match actual.name == 'viktor'
#    * print ' --*******************************-- ending destroy-data.feature --*******************************-- '



#  Scenario: purge all modules for tenant
#
#    Given path '_/proxy/tenants', testUser.tenant, 'modules'
#    And header Content-Type = 'application/json'
#    And header Accept = 'application/json'
#    And header x-okapi-token = okapitoken
#    When method GET
#    Then status 200
#
#    * set response $[*].action = 'disable'
#
#    Given path '_/proxy/tenants', testUser.tenant, 'install'
#    And param purge = true
#    And header Content-Type = 'application/json'
#    And header Accept = 'application/json'
#    And header x-okapi-token = okapitoken
#    And retry until responseStatus == 200
#    And request response
#    When method POST
#    Then status 200


#  Scenario: delete entitlement
#    * def applicationOfAllFolioModuleId = karate.get('allFolioModulesApplicationId')
#    * def entitlementTamplate = read('classpath:common/samples/entitlement-entity.json')
#    Given path 'entitlements'
#    And request entitlementTamplate
#    When method DELETE
#    Then status 200

  Scenario: delete tenant
    Given call read('classpath:common/tenant.feature@delete') { tenantId: '#(testTenantId)' }

