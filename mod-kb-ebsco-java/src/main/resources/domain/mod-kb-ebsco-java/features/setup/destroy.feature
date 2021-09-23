Feature: Setup test data for kb-ebsco-java

  Background:
    * url baseUrl

  @DestroyPackage
  Scenario: Destroy package
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204