Feature: Testing Update transaction status

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  Scenario: Update transaction status to AWAITING_PICKUP
    * def dcbTransactionId = '1234568'

    Given path '/transactions/' + dcbTransactionId
    And request
    """
    {
      "status": "AWAITING_PICKUP"
    }
    """
    When method PUT
    Then status 200
