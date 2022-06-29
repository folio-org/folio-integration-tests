@parallel=false
Feature: Cancel Current Contribution

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser


  Scenario: Start initial contribution
    * print 'Get central servers'
    Given path '/inn-reach/central-servers'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def centralServerId = response.centralServers[0].id

    * print 'Start initial contribution'
    Given path '/inn-reach/central-servers/' + '{centralServerId}' + '/contributions'
    When method POST
    Then status 201

    * print 'Check current contribution'
    Given path '/inn-reach/central-servers/' + '{centralServerId}' + '/contributions/current'
    When method GET
    Then status 200
    And match response.status == 'In Progress'

  Scenario: Cancel current contribution
    * call pause 10000
    Given path '/inn-reach/central-servers/' + '{centralServerId}' + '/contributions/current'
    When method DELETE
    Then status 204

  Scenario: Get current contribution
    Given path '/inn-reach/central-servers/' + '{centralServerId}' + '/contributions/current'
    When method GET
    Then status 200
    And match response.status == 'Not Started'


