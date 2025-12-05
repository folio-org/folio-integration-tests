@C432315
Feature: Negative - Verify configured limit of exported file size

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

  Scenario: Configure limit of exported file size to 0
    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "0"
      }
      """
    When method POST
    Then status 400
    * print response
    And match response contains "Slice size value cannot be less than 1: 0"

  Scenario: Configure limit of exported file size to text

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "text"
      }
      """
    When method POST
    Then status 400
    And match response contains 'Slice size is not a number: text'

  Scenario: Configure limit of exported file size

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "2.5"
      }
      """
    When method POST
    Then status 400
    And match response contains 'Slice size is not a number: 2.5'

  Scenario: Configure limit of exported file size to 2147483647

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "2147483647"
      }
      """
    When method POST
    Then status 201

    Scenario: Configure limit of exported file size to 2147483648

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "2147483648"
      }
      """
    When method POST
    Then status 400
    And match response contains 'Slice size is not a number: 2147483648'

    Scenario: Configure limit of exported file size to 100000

      Given path 'data-export/configuration'
      And request
        """
        {
          "key": "slice_size",
          "value": "100000"
        }
        """
      When method POST
      Then status 201
