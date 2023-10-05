Feature: Destroy test data for kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'x-okapi-token': '#(okapitoken)'}

    * def destroyResource = 'destroy.feature@DestroyResource'
    * def destroyPackageWithResources = 'destroy.feature@DestroyPackageWithResources'

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

  @DestroyPackages
  Scenario: Destroy packages with resources
    * def packageId = getAndClearSystemProperty('packageId')
    * call read(destroyPackageWithResources)

    * def packageId = getAndClearSystemProperty('freePackageId')
    * call read(destroyPackageWithResources)

  @DestroyCredentials
  Scenario: Destroy kb-credentials
    * def credentialId = getAndClearSystemProperty('credentialId')
    * if (credentialId == null) karate.abort()
    Given path '/eholdings/kb-credentials', credentialId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyPackageWithResources
  @Ignore #accept packageId
  Scenario: Destroy package with resources
    * if (packageId == null) karate.abort()
    Given path '/eholdings/packages', packageId, 'resources'
    When method GET
    Then status 200

    * def ids = get response.data[*].id
    * def resourceIds = karate.mapWithKey(ids, 'resourceId')
    * call read(destroyResource) resourceIds

    Given path '/eholdings/packages', packageId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyResource
  @Ignore #accept resourceId
  Scenario: Destroy resource
    * if (resourceId == null) karate.abort()
    Given path '/eholdings/resources', resourceId
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @UnassignAgreements
  @Ignore #accept agreementsId
  Scenario: Unassign agreements
    * if (agreementsId == null) karate.abort()
    Given path '/erm/sas', agreementsId
    When method DELETE
    Then assert responseStatus == 204
