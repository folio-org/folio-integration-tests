@ignore
Feature: Test rule

  Background:
    * url baseUrl

    * def okapiUserToken = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    # Parameter "rule" is expected to be set as a call arg
    * def rule = read('classpath:samples/rules/' + __arg.rule + ".json")
    * def password = read('classpath:samples/password.json')

  Scenario: Enable rule
    Given path 'tenant/rules'
    And request rule
    And set rule.state = "Enabled"
    And set rule.orderNo = 0
    When method PUT
    Then status 200

  Scenario: Test rule
    Given path 'password/validate'
    And request password
    And set password.password = rule.invalidExample
    When method POST
    Then status 200
    And match response.result == "invalid"
    And match response.messages[0] == rule.errMessageId

  Scenario: Disable rule
    Given path 'tenant/rules'
    And request rule
    And set rule.state = "Disabled"
    When method PUT
    Then status 200
