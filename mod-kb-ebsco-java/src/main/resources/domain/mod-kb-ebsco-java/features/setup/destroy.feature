Feature: Destroy test data for kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'x-okapi-token': '#(okapitoken)'}

    * def credentialId = karate.properties['credentialId']
    * def packageId = karate.properties['packageId']

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