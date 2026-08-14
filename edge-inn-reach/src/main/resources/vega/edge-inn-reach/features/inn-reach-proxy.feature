@ignore
@parallel=false
Feature: Inn reach proxy api

  Background:
    * url baseUrl

    * print 'Create central server'
    * callonce read(edgeFeaturesPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]

    * print 'Create JWT Token : Get Token'
    * callonce read(edgeGlobalPath + 'jwt-token-helper.feature@GetJWTToken')
    * def responseToken = 'Bearer ' + response.access_token
    * def authHeader = { 'Content-Type': 'application/json', 'Authorization' : '#(responseToken)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }

  Scenario: Negative scenario for JWT token
    * print 'Negative scenario for JWT token'
    * callonce read(edgeGlobalPath + 'jwt-token-helper.feature@GetInvalidJWTToken')


  Scenario: Proxying mod-inn-reach api calls
    * print 'Proxying mod-inn-reach api calls'
    * callonce read(featuresPath + 'inn-reach-transaction.feature') { proxyCall: true, proxyPath: edgeUrl + '/innreach/v2', proxyHeader: #(authHeader), centralServer: #(centralServer1) , testUserEdge: #(testUser) }


