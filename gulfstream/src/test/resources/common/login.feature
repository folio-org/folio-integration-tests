Feature: login

  Background:
    * url baseUrl

  Scenario: login user
    Given path 'authn/login'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    And request { username: '#(name)', password: '#(password)' }
    When method POST
    Then status 201
    * def okapitoken = responseHeaders['x-okapi-token'][0]

