Feature: Setup quickMARC

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/setup/samples/'

    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'
    * def instanceId = '337d160e-a36b-4a2b-b4c1-3589f230bd2c'
    * def sourceId = '036ee84a-6afd-4c3c-9ad3-4a12ab875f59'
    * def instanceHrid = 'in00000000001'
    * def linkedAuthorityId = 'e7537134-0724-4720-9b7d-bddec65c0fad'
    * def authorityNaturalId = 'n00001263'

  Scenario: Setup locations
    Given path 'location-units/institutions'
    And headers headersUser
    And request read(samplePath + 'locations/institution.json')
    When method POST

    Given path 'location-units/campuses'
    And headers headersUser
    And request read(samplePath + 'locations/campus.json')
    When method POST

    Given path 'location-units/libraries'
    And headers headersUser
    And request read(samplePath + 'locations/library.json')
    When method POST

    Given path 'locations'
    And headers headersUser
    And request read(samplePath + 'locations/location.json')
    When method POST

  @SetupTypes
  Scenario: Setup record types
    Given path 'holdings-sources'
    And headers headersUser
    And request
    """
      {
       "id": "#(sourceId)",
       "name": "MARC"
      }
    """
    When method POST

    Given path 'instance-types'
    And headers headersUser
    And request read(samplePath + 'record-types/instance-type.json')
    When method POST

    Given path 'holdings-types'
    And headers headersUser
    And request read(samplePath + 'record-types/holdings-type.json')
    When method POST

  @CreateSnapshot
  Scenario: Create snapshot
    Given path 'source-storage/snapshots'
    And request { 'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS' }
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('snapshotId', snapshotId)

  Scenario: Create Authority Source FIle
    Given path 'authority-source-files'
    And request read(samplePath + 'setup-records/authority-source-file.json')
    And headers headersUser
    When method POST
    Then status 201

  Scenario: Create MARC-AUTHORITY records
    * call read('setup.feature@CreateAuthority') {recordName: 'authorityId'}
    * call read('setup.feature@CreateAuthority') {recordName: 'authorityIdForDelete'}
    * call read('setup.feature@CreateAuthority') {recordName: 'linkedAuthorityId', id: #(linkedAuthorityId)}

  Scenario: Create MARC-BIB record
    * call read('setup.feature@CreateMarcBib') {id: #(instanceId), hrid: #(instanceHrid)}
    * setSystemProperty('instanceId', instanceId)

  Scenario: Create MARC-HOLDINGS record
    * def holdingsId = uuid()
    Given path 'holdings-storage/holdings'
    And request read(samplePath + 'setup-records/holdings.json')
    And headers headersUser
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + 'setup-records/marc-holdings.json')
    And headers headersUser
    When method POST
    Then status 201

    * setSystemProperty('holdingsId', holdingsId)

  Scenario: Create Instance-Authority links
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def linkContent = ' $0 ' + authorityNaturalId + ' $9 ' + linkedAuthorityId
    * def tag100 = {"tag": "100", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","1"], "linkDetails":{ "authorityId": #(linkedAuthorityId),"authorityNaturalId": #(authorityNaturalId), "linkingRuleId": 1} }
    * def tag110 = {"tag": "240", "content":'#("$a Johnson" + linkContent)', "indicators": ["\\","\\"], "linkDetails":{ "authorityId": #(linkedAuthorityId),"authorityNaturalId": #(authorityNaturalId), "linkingRuleId": 5} }

    * record.fields.push(tag100)
    * record.fields.push(tag110)
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    * setSystemProperty('authorityNaturalId', authorityNaturalId)

  @Ignore #Util scenario, accept 'id', 'hrid' parameters
  @CreateMarcBib
  Scenario: Create Instance and MARC-BIB record
    * def instanceId = id
    * def instanceHrid = hrid
    Given path 'instance-storage/instances'
    And request read(samplePath + 'setup-records/instance.json')
    And headers headersUser
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + 'setup-records/marc-bib.json')
    And headers headersUser
    When method POST
    Then status 201

  @Ignore #Util scenario, accept 'recordName' parameter
  @CreateAuthority
  Scenario: Create MARC-AUTHORITY record
    * def authorityId = karate.get('id', uuid())
    Given path 'authority-storage/authorities'
    And request read(samplePath + 'setup-records/authority.json')
    And headers headersUser
    When method POST
    Then status 201

    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + 'setup-records/marc-authority.json')
    And headers headersUser
    When method POST
    Then status 201
    * def externalId = response.externalIdsHolder.authorityId

    And eval if (typeof recordName != 'undefined') setSystemProperty(recordName, externalId)
