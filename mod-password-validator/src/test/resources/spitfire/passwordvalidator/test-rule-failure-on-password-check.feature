@ignore
Feature: Test rule against password check

  Background:
    * url baseUrl

    * def okapiUserToken = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    # Parameter "rule" is expected to be set as a call arg
    * def rule = read('classpath:samples/rules/' + __arg.rule + ".json")
    * def passwordCheck = read('classpath:samples/password_check.json')

  Scenario: Enable rule
    Given path 'tenant/rules'
    And request rule
    And set rule.state = "Enabled"
    And set rule.orderNo = 0
    When method PUT
    Then status 200

  Scenario: Should fail when checking invalid password
    Given path 'password/check'
    And request passwordCheck
    And set passwordCheck.password = rule.invalidExample
    * if (__arg.rule == 'no_user_name') passwordCheck.username = rule.invalidExample
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
