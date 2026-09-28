Feature: Destroy test data for erm (mod-agreements)

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * def jsonHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * def destroyResource = 'destroy.feature@DestroyResource'

  @DestroyAgreement
  Scenario: Delete the agreement created for the test
    * def agreementId = getAndClearSystemProperty('agreementId')
    * if (agreementId == null) karate.abort()
    Given path 'erm/sas', agreementId
    And headers jsonHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 200 || responseStatus == 404

  @DestroyPackage
  Scenario: Delete the kept eHoldings package with its resources
    * def packageId = getAndClearSystemProperty('keptPackageId')
    * if (packageId == null) karate.abort()

    Given path '/eholdings/packages', packageId, 'resources'
    And headers vndHeaders
    When method GET
    Then assert responseStatus == 200 || responseStatus == 404
    * def ids = responseStatus == 200 ? karate.jsonPath(response, '$.data[*].id') : []
    * def resourceIds = karate.mapWithKey(ids, 'resourceId')
    * call read(destroyResource) resourceIds

    Given path '/eholdings/packages', packageId
    And headers vndHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyResource
  @Ignore #accept resourceId
  Scenario: Delete an eHoldings resource
    * if (resourceId == null) karate.abort()
    Given path '/eholdings/resources', resourceId
    And headers vndHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @DestroyCredentials
  Scenario: Delete kb-credentials
    * def credentialId = getAndClearSystemProperty('credentialId')
    * if (credentialId == null) karate.abort()
    Given path '/eholdings/kb-credentials', credentialId
    And headers vndHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404
