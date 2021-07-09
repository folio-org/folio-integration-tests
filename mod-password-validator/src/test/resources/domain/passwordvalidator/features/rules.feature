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

  Scenario: Test rule CRUD flow
    # Test creating rule
    Given path 'tenant/rules'
    And request rule
    When method POST
    Then status 200
    And match response.id == '#present'
    And def ruleId = response.id

    # Test getting rule
    Given path 'tenant/rules', ruleId
    When method GET
    Then status 200
    And match response.name contains 'test rule'

    # Test updating rule
    Given path 'tenant/rules', ruleId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    And request rule
    And set rule.name = 'test rule - updated'
    When method PUT
    Then status 204

    Given path 'tenant/rules', ruleId
    When method GET
    Then status 200
    And match response.name contains 'test rule - updated'
