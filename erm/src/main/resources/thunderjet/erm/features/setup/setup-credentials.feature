Feature: Setup credentials

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}
    * def jsonHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}
    * def samplesPath = 'classpath:thunderjet/erm/features/setup/samples/'
    * def testUserId = java.lang.System.getProperty('erm-testUserId')

  @SetupCredentials
  Scenario: Create kb-credentials and assign users
    Given path '/eholdings/kb-credentials'
    And headers vndHeaders
    And request read(samplesPath + 'credentials.json')
    When method POST
    Then assert responseStatus == 201 || responseStatus == 422
    And def credential = responseStatus == 201 ? response : karate.call('setup-credentials.feature@RetrieveCredentials')
    And def credentialId = credential.id

    # Assign The Test User To The Credentials
    * call read('setup-credentials.feature@AssignUser') { userId: '#(testUserId)', credentialId: '#(credentialId)' }

    # Assign The mod-agreements System User Too: The Sync Job Calls mod-kb-ebsco As This User,
    # And mod-kb-ebsco Returns 500 To Users Not Assigned To Any Credentials
    Given path 'users'
    And headers jsonHeaders
    And param query = 'type=="system"'
    And param limit = 1000
    When method GET
    Then status 200
    * def agreementsSystemUsers = karate.filter(response.users, function(u){ return ('' + u.username).indexOf('agreements') > -1 })
    * assert agreementsSystemUsers.length > 0
    * def assignArgs = karate.map(agreementsSystemUsers, function(u){ return { userId: u.id, credentialId: credentialId } })
    * call read('setup-credentials.feature@AssignUser') assignArgs

    * setSystemProperty('credentialId', credentialId)

  @Ignore
  @AssignUser
  Scenario: Assign a user to kb-credentials
    # Input: userId, credentialId
    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And headers vndHeaders
    And request { data: { id: '#(userId)', credentialsId: '#(credentialId)' } }
    When method POST
    Then assert responseStatus == 201 || responseStatus == 422

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
