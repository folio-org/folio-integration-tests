@ignore
Feature: Verify Released Encumbrance
  # parameters: encId

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Verify Released Encumbrance
    Given path '/finance/transactions', encId
    When method GET
    Then status 200
    And match response.encumbrance.status == 'Released'
    And match response.amount == 0
