Feature: linking-rules tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

  @Positive
  Scenario: Get instance to authority rules - Should match json rules
    Given path '/linking-rules/instance-authority'
    When method GET
    Then status 200
    And assert karate.sizeOf(response) > 0
    And assert karate.sizeOf(response[0].authoritySubfields) > 0
    And assert response[0].bibField != null
    And assert response[0].authorityField != null
    And assert response[0].subfieldModifications != null
    And assert response[0].validation != null
