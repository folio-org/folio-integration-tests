Feature: Setup credentials

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}
    * def samplesPath = 'classpath:thunderjet/erm/features/setup/samples/'
    * def testUserId = java.lang.System.getProperty('erm-testUserId')

  @SetupCredentials
  Scenario: Create kb-credentials and assign user
    Given path '/eholdings/kb-credentials'
    And headers vndHeaders
    And request read(samplesPath + 'credentials.json')
    When method POST
    Then assert responseStatus == 201 || responseStatus == 422
    And def credential = responseStatus == 201 ? response : karate.call('setup-credentials.feature@RetrieveCredentials')
    And def credentialId = credential.id

    # No user is assigned to the credentials on purpose: the sync job calls mod-kb-ebsco as the
    # mod-agreements system user, which cannot resolve credentials that are assigned to other users only
    * setSystemProperty('credentialId', credentialId)

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
