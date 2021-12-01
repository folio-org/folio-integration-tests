# created for MODINVOSTO-120
Feature: Voucher numbers

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
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
