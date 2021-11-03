Feature: Destroy test data for kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'x-okapi-token': '#(okapitoken)'}

    * def credentialId = karate.properties['credentialId']
    * def resourcesId = karate.properties['resourcesId']
    * def packageId = karate.properties['packageId']

  @DestroyPackage
  Scenario: Destroy package
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  @DestroyResource
  Scenario: Destroy resource
    Given path '/eholdings/resources', resourcesId
    When method DELETE
    Then status 204
    #waiting for resources deletion
    * eval sleep(20000)

  @DestroyCredentials
  Scenario: Destroy kb-credentials
    Given path '/eholdings/kb-credentials', credentialId
    When method DELETE
    And status 204
