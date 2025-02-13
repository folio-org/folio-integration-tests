Feature: login

  Background:
    * url baseKongUrl
    * configure cookies = null

  Scenario: login user
    Given path 'authn', 'login'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    And request { username: '#(name)', password: '#(password)' }
    When method POST
    Then status 201
    * assert response.okapiToken != null
    * assert response.refreshToken != null
    * def okapiToken  = response.okapiToken
    * def refreshToken  = response.refreshToken
    * configure cookies = null
