Feature: Testing Get DCB Transaction Status

    Background:
        * url baseUrl
        * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
        * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }


  Scenario: Get DCB Transaction Status
    * def dcbTransactionId = '1234568'

    Given url edgeUrl
    Given path '/dcbService/transactions/' + dcbTransactionId + '/status'
    And param apikey = apikey
    When method GET
    Then status 200
    And match response.status == 'OPEN'

  Scenario: Get DCB Transaction Status with incorrect transaction id
    * def dcbTransactionId = '123'

    Given url edgeUrl
    Given path '/dcbService/transactions/' + dcbTransactionId + '/status'
    And param apikey = apikey
    When method GET
    Then status 404
    And def responseJson = response
    And karate.set('responseJson.errors[0].message','DCB Transaction was not found by id= '+dcbTransactionId)
    And match response == responseJson

  Scenario: Get DCB Transaction Status with incorrect api key
    * def dcbTransactionId = '123456'
    * def key = 'dummykey'

    Given url edgeUrl
    Given path '/dcbService/transactions/' + dcbTransactionId + '/status'
    And param apikey = key
    When method GET
    Then status 401
