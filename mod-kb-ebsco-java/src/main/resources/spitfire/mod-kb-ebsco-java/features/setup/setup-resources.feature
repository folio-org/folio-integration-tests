Feature: Setup resources

  Background:
    * url baseUrl
    * callonce login testUser
    * def vndHeaders = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)'}
    * def jsonHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)'}
    * def samplesPath = 'classpath:spitfire/mod-kb-ebsco-java/features/setup/samples/'

    * def assignNote = 'setup-resources.feature@AssignNote'
    * def createNoteType = 'setup-resources.feature@SetupNoteType'
    * def assignAgreement = 'setup-resources.feature@AssignAgreement'
    * def createPackage = 'setup-resources.feature@CreatePackage'

  @SetupPackage
  Scenario: Create package without title
    * def packageName = "Folio-Karate Single Package"
    * def package = karate.call(createPackage);
    * setSystemProperty('freePackageId', package.id)

  @SetupResources
  Scenario: Create resources with Agreements and Notes
    * def packageName = "Folio-Karate Main Package"
    * def package = karate.call(createPackage);
    * def packageId = package.id

    Given path '/eholdings/titles'
    And headers vndHeaders
    And def titleName = "Folio-Karate Test Title"
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

  @CreatePackage
  @Ignore #accept packageName
  Scenario: Create package
    Given path '/eholdings/packages'
    And headers vndHeaders
    And request read(samplesPath + 'package.json')
    When method POST
    Then status 200
    * def id = response.data.id
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
    And request '{ "name": "Folio-Karate Note Type" }'
    When method POST
    Then status 201
    * def noteTypeId = response.id
    * setSystemProperty('noteTypeId', noteTypeId)

