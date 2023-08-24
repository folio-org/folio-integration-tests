Feature: login

  Background:
    * url baseUrl

  Scenario: Login a user, then if successful set latest value for 'okapitoken'
    * def username = karate.get('username', karate.get('name', ''))

    Given path 'authn/login'
    And header x-okapi-tenant = tenant
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 201
    * def okapitoken = responseHeaders['x-okapi-token'][0]

