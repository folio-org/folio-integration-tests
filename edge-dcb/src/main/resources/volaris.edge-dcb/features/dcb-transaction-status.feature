Feature: Testing getDCBTransactionStatus

    Background:
        * url baseUrl
        * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
        * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }


  Scenario: Get DCB Transaction Status
    * def dcbTransactionId = '1234'

    Given url edgeUrl
    Given path '/dcbService/transactions' + dcbTransactionId + '/status'
    And param apikey = apikey
    When method GET
    Then status 404