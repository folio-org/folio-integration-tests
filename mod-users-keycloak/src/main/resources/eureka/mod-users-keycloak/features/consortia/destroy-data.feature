Feature: Destroy consortia test data

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }
    * def deleteTenantAndEntitlement = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')

  Scenario: Destroy central and member tenants
    * call deleteTenantAndEntitlement { tenantId: '#(memberTenantId)' }
    * call deleteTenantAndEntitlement { tenantId: '#(centralTenantId)' }
