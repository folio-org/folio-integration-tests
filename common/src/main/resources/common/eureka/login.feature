Feature: login

  Background:
    * url baseUrl
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
    * def okapitoken  = response.okapiToken
    * def refreshtoken  = response.refreshToken
    * configure cookies = null
