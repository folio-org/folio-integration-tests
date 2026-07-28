Feature: CRUD operations on a specifications
  Background:
    * url baseUrl

  @getSpecifications
  Scenario: Get a collection of specifications
    Given path 'specification-storage/specifications'
    And param profile = profileParam
    And param family = familyParam
    When method Get
    Then status 200
    * def response = $

  @getRules
  Scenario: Get a collection of rules of a specification
    Given path 'specification-storage/specifications/' + specificationId + '/rules'
    When method Get
    Then status 200
    * def response = $

  @patchRule
  Scenario: Update a specification rule
    Given path 'specification-storage/specifications/' + specificationId + '/rules/' + ruleId
    And request
    """
    {
      "enabled": "#(isEnabled)"
    }
    """
    When method Patch
    Then status 204