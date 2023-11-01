Feature: destroy data for tenant

  Background:
    * url baseUrl
    * configure readTimeout = 420000
    * configure retry = { count: 2, interval: 5000 }
    * configure headers = {}

  Scenario: purge all modules for tenant
    Given path '_/proxy/tenants', tenant, 'modules'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = adminToken
    When method GET
    Then status 200

    * set response $[*].action = 'disable'

    Given path '_/proxy/tenants', tenant, 'install'
    And param purge = true
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = adminToken
    And retry until responseStatus == 200
    And request response
    When method POST
    Then status 200

    * call read('classpath:common/tenant.feature@delete') __arg
