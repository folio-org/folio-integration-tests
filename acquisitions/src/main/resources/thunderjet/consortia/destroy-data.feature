Feature: Destroy data of consortia orders tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def deleteTenantAndEntitlement = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')


  Scenario: Destroy created ['central', 'university'] tenants
    * call deleteTenantAndEntitlement { tenantId: '#(universityTenantId)' }
    * call deleteTenantAndEntitlement { tenantId: '#(centralTenantId)' }
