Feature: init data for mod-entities-links

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples'

  @Setup
  Scenario: Setup
    * def instanceId = call uuid
    * def sourceFileId = 'c95e6fa1-f3b1-4db6-ba05-1fb6e6c80599'
    * def firstAuthorityId = call uuid
    * def secondInstanceId = call uuid
    * def secondAuthorityId = call uuid
    * def snapshotId = '7dbf5dcf-f46c-42cd-924b-04d99cd410b9'

    * call read(utilPath + '@PostInstanceType')
    * call read(utilPath + '@PostSnapshot')
    * call read(utilPath + '@PostInstance') { extInstanceId: #(instanceId)}
    * call read(utilPath + '@PostInstance') { extInstanceId: #(secondInstanceId)}
    * call read(utilPath + '@PostAuthoritySourceFile') { extSourceFileId: #(sourceFileId)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(firstAuthorityId), extSourceFileId: #(sourceFileId)}
    * call read(utilPath + '@PostAuthority') { extAuthorityId: #(secondAuthorityId), extSourceFileId: #(sourceFileId)}

  @PostInstanceType
  Scenario: Create instance type
    Given path 'instance-types'
    And request read(samplePath + '/setup-records/instance-type.json')
    When method POST
    Then status 201

  @PostSnapshot
  Scenario: Create snapshot
    Given path 'source-storage/snapshots'
    And request {'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS'}
    When method POST
    Then status 201

  @PostInstance
  Scenario: Create instance record
    * def intInstanceId = karate.get('extInstanceId', instanceId)
    * def instance = read(samplePath + '/setup-records/instance.json')
    * instance.id = intInstanceId
    Given path 'instance-storage/instances'
    And request instance
    When method POST
    Then status 201

  @PostAuthoritySourceFile
  Scenario: Create authority source file
    * def sourceFileId = karate.get('extSourceFileId', uuid())
    * def path = karate.get('filePath', '/setup-records/authority/source-files/authority-source-file1.json')
    * def dto = read(samplePath + path)

    Given path '/authority-source-files'
    And request dto
    When method POST
    Then status 201

  @PostAuthority
  Scenario: Create authority record
    * def sourceFileId = karate.get('extSourceFileId')
    * def authorityId = karate.get('extAuthorityId', uuid())
    * def path = karate.get('authorityPath', '/setup-records/authority/authority.json')
    * def dto = read(samplePath + path)
    Given path 'authority-storage/authorities'
    And request dto
    When method POST
    Then status 201

  @CreateMarcAuthority
  Scenario: Create authority record
    * def authorityId = karate.get('extAuthority')
    * def recordId = uuid()
    Given path 'source-storage/records'
    And request read(samplePath + '/setup-records/marc-authority.json')
    When method POST
    Then status 201

    * setSystemProperty('recordId', recordId)

  @PutInstanceLinks
  Scenario: Update instance-authority links collection
    * def link = karate.get('extRequestBody')
    Given path '/links/instances', karate.get('extInstanceId')
    And request link
    When method PUT
    Then status 204

  @GetInstanceLinks
  Scenario: Get instance-authority links collection
    Given path '/links/instances', karate.get('extInstanceId')
    When method GET
    Then status 200
    Then assert response.links.length > 0
    Then assert response.totalRecords > 0

  @RemoveLinks
  Scenario: Put link - Should remove all links for instance
    Given path '/links/instances', karate.get('extInstanceId')
    And request {'links': [] }
    When method PUT
    Then status 204

  @PostCountLinks
  Scenario: Count instance-authority links by authority ids
    * def ids = karate.get('extIds')
    Given path '/links/authorities/bulk/count'
    And request ids
    When method POST
    Then status 200

  @TryPutInstanceLinks
  Scenario: Try to update instance-authority links collection for
    * def link = karate.get('extRequestBody')
    Given path '/links/instances', karate.get('extInstanceId')
    And request link
    When method PUT
    Then status 422