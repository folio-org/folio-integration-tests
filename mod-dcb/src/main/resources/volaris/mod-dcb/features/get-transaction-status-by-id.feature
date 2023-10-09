Feature: Testing Get DCB Transaction Status By Id

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Get DCB Transaction Status By Id
    * def dcbTransactionId = '1234568'

    Given url edgeUrl
    Given path '/dcbService/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 200
    And match response.status == 'CLOSED'
