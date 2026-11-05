Feature: destroy Keycloak upgrade test data

  Background:
    * url baseUrl
    * configure readTimeout = 3000000

  Scenario: delete upgrade test tenant
    * call read('classpath:common/eureka/destroy-data.feature') { testTenantId: '#(testTenantId)' }
