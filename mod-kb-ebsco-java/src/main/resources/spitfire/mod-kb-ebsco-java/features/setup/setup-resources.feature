Feature: Setup resources

  Background:
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)'}
    * def jsonHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)'}
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/setup/samples/'

    * def createNoteType = 'setup-resources.feature@SetupNoteType'
    * def assignNote = 'setup-resources.feature@AssignNote'
    * def assignAgreement = 'setup-resources.feature@AssignAgreement'

  @SetupPackage
  Scenario: Create package without title
    Given path '/eholdings/packages'
    And headers vndHeaders
    And def packageName = "Karate Single Package " + random_string()
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200
    * setSystemProperty('freePackageId', response.data.id)
    * eval sleep(15000)

  @SetupResources
  Scenario: Create resources with Agreements and Notes
    Given path '/eholdings/packages'
    And headers vndHeaders
    And def packageName = "Karate Package " + random_string()
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200
    And def packageId = response.data.id

    Given path '/eholdings/titles'
    And headers vndHeaders
    And def titleName = "Karate Title " + random_string()
    And request read(samplesPath + 'title.json')
    When method POST
    Then status 200
    And def titleId = response.data.id
    And def resourceId = packageId + '-' + titleId

    * call read(createNoteType)
    * call read(assignNote) {noteName: 'Note 1'}
    * call read(assignNote) {noteName: 'Note 2'}
    * call read(assignAgreement) {recordId: packageId, recordType: 'EKB-PACKAGE', agreementName: 'Package Agreement'}
    * call read(assignAgreement) {recordId: resourceId, recordType: 'EKB-TITLE', agreementName: 'Resource Agreement'}

    * setSystemProperty('resourceId', resourceId)
    * setSystemProperty('packageId', packageId)
    * setSystemProperty('titleId', titleId)
    * eval sleep(15000)

  @AssignNote
  @Ignore #accept resourceId, packageId and noteName
  Scenario: Assign note
    Given path '/notes'
    And headers jsonHeaders
    And request read(samplesPath + 'notes.json')
    When method POST
    Then status 201

  @AssignAgreement
  @Ignore #accept recordId, recordType and agreementName
  Scenario: Assign agreement
    Given path '/erm/sas'
    And headers jsonHeaders
    And request read(samplesPath + 'agreements.json')
    When method POST
    Then status 201
    * setSystemProperty(recordType + '-AGREEMENT', response.id)

  @Ignore
  @SetupNoteType
  Scenario: Create note-type
    Given path '/note-types'
    And headers jsonHeaders
    And request '{ "name": "Karate Note Type" }'
    When method POST
    Then status 201
    * def noteTypeId = response.id
    * setSystemProperty('noteTypeId', noteTypeId)

