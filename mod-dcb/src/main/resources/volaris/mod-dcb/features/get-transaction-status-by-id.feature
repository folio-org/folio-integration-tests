Feature: Testing Get DCB Transaction Status By Id

  Background:
    * url baseUrl
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Get DCB Transaction Status By transaction Id
    * def dcbTransactionId = '1234568'

    Given url edgeUrl
    Given path '/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 200
    And match response.status == 'CLOSED'

  Scenario: Get DCB Transaction Status with incorrect transaction id
    * def dcbTransactionId = '12345'

    Given url edgeUrl
    Given path '/transactions/' + dcbTransactionId + '/status'
    When method GET
    Then status 404
    And def responseJson = response
    And karate.set('responseJson.errors[0].message','DCB Transaction was not found by id= '+dcbTransactionId)
    And match response == responseJson


