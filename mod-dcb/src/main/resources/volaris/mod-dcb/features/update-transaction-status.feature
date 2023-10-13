Feature: Testing Update transaction status

  Background:
    * url baseUrl
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Update transaction status to AWAITING_PICKUP
    * def dcbTransactionId = '222'

    Given url edgeUrl
    Given path '/transactions/' + dcbTransactionId + '/status'
    And request { status = 'AWAITING_PICKUP'}
    When method PUT
    Then status 200
