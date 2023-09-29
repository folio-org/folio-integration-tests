Feature: Testing Update DCB Transaction Status

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Update DCB Transaction Status
    * def dcbTransactionId = '111'

    Given path '/dcbService/transactions/' + dcbTransactionId + '/status'
    And param apikey = apikey
    And request {
        status = 'STATUS'
    }
    When method PUT
    Then status 501