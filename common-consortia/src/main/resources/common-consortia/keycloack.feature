Feature:
  Background:
    * url keycloakUrl
    * configure readTimeout = 300000
    * configure charset = null
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