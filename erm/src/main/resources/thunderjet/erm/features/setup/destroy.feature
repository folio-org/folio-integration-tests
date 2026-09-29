Feature: Destroy test data for erm (mod-agreements)

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * def jsonHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
  @DestroyAgreement
  Scenario: Delete the agreement created for the test
    * def agreementId = getAndClearSystemProperty('agreementId')
    * if (agreementId == null) karate.abort()

    # An agreement with lines cannot be deleted (405), so remove its lines first
    Given path 'erm/entitlements'
    And headers jsonHeaders
    And param query = 'owner==' + agreementId
    When method GET
    Then status 200
    * def agreement = { id: '#(agreementId)', items: '#(response)' }
    * set agreement.items[*]._delete = true

    Given path 'erm/sas', agreementId
    And headers jsonHeaders
    And request agreement
    When method PUT
    Then status 200

    Given path 'erm/sas', agreementId
    And headers jsonHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 200 || responseStatus == 404

  @DestroyCredentials
  Scenario: Delete kb-credentials
    * def credentialId = getAndClearSystemProperty('credentialId')
    * if (credentialId == null) karate.abort()
    Given path '/eholdings/kb-credentials', credentialId
    And headers vndHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404
