Feature: list tenants

  Background:
    * url baseUrl
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token

  @Positive
  Scenario: verify tenants endpoint is reachable
    Given path 'tenants'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.tenants == '#array'
    And match response.totalRecords == '#number'
