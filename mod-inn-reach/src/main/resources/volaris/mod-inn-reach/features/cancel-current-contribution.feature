@parallel=false
Feature: Cancel Current Contribution

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables
    * def notExistedCentralServerId = globalCentralServerId1


    # Positive Scenarios
  Scenario: Start initial contribution
    * print 'Create central server'
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId = $.id

    * print 'Get central server by id'
    Given path '/inn-reach/central-servers', centralServerId
    When method GET
    Then status 200

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

    * print 'Delete central server by id'
    Given path '/inn-reach/central-servers', centralServerId
    When method DELETE
    Then status 204

  # Negative Scenarios
  Scenario: Start initial contribution
    * print 'Start initial contribution'
    Given path '/inn-reach/central-servers/' + '{notExistedCentralServerId}' + '/contributions'
    When method POST
    Then status 201

  Scenario: Cancel current contribution
    * call pause 10000
    Given path '/inn-reach/central-servers/' + '{notExistedCentralServerId}' + '/contributions/current'
    When method DELETE
    Then status 204

  Scenario: Get current contribution
    Given path '/inn-reach/central-servers/' + '{notExistedCentralServerId}' + '/contributions/current'
    When method GET
    Then status 200
    And match response.status == 'Not Started'

