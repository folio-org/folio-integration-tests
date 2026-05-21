Feature: Destroy folio-ecs-circulation ecs-requests tenants

  Background:
    * url baseUrl
    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }
    * call login admin

  Scenario: Destroy created ['consortium', 'university'] tenants for ecs-requests tests
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(centralTenant)', tenantId: '#(centralTenantId)' }
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)' }
