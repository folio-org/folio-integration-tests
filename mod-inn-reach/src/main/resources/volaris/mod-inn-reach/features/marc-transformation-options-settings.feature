@parallel=false
Feature: MARC transformation options settings

  Background:
    * url baseUrl + '/inn-reach/central-servers'
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]
    * def notExistedCentralServerId1 = globalCentralServerId1

  @create
  Scenario: Create MARC transformation options settings
    * print 'Create MARC transformation options settings'
    Given path centralServer1.id + '/marc-transformation-options'
    And request read(samplesPath + 'marc-transformation-options/create-marc-transformation-options.json')
    When method POST
    Then status 201

    * def ResponseMARCTransformation = $
    And match ResponseMARCTransformation.configIsActive == true
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].resourceIdentifierTypeId == "d8bd646c-5371-4167-9f66-cd6922f93eb8"

  Scenario: Attempting to create MARC transformation options settings that already exist
    * print 'Attempting to create MARC transformation options for negative scenario'
    * def marc = read(samplesPath + 'marc-transformation-options/create-marc-transformation-options.json')
    Given path centralServer1.id + '/marc-transformation-options'
    And request marc
    When method POST
    Then status 500

  @get
  Scenario: Get MARC transformation options settings by central server id
    * print 'Get MARC transformation options settings by central server id'
    Given path centralServer1.id + '/marc-transformation-options'
    When method GET
    Then status 200
    * def ResponseMARCTransformation = $
    And match ResponseMARCTransformation.configIsActive == true
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].resourceIdentifierTypeId == "d8bd646c-5371-4167-9f66-cd6922f93eb8"
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].stripPrefix == true
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[1].resourceIdentifierTypeId == "de5d0b47-f3fe-4d3d-a648-6d241e5df98e"
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[1].stripPrefix == false

  Scenario: Check not existed MARC transformation options settings by central server id
    * print 'Check not existed MARC transformation options settings by central server id'
    Given path notExistedCentralServerId1 + '/marc-transformation-options'
    When method GET
    Then status 404

  @update
  Scenario: Update MARC transformation options settings
    * print 'Update MARC transformation options settings by central server id'
    * def marc = read(samplesPath + 'marc-transformation-options/update-marc-transformation-options.json')
    Given path centralServer1.id + '/marc-transformation-options'
    And request marc
    When method PUT
    Then status 204

    Given path centralServer1.id + '/marc-transformation-options'
    When method GET
    Then status 200
    * def ResponseMARCTransformation = $
    And match ResponseMARCTransformation.configIsActive == true
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].resourceIdentifierTypeId == "d8bd646c-5371-4167-9f66-cd6922f93eb8"
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].stripPrefix == false
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].ignorePrefixes[0] == "FAA"
    And match ResponseMARCTransformation.modifiedFieldsForContributedRecords[0].ignorePrefixes[1] == "fog"

  Scenario: Attempting to update MARC transformation options settings by invalid central server id
    * print 'Attempting to update MARC transformation options settings by invalid central server id'
    Given path notExistedCentralServerId1 + '/marc-transformation-options'
    And request read(samplesPath + 'marc-transformation-options/update-marc-transformation-options.json')
    When method PUT
    Then status 404

  @delete
  Scenario: Delete MARC transformation options settings by central server id
    * print 'Delete MARC transformation options settings by central server id'
    Given path centralServer1.id + '/marc-transformation-options'
    When method DELETE
    Then status 204

    Given path centralServer1.id + '/marc-transformation-options'
    When method GET
    Then status 404

  Scenario: Check deleted MARC transformation options settings by central server id
    * print 'Check deleted MARC transformation options settings by central server id'
    Given path centralServer1.id + '/marc-transformation-options'
    When method DELETE
    Then status 404

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')