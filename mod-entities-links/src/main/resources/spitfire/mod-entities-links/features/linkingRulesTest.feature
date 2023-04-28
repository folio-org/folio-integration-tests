Feature: linking-rules tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * def existingRuleId = 1
    * def notExistingRuleId = 100

  @Positive
  Scenario: Get instance to authority rules - Should match rule schema
    Given path '/linking-rules/instance-authority'
    When method GET
    Then status 200
    And assert karate.sizeOf(response) > 0
    And assert karate.sizeOf(response[0].authoritySubfields) > 0
    And assert response[0].bibField != null
    And assert response[0].authorityField != null
    And assert response[0].autoLinkingEnabled != null

  @Positive
  Scenario: Get instance to authority rules by id - Should return appropriate rule
    Given path '/linking-rules/instance-authority/' + existingRuleId
    When method GET
    Then status 200
    And assert response != null
    And assert response.bibField == 100
    And assert response.authorityField == 100
    And assert response.autoLinkingEnabled != null
    And assert karate.sizeOf(response.authoritySubfields) > 0

  @Negative
  Scenario: Get instance to authority rules by not existing id - Should return 404
    Given path '/linking-rules/instance-authority/' + notExistingRuleId
    When method GET
    Then status 404

  @Positive
  Scenario: Patch linking rule by id - Should update appropriate rule
    Given path '/linking-rules/instance-authority/' + existingRuleId
    And request
    """
    {
      "id": "#(existingRuleId)",
      "autoLinkingEnabled": "true"
    }
    """
    When method PATCH
    Then status 202

    Given path '/linking-rules/instance-authority/' + existingRuleId
    When method GET
    Then status 200
    And assert response != null
    And assert response.bibField == 100
    And assert response.authorityField == 100
    And assert response.autoLinkingEnabled == true
    And assert karate.sizeOf(response.authoritySubfields) > 0

  @Positive
  Scenario: Patch linking rule by id - Should update appropriate rule's autoLinkingEnabled field only, other fields ignored
    Given path '/linking-rules/instance-authority/' + existingRuleId
    And request
    """
    {
      "id": "#(existingRuleId)",
      "autoLinkingEnabled": "false",
      "bibField": "200",
      "authorityField": "200"
    }
    """
    When method PATCH
    Then status 202

    Given path '/linking-rules/instance-authority/' + existingRuleId
    When method GET
    Then status 200
    And assert response != null
    And assert response.bibField == 100
    And assert response.authorityField == 100
    And assert response.autoLinkingEnabled == false
    And assert karate.sizeOf(response.authoritySubfields) > 0

  @Negative
  Scenario: Patch linking rule by not existing id - Should return 404
    Given path '/linking-rules/instance-authority/' + notExistingRuleId
    And request
    """
    {
      "id": "#(notExistingRuleId)",
      "autoLinkingEnabled": "false"
    }
    """
    When method PATCH
    Then status 404
