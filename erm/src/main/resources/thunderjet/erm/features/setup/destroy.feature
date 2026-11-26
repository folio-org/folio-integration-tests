Feature: Destroy test data for erm (mod-agreements)

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  @DestroyCredentials
  Scenario: Delete kb-credentials
    * def credentialId = getAndClearSystemProperty('credentialId')
    * if (credentialId == null) karate.abort()
    Given path '/eholdings/kb-credentials', credentialId
    And headers vndHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404
