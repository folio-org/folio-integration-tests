Feature: Resource validation
  Background:
    * url baseUrl

  @validationErrorWithCodeOnResourceCreation
  Scenario: Post a resource and verify bad request
    Given path 'linked-data/resource'
    And request resource
    When method POST
    Then status 400
    And match $.errors[0].code == code
