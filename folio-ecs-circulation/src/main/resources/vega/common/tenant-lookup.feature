@ignore
Feature: Tenant lookup helpers

  Background:
    * url baseUrl
    * configure retry = { count: 5, interval: 5000 }
    * configure readTimeout = 300000

  @getIdByName
  Scenario: Resolve a tenant UUID by its name
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token
    Given path 'tenants'
    And param query = 'name==' + __arg.tenantName
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    * def tenantId = responseStatus == 200 && response.totalRecords > 0 ? response.tenants[0].id : null
