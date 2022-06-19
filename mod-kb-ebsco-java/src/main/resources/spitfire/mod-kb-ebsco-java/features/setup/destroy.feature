Feature: Destroy test data for kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'x-okapi-token': '#(okapitoken)'}

  @UnassignAllAgreements
  Scenario: Unassign all agreements
    * def agreementsId = getAndClearSystemProperty('EKB-PACKAGE-AGREEMENT')
    * call read('destroy.feature@UnassignAgreements')

    * def agreementsId = getAndClearSystemProperty('EKB-TITLE-AGREEMENT')
    * call read('destroy.feature@UnassignAgreements')

  @DestroyNoteType
  Scenario: Destroy note-type
    * def noteTypeId = getAndClearSystemProperty('noteTypeId')
    * if (noteTypeId == null) karate.abort()
    Given path '/note-types', noteTypeId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyResources
  Scenario: Destroy resources
    * def resourceId = getAndClearSystemProperty('resourceId')
    * if (resourceId == null) karate.abort()
    Given path '/eholdings/resources', resourceId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyPackage
  Scenario: Destroy package
    * def packageId = getAndClearSystemProperty('packageId')
    * if (packageId == null) karate.abort()
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyPackage
  Scenario: Destroy single package
    * def freePackageId = getAndClearSystemProperty('freePackageId')
    * if (freePackageId == null) karate.abort()
    Given path '/eholdings/packages', freePackageId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyCredentials
  Scenario: Destroy kb-credentials
    * def credentialId = getAndClearSystemProperty('credentialId')
    * if (credentialId == null) karate.abort()
    Given path '/eholdings/kb-credentials', credentialId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @UnassignAgreements
  @Ignore #accept agreementsId
  Scenario: Unassign agreements
    * if (agreementsId == null) karate.abort()
    Given path '/erm/sas', agreementsId
    When method GET
    And status 200
    And def agreements = response
    And set agreements.items[*]._delete = 'true'

    Given path '/erm/sas', agreementsId
    And request agreements
    When method PUT
    Then assert responseStatus == 200

    Given path '/erm/sas', agreementsId
    When method DELETE
    Then assert responseStatus == 204