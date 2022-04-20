@parallel=false
Feature: Authentication

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

  Scenario: Successful authentication
    * print 'Successful authentication'
    Given path '/inn-reach/authentication'
    * def authReq = read('classpath:samples/authentication-request.json')
    And request authReq
    When method POST
    Then status 200

  Scenario: Failed authentication
    * print 'Failed authentication'
    Given path '/inn-reach/authentication'
    * def authReq = read('classpath:samples/bad-credentials-authentication-request.json')
    And request authReq
    When method POST
    Then status 401