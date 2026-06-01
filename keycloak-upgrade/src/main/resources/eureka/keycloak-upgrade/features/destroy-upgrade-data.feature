Feature: destroy Keycloak upgrade test data

  Background:
    * url baseUrl
    * configure readTimeout = 3000000

  Scenario: delete member and central tenants
    # Delete the member tenant first because it depends on the central consortium tenant.
    * call read('classpath:common/eureka/destroy-data.feature') { testTenantId: '#(memberTenantId)' }

    # Delete the central tenant last.
    * call read('classpath:common/eureka/destroy-data.feature') { testTenantId: '#(centralTenantId)' }
