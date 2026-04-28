Feature: list entitlements

  Background:
    * url baseUrl
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token

  @Positive
  Scenario: verify entitlements endpoint is reachable
    Given path 'entitlements'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.entitlements == '#array'
    And match response.totalRecords == '#number'
