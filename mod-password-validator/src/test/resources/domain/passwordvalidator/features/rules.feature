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

  Scenario: Test POST & GET rule
    Given path 'tenant/rules'
    And request rule
    And set rule.name = 'test rule 1'
    When method POST
    Then status 200
    And match response.id == '#present'
    And def createdRule = response

    Given path 'tenant/rules', createdRule.id
    When method GET
    Then status 200
    And match response.name contains 'test rule'

  Scenario: Test POST & PUT
    Given path 'tenant/rules'
    And request rule
    And set rule.name = 'test rule 2'
    When method POST
    Then status 200
    And match response.id == '#present'
    And def createdRule = response

    Given path 'tenant/rules'
    And headers headersUser
    And request createdRule
    And set createdRule.state = 'Enabled'
    When method PUT
    Then status 200

    Given path 'tenant/rules', createdRule.id
    When method GET
    Then status 200
    And match response.state == 'Enabled'

  Scenario: Test GET collection of rules
    Given path 'tenant/rules'
    When method GET
    Then status 200
    And match response.totalRecords == 10
