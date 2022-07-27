@ignore
@parallel=false
Feature: Get authentication token

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def okapiTenantUser = testTenant
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(okapiTenantUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce variables

    * print 'Create central servers'
    * callonce read(featuresPath + 'central-server.feature@create')

  Scenario: Authenticate credentials and get a new JWT token
    * print 'Authenticate credentials and get a new JWT token'
    Given path '/innreach/v2/oauth2/token'
    And param grant_type = 'client_credentials'
    And param scope = 'innreach_tp'
    When method POST
    Then status 200
    And match response.access_token == '#present'

  Scenario: Failed authentication

    * print 'Failed authentication'
    Given path '/innreach/v2/oauth2/token'

    When method POST
    Then status 401

  Scenario: Destroy central servers
    * print 'Destroy central servers'
    * call read(featuresPath + 'central-server.feature@delete')
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]

