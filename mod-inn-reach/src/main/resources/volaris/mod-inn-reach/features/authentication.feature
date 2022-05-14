@ignore
@parallel=false
Feature: Authentication

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * def mockServer = karate.start(mocksPath + 'general/auth-mock.feature')
    * def port = mockServer.port
    * def centralServerUrl = 'http://10.0.2.2:' + port

  Scenario: Successful authentication
    * print 'Create central server for authentication'

    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    And request read (samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId1 = response.id

    * configure headers = headersUser
    Given path '/inn-reach/central-servers', centralServerId1
    When method GET
    Then status 200
    * def localServerKey = response.localServerKey
    * def localServerSecret = response.localServerSecret

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