Feature: Destroy test data for kb-ebsco-java

  Background:
    * url baseUrl

  @DestroyCredentials
  Scenario: Destroy kb-credentials
    Given path '/eholdings/kb-credentials', credentialId
    When method DELETE
    And status 204

  @DestroyPackage
  Scenario: Destroy package
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204