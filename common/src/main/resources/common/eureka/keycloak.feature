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
