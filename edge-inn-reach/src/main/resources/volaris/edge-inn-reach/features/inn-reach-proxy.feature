#@ignore
@parallel=false
Feature: Inn reach proxy api

  Background:
    * url baseUrl

    * callonce login admin
    * def okapitokenUser = okapitoken
    * def okapiTenantUser = testTenant

    * print 'Create JWT Token : Get Token'
    * callonce read(globalPath + 'jwt-token-helper.feature@GetJWTToken')
    * def responseToken = 'Bearer ' + response.access_token
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiTenantUser)', 'x-okapi-tenant': '#(okapiTenantUser)', 'Authorization' : '#(responseToken)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }

    * configure headers = headersUser

  Scenario: Proxying mod-inn-reach api calls
    * print 'Proxying mod-inn-reach api calls'
    * callonce read(modInnReachPath + 'inn-reach-transactions.feature@InnReachTransaction') { isProxyCall: true, proxyPath: 'http://localhost:8081/innreach/v2', proxyHeader: headersUser }
