Feature:

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * configure headers = null

  @getAuthorizationToken
  Scenario: get authorization token for new tenant
    * print "---extracting authorization token---"
    Given url baseKeycloakUrl
    And path 'realms', 'master', 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = kcClientId
    And form field client_secret = kcClientSecret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * def accessToken = response.access_token

    Given url baseKeycloakUrl
    And path 'admin', 'realms', tenant, 'clients'
    And header Authorization = 'Bearer ' + accessToken
    When method GET
    Then status 200
    * def clientId = response.filter(x => x.clientId == 'sidecar-module-access-client')[0].id

    Given url baseKeycloakUrl
    And path 'admin', 'realms', tenant, 'clients', clientId, 'client-secret'
    And header Authorization = 'Bearer ' + accessToken
    When method GET
    Then status 200
    * def sidecarSecret = response.value

    Given url baseKeycloakUrl
    And path 'realms', tenant, 'protocol', 'openid-connect', 'token'
    And header Content-Type = 'application/x-www-form-urlencoded'
    And form field grant_type = 'client_credentials'
    And form field client_id = 'sidecar-module-access-client'
    And form field client_secret = sidecarSecret
    And form field scope = 'email openid'
    When method post
    Then status 200
    * karate.set('okapitoken', response.access_token)