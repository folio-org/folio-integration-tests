Feature: Setup kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)'}
    * def samplesPath = 'classpath:domain/mod-kb-ebsco-java/features/setup/samples/'

  @SetupCredentials
  Scenario: Create kb-credentials and assign user
    Given path '/eholdings/kb-credentials'
    And headers vndHeaders
    And request read(samplesPath + 'credentials.json')
    When method POST
    Then assert responseStatus == 201 || responseStatus == 422
    And def credential = responseStatus == 201 ? response : karate.call('setup.feature@RetrieveCredentials')
    And def credentialId = credential.id

    Given path '/eholdings/kb-credentials', credentialId, 'users'
    And headers vndHeaders
    And request read(samplesPath + 'user.json')
    When method POST
    Then status 201

    * setSystemProperty('credentialId', credentialId)

  @SetupPackage
  Scenario: Create package
    Given path '/eholdings/packages'
    And headers vndHeaders
    And def packageName = random_string()
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200
    * setSystemProperty('packageId', response.data.id)

  @SetupTitle
  Scenario: Create title
    Given path '/eholdings/titles'
    And def titleName = random_string()
    And request read(samplesPath + 'title.json')
    When method POST
    Then status 200
    * setSystemProperty('titleId', response.data.id)
    * eval sleep(20000)

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
