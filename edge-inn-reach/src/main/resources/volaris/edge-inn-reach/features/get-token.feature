#@ignore
@parallel=false
Feature: Get authentication token

  Background:
    * url baseUrl

    * callonce login admin
    * def okapitokenUser = okapitoken
    * def okapiTenantUser = testTenant
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(okapiTenantUser)', 'x-to-code': 'fli01', 'x-from-code': '69a3d' , 'Authorization' : 'Basic NTg1OGY5ZDgtMTU1OC00NTEzLWFhMjUtYmFkODM5ZWI4MDNhOjM1NGFmZGFlLWZlYzktNDhkMC05MTVhLTc3Mjg3ZWJiMjk4Yg==' ,  'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce variables

#    * print 'Create central servers'
#    * callonce read(featuresPath + 'central-server.feature@create')

  Scenario: Authenticate credentials and get a new JWT token
    * print 'Authenticate credentials and get a new JWT token'
    Given url 'http://localhost:8081/innreach/v2/oauth2/token'
    And param grant_type = 'client_credentials'
    And param scope = 'innreach_tp'
    When method POST
    Then status 200
    And match response.access_token == '#present'

#  Scenario: Failed authentication
#
#    * print 'Failed authentication'
#    Given path 'http://localhost:8081/innreach/v2/oauth2/token''
#
#    When method POST
#    Then status 401

#  Scenario: Destroy central servers
#    * print 'Destroy central servers'
#    * call read(featuresPath + 'central-server.feature@delete')
#    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
#    * configure headers = headersUser
#
#    * callonce read(featuresPath + 'central-server.feature@create')
#    * def centralServer1 = response.centralServers[0]

