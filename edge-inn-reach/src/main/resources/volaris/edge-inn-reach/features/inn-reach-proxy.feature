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


    * print 'Create JWT Token : Get Token'
    * callonce read(globalPath + 'jwt-token-helper.feature@GetJWTToken')
    * def responseToken = 'Bearer ' + response.access_token
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiTenantUser)', 'x-okapi-tenant': '#(okapiTenantUser)', 'Authorization' : '#(responseToken)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }

    * configure headers = headersUser


  @delete
  Scenario: Delete
    * print 'Delete central servers'
    Given url 'http://localhost:8081/innreach/v2/central-servers'
    When method GET
    Then status 200
    * def centralServer1 = response.centralServers[0]

    Given url 'http://localhost:8081/innreach/v2/central-servers/' +  centralServer1.id
    When method DELETE
    Then status 204