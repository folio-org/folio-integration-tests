@ignore
@parallel=false
Feature: Authentication

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * callonce variables

    * def mockServer = karate.start(mocksPath + 'general/auth-mock.feature')
    * def port = mockServer.port
    * def centralServerUrl = 'http://10.0.2.2:' + port

  Scenario: Successful authentication
    * print 'Successful authentication'
    * configure headers = headersUser
    Given path '/inn-reach/authentication'
    * def authReq = read(samplesPath + "/authentication/authentication-request.json")
    And request authReq
    When method POST
    Then status 200

  Scenario: Failed authentication
    * print 'Failed authentication'
    * configure headers = headersUser
    Given path '/inn-reach/authentication'
    * def authReq = read(samplesPath + "/authentication/bad-credentials-authentication-request.json")
    And request authReq
    When method POST
    Then status 401