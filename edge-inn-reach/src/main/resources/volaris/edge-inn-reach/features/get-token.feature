#@ignore
@parallel=false
Feature: Get authentication token

  Background:
    * url baseUrl

    * callonce login admin
    * def okapitokenUser = okapitoken
    * def okapiTenantUser = testTenant

    * print 'Create central servers'
    * callonce read(featuresPath + 'central-server.feature@create')

    * def tokenResponse = callonce read(globalPath + 'jwt-token-helper.feature@GetJWTToken')
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiTenatUser)', 'x-okapi-tenant': '#(okapiTenantUser)', 'Authorization' : '#(tokenResponse.access_token)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }
    * configure headers = headersUser


  Scenario: Get inn-reach transactions through proxy
    * print 'Get inn-reach transactions through proxy'
    Given url 'http://localhost:8081/innreach/v2/transactions'
    When method GET
    Then status 200

  Scenario: Destroy central servers
    * print 'Destroy central servers'
    * call read(featuresPath + 'central-server.feature@delete')