Feature: Testing Update transaction status

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Update transaction status
    * def dcbTransactionId = '1234568'

    Given url edgeUrl
