@ignore
Feature: Get capabilities of a user in a tenant

  # Inputs (passed via call):
  #   tenant - tenant id where capabilities should be queried
  #   userId - id of the user whose capabilities should be retrieved
  #
  # Outputs (available on the result of the call):
  #   response - raw response from GET /users/capabilities

  Background:
    * url baseUrl

  Scenario:
    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def okapitoken = karate.get('okapitoken')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    Given path '/users/capabilities'
    And param query = 'userId=' + userId
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    When method GET
    Then status 200
