@ignore
Feature: Keycloak admin API helpers to verify realm login configuration

  # Inputs (passed via call):
  #   realm - keycloak realm (tenant) name
  #   alias - identity provider alias (only for @GetIdentityProvider)
  #   flow  - browser flow alias to bind (only for @BindBrowserFlow)

  Background:
    * url baseKeycloakUrl
    * configure cookies = null
    * configure headers = null
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def kcAuth = 'Bearer ' + keycloakResponse.response.access_token

  @GetBrowserFlow
  Scenario: Get realm browser flow
    Given path 'admin', 'realms', realm
    And header Authorization = kcAuth
    When method GET
    Then status 200
    * def browserFlow = response.browserFlow

  @GetFlowAliases
  Scenario: Get realm authentication flow aliases
    Given path 'admin', 'realms', realm, 'authentication', 'flows'
    And header Authorization = kcAuth
    When method GET
    Then status 200
    * def flowAliases = karate.map(response, function(x){ return x.alias })

  @BindBrowserFlow
  Scenario: Bind browser flow to the realm
    Given path 'admin', 'realms', realm
    And header Authorization = kcAuth
    When method GET
    Then status 200
    * def realmRep = response
    * realmRep.browserFlow = flow

    Given path 'admin', 'realms', realm
    And header Authorization = kcAuth
    And request realmRep
    When method PUT
    Then status 204

  @GetIdentityProvider
  Scenario: Get identity provider of the realm
    Given path 'admin', 'realms', realm, 'identity-provider', 'instances', alias
    And header Authorization = kcAuth
    When method GET
    * def idpStatus = responseStatus
    * def idp = response
