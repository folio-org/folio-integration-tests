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

    * print 'Create central servers'
    * callonce read(featuresPath + 'central-server.feature@create')

  Scenario: Successful authentication

    * print 'Successful authentication'
    Given path '/inn-reach/authentication'
    * def authReq = read(samplesPath + "/authentication/authentication-request.json")
    And request authReq
    When method POST
    Then status 200

  Scenario: Failed authentication

    * print 'Failed authentication'
    Given path '/inn-reach/authentication'
    * def authReq = read(samplesPath + "/authentication/bad-credentials-authentication-request.json")
    And request authReq
    When method POST
    Then status 401

  Scenario: Destroy central servers
    * print 'Destroy central servers'
    * call read(featuresPath + 'central-server.feature@delete')