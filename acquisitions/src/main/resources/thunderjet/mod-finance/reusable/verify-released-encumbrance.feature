@ignore
Feature: Verify Released Encumbrance
  # parameters: encId

  Background:
    * url baseUrl

  Scenario: verifyReleasedEncumbrance
    Given path '/finance/transactions', encId
    When method GET
    Then status 200
    And match response.encumbrance.status == 'Released'
    And match response.amount == 0
