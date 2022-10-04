Feature: init data for mod-entities-links

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples'

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

  @PostAuthority
  Scenario: Create authority record
    * def authority = read(samplePath + '/setup-records/authority.json')
    * authority.id = karate.get('extAuthority')
    Given path 'authority-storage/authorities'
    And request authority
    When method POST
    Then status 201

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