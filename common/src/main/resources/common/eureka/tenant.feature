Feature: Tenants

  Background:
    * url baseUrl
    * configure retry = { count: 2, interval: 5000 }
    * configure readTimeout = 3000000

  @create
  Scenario: createTenant
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def KeycloakMasterToken = keycloakResponse.response.access_token
    Given path 'tenants'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And request { id: '#(__arg.tenantId)', name: '#(__arg.tenantName)', description: 'Tenant for test purpose' }
    And header Authorization = 'Bearer ' + KeycloakMasterToken
    When method POST
    Then status 201

  @delete
  Scenario: deleteTenant
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def KeycloakMasterToken = keycloakResponse.response.access_token
    Given path 'tenants', __arg.tenantId
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header Authorization = 'Bearer ' + KeycloakMasterToken
    When method DELETE
    Then status 204
