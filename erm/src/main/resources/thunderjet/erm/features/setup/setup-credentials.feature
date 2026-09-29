Feature: Setup credentials

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}
    * def samplesPath = 'classpath:thunderjet/erm/features/setup/samples/'
  @SetupCredentials
  Scenario: Create kb-credentials as the only tenant credentials
    # mod-kb-ebsco inserts 'Dummy Credentials' into every new tenant (liquibase migration). The unassigned-user fallback
    # (used by test-user and by the sync job) works only when the tenant has exactly one credentials, so drop the others.
    * def credentialsName = read(samplesPath + 'credentials.json').data.attributes.name
    Given path '/eholdings/kb-credentials'
    And headers vndHeaders
    When method GET
    Then status 200
    * def otherIds = karate.jsonPath(response, "$.data[?(@.attributes.name != '" + credentialsName + "')].id")
    * def otherCredentials = karate.map(otherIds, function(id){ return { otherCredentialId: id } })
    * call read('setup-credentials.feature@DeleteCredentials') otherCredentials

    Given path '/eholdings/kb-credentials'
    And headers vndHeaders
    And request read(samplesPath + 'credentials.json')
    When method POST
    Then assert responseStatus == 201 || responseStatus == 422
    And def credential = responseStatus == 201 ? response : karate.call('setup-credentials.feature@RetrieveCredentials')
    And def credentialId = credential.id

    # No user is assigned to the credentials on purpose. The sync job calls mod-kb-ebsco with
    # x-okapi-user-id 00000000-0000-0000-0000-000000000001, which cannot be assigned (it is not a real user).
    # mod-kb-ebsco falls back to the single tenant credentials only when nobody is assigned to them.
    * setSystemProperty('credentialId', credentialId)

  @Ignore
  @DeleteCredentials
  Scenario: Delete kb-credentials by id
    # Input: otherCredentialId
    Given path '/eholdings/kb-credentials', otherCredentialId
    And headers vndHeaders
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 404

  @Ignore
  @RetrieveCredentials
  Scenario: Retrieve kb-credentials by name
    Given path '/eholdings/kb-credentials'
    And headers vndHeaders
    When method GET
    Then status 200
    And def credentials = read(samplesPath + 'credentials.json')
    And def credentialName = credentials.data.attributes.name
    And def credentialsByName = karate.jsonPath(response, "$.data[?(@.attributes.name =='" + credentialName + "')]")[0]
    And def id = credentialsByName.id
