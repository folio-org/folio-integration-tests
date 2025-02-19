Feature:
  Background:
    * url keycloakUrl
    * configure readTimeout = 300000
    * configure charset = null
    * configure retry = { count: 20, interval: 40000 }
  @Login
  Scenario: Login via keycloak
    * print __arg
    Given path 'realms/', client.realm, '/protocol/openid-connect/token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field client_id = client.id
    And form field client_secret = client.secret
    And form field grant_type = 'client_credentials'
    When method post
    Then status 200
    * def token = $.access_token

  @NewTenantToken
  Scenario: get new tenant authorization token
    Given url keycloakUrl
    And path 'realms', 'master', 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = client.id
    And form field client_secret = client.secret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * def accessToken = response.access_token

    Given url keycloakUrl
    And path 'admin', 'realms', tenant.name, 'clients'
    And header Authorization = 'Bearer ' + accessToken
    When method GET
    Then status 200
    * def clientId = response.filter(x => x.clientId == 'sidecar-module-access-client')[0].id

    Given url keycloakUrl
    And path 'admin', 'realms', tenant.name, 'clients', clientId, 'client-secret'
    And header Authorization = 'Bearer ' + accessToken
    When method GET
    Then status 200
    * def sidecarSecret = response.value