Feature: Destroy consortia
  Background:
    * url baseUrl
    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }
    * call login admin

  Scenario: Destroy created ['central', 'university', 'college'] tenants
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenant') { tenantName: '#(centralTenant)', tenantId: '#(centralTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenant') { tenantName: '#(collegeTenant)', tenantId: '#(collegeTenantId)'}
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenant') { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)'}