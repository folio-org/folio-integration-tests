Feature: Destroy data of consortia orders tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }

    * def deleteTenantAndEntitlement = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')


  Scenario: Destroy Central and University tenants
    * call deleteTenantAndEntitlement { tenantId: '#(universityTenantUuid)' }
    * call deleteTenantAndEntitlement { tenantId: '#(centralTenantUuid)' }
