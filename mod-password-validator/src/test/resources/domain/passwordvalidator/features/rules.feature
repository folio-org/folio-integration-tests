Feature: Test job profiles

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * def rule = read('classpath:samples/rule.json')

  Scenario: Test creating rule
    Given path 'tenant/rules'
    And request rule
    When method POST
    Then status 201
    And match response.id == '#present'
    And match response.ruleId == '#present'
    And match response.name == '#present'

  Scenario: Test getting rule
    Given path 'tenant/rules', rule.id
    When method GET
    Then status 200
    And match  response.name contains 'Test validation rule'

  Scenario: Test updating rule
    Given path 'tenant/rules', rule.id
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    And request rule
    And set rule.name = 'Test validation rule - updated'
    When method PUT
    Then status 204
    When method GET
    Then status 200
    And match  response.name contains 'Test validation rule - updated'
