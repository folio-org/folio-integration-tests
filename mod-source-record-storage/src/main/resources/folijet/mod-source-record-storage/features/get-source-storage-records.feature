Feature: Source-Record-Storage

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get storage records
    Given path 'source-storage', 'records'
    When method GET
    Then status 200

  @Undefined
  Scenario: Test creating snapshots and records linked to different snapshots
    * print 'Create snapshot 1, create snapshot 2, create MARC records linked to different snapshots, get collections of records filtered by snapshot'

  @Undefined
  Scenario: Test creating and ordering records
    * print 'Create snapshot, create multiple EDIFACT records with order values filled in, get collection filtered by snapshot and ordered, verify correct order'

  @Undefined
  Scenario: Test return existing record on GET by id
    * print 'Create snapshot, create record, GET record by id'

  @Undefined
  Scenario: Test update of an existing record
    * print 'Create snapshot, save record, update record'

  @Undefined
  Scenario: Test filtering by record type
    * print 'Create snapshots, save records with different types linked to multiple snapshots, get collection filtered by record type'

  @Undefined
  Scenario: Test creating error record if parsed content is invalid
    * print 'Create snapshot, try to save record with invalid parsed content - verify error record is created'

  @Undefined
  Scenario: Test suppress from discovery
    * print 'Create snapshot, create record with external id holder value, suppress record from discovery'

  @Undefined
  Scenario: Test suppress from discovery - negative case
    * print 'Create snapshot 1, create record, try to suppress record from discovery - verify not fount error by external id'

  @Undefined
  Scenario: Test calculation of records generation
    * print 'Create snapshot, create record, mark snapshot committed, create another snapshot, save record with the same matched id, verify records generation'

  @Undefined
  Scenario: Test records generation is not calculated if snapshot is not committed
    * print 'Create snapshot, create record, create another snapshot, save record with the same matched id, verify records generation'

  @Undefined
  Scenario: Test return of record by external id
    * print 'Create snapshot, create record with external id, find record by external id'
