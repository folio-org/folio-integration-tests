# For MODINVOSTO-120
Feature: Voucher numbers

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser


  Scenario: Set/reset the start value of the voucher-number sequence
    # Note: an id is passed by the UI in the request, but not used...
    Given path '/voucher/voucher-number/start/11'
    And request {}
    When method POST
    Then status 204

  Scenario: Try a wrong number as the start value of the voucher-number sequence
    Given path '/voucher/voucher-number/start/abc'
    And request {}
    When method POST
    Then status 400
