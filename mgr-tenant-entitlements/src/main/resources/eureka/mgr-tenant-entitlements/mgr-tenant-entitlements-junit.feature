Feature: mgr-tenant-entitlements integration tests setup

  Background:
    * url baseUrl

  Scenario: get master token for manager tests
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token

  Scenario: create tenant for testing
    * call read('classpath:common/eureka/setup-users.feature@createTenant')
