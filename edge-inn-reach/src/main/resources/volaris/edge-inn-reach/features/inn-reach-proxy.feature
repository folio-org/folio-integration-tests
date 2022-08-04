@ignore
@parallel=false
Feature: Get authentication token

  Background:
    * url baseUrl

    * print 'Create central servers'
    * callonce read(featuresPath + 'central-server.feature@create') {'okapitokenUser': #(okapitokenUser)}

    * print 'Create JWT Token : Get Token'
    * callonce read(globalPath + 'jwt-token-helper.feature@GetJWTToken')
    * def responseToken = 'Bearer ' + response.access_token
    * def headersUser = { 'Content-Type': 'application/json', 'Authorization' : '#(responseToken)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }

  Scenario: Delete central server
    * print 'Delete central server'
    * callonce read(featuresPath + 'central-server.feature@delete')