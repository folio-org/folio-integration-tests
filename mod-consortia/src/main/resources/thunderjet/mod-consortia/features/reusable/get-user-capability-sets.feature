@ignore
Feature: Verify a user has at least one capability-set in a tenant (Eureka)

  # Inputs (passed via call):
  #   tenant - tenant id where capability-sets should be queried
  #   userId - id of the user whose capability-sets should be retrieved
  #
  # Behavior:
  #   Retries the GET until response.totalRecords > 0
  #
  # Outputs (available on the result of the call):
  #   response - raw response from GET /users/capability-sets

  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 2000 }

  Scenario:
    * call read('classpath:common-consortia/eureka/keycloak.feature@getAuthorizationToken')
    * def okapitoken = karate.get('okapitoken')
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
    Given path '/users/capability-sets'
    And param query = 'userId=' + userId
    And param limit = 1
    And headers { 'x-okapi-tenant': '#(tenant)', 'x-okapi-token': '#(okapitoken)' }
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
