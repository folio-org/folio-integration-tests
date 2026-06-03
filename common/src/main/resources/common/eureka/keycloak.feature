Feature: keycloak

  Background:
    * url baseKeycloakUrl
    * configure cookies = null
    * configure headers = null

  @getKeycloakMasterToken
  Scenario: get master keycloak token
    Given path 'realms', 'master', 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = kcClientId
    And form field client_secret = kcClientSecret
    And form field scope = 'email openid'
    When method post
    Then status 200

  @getSidecarToken
  Scenario: get sidecar-module-access-client token (has elevated system permissions)
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token

    Given path 'admin', 'realms', testTenant, 'clients'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    Then status 200
    * def m2mClientId = 'sidecar-module-access-client'
    * def sidecarClientUUID = response.filter(x => x.clientId == m2mClientId)[0].id

    Given path 'admin', 'realms', testTenant, 'clients', sidecarClientUUID, 'client-secret'
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    Then status 200
    * def sidecarSecret = response.value

    Given path 'realms', testTenant, 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = m2mClientId
    And form field client_secret = sidecarSecret
    And form field scope = 'email openid'
    When method POST
    Then status 200
    * def sidecarToken = response.access_token

  @configureAccessTokenTime
  Scenario: adjust access token lifespan
    * def keycloakResponse = call read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def keycloakMasterToken = keycloakResponse.response.access_token

    * def tokenLifespan = karate.get('AccessTokenLifespance', 600)
    Given path 'admin', 'realms', testTenant
    And header Authorization = 'Bearer ' + keycloakMasterToken
    When method GET
    * def realmInfo = response
    * realmInfo.accessTokenLifespan = tokenLifespan

    Given path 'admin', 'realms', testTenant
    And header Authorization = 'Bearer ' + keycloakMasterToken
    And request realmInfo
    When method PUT
