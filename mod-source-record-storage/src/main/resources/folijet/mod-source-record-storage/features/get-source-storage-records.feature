Feature: Source-Record-Storage

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }

    * def samplesPath = 'classpath:folijet/mod-source-record-storage/features/samples/'
    * def snapshotPath = samplesPath + 'snapshot.json'
    * def recordPath = samplesPath + 'record.json'
    * def recordWith999fieldPath = samplesPath + 'recordWith999field.json'
    * def errorRecordPath = samplesPath + 'errorRecord.json'
    * def postInstanceFeature = read('classpath:folijet/mod-source-record-storage/features/global/postToInventory.feature')

    * def instanceId = uuid()
    * def hrId = 'inst000000000001'

  Scenario: Create Instance Type
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
     {
            "id": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
            "name": "text",
            "code": "txt",
            "source": "rdacontent"
     }
    """
    When method POST

  Scenario: Get storage records
    Given path 'source-storage', 'records'
    When method GET
    Then status 200

  Scenario: Test creating snapshots and records linked to different snapshots
    * print 'Create snapshot 1, create snapshot 2, create MARC records linked to different snapshots, get collections of records filtered by snapshot'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)

    * def recordId = uuid()
    * def record2 = read(recordWith999fieldPath)

    * def snapshotId = uuid()
    * def snapshot2 = read(snapshotPath)

    * def recordId = uuid()
    * def record3 = read(recordWith999fieldPath)
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create snapshot 2
    Given path 'source-storage','snapshots'
    And request snapshot2
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Create record 2
    Given path 'source-storage','records'
    And request record2
    When method POST
    Then status 201
    #   Create record 3
    Given path 'source-storage','records'
    And request record3
    When method POST
    Then status 201
    #   Get collections of records filtered by snapshot
    Given path 'source-storage', 'records'
    And param snapshotId = snapshot1.jobExecutionId
    When method GET
    Then status 200
    And match response.records == '#[]? _.snapshotId == snapshot1.jobExecutionId'

  Scenario: Test creating and ordering records
    * print 'Create snapshot, create multiple EDIFACT records with order values filled in, get collection filtered by snapshot and ordered, verify correct order'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    * record1.order = 1

    * def recordId = uuid()
    * def record2 = read(recordWith999fieldPath)
    * record2.order = 2
    * record2.recordType = 'EDIFACT'

    * def recordId = uuid()
    * def record3 = read(recordWith999fieldPath)
    * record3.order = 3
    * record3.recordType = 'EDIFACT'

    * def recordId = uuid()
    * def record4 = read(recordWith999fieldPath)
    * record4.order = 4
    * record4.recordType = 'EDIFACT'

    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 3
    Given path 'source-storage','records'
    And request record3
    When method POST
    Then status 201
    #   Create record 2
    Given path 'source-storage','records'
    And request record2
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Create record 4
    Given path 'source-storage','records'
    And request record4
    When method POST
    Then status 201
    #   Get collection filtered by snapshot and ordered, verify correct order
    Given path 'source-storage', 'records'
    And param snapshotId = snapshotId
    And param recordType = 'EDIFACT'
    And param orderBy = 'order,ASC'
    When method GET
    Then status 200
    And assert response.records[0].order <= response.records[1].order
    And assert response.records[1].order <= response.records[2].order

  Scenario: Test return existing record on GET by id
    * print 'Create snapshot, create record, GET record by id'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Get record by id
    Given path 'source-storage', 'records', recordId
    When method GET
    Then status 200
    And assert response.snapshotId == snapshotId
    And assert response.id == recordId

  Scenario: Test update of an existing record
    * print 'Create snapshot, save record, update record'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    * record1.order = 2
    #   Update record
    Given path 'source-storage', 'records', recordId
    And request record1
    When method PUT
    Then status 200
    #   Get record
    Given path 'source-storage', 'records', recordId
    When method GET
    Then status 200
    And assert response.order == 2

  Scenario: Test filtering by record type
    * print 'Create snapshots, save records with different types linked to multiple snapshots, get collection filtered by record type'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)

    * def recordId = uuid()
    * def record2 = read(recordWith999fieldPath)
    * record2.recordType = 'MARC_HOLDING'

    * def recordId = uuid()
    * def record3 = read(recordWith999fieldPath)

    * def snapshotId = uuid()
    * def snapshot2 = read(snapshotPath)

    * def recordId = uuid()
    * def record4 = read(recordWith999fieldPath)
    * record4.recordType = 'MARC_HOLDING'
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create snapshot 2
    Given path 'source-storage','snapshots'
    And request snapshot2
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Create record 3
    Given path 'source-storage','records'
    And request record3
    When method POST
    Then status 201
    #   Create record 2
    Given path 'source-storage','records'
    And request record2
    When method POST
    Then status 201
    #   Create record 4
    Given path 'source-storage','records'
    And request record4
    When method POST
    Then status 201
    #   Get records
    Given path 'source-storage', 'records'
    And param recordType = "MARC_HOLDING"
    When method GET
    Then status 200
    And assert response.totalRecords == 2

  Scenario: Test creating error record if parsed content is invalid
    * print 'Create snapshot, try to save record with invalid parsed content - verify error record is created'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(errorRecordPath)
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    # Get record by id
    Given path 'source-storage', 'records', recordId
    When method GET
    Then status 200
    And assert response.id == recordId
    And match response.errorRecord == '#notnull'

  Scenario: Test suppress from discovery
    * print 'Create snapshot, create record with external id holder value, suppress record from discovery'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    # Suppress record from discovery
    Given path 'source-storage', 'records', recordId, 'suppress-from-discovery'
    When method PUT
    Then status 200

  Scenario: Test suppress from discovery - negative case
    * print 'Create snapshot 1, create record, try to suppress record from discovery - verify not fount error by external id'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Try to suppress record from discovery - verify not fount error by external id
    Given path 'source-storage','records',uuid(),'suppress-from-discovery'
    When method PUT
    Then status 404

  Scenario: Test calculation of records generation
    * def instanceId = uuid()
    * def hrId = 'inst000000000019'
    * def instanceHrid = 'in' + ("00000000000" + Math.floor(Math.random() * 10000000000)).slice(-11)
    Given call postInstanceFeature

    * print 'Create snapshot, create record, mark snapshot committed, create another snapshot, save record with the same matched id, verify records generation'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordPath)

    * def snapshotId = uuid()
    * def snapshot2 = read(snapshotPath)

    * def recordId = uuid()
    * def record2 = read(recordPath)
    * record2.matchedId = record1.id
      #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Mark snapshot committed
    * snapshot1.status = 'COMMITTED'
    Given path 'source-storage','snapshots',snapshot1.jobExecutionId
    And request snapshot1
    When method PUT
    Then status 200
    #   Create snapshot 2
    * snapshot2.processingStartedDate =  plusSecond(response.metadata.updatedDate)
    Given path 'source-storage','snapshots'
    And request snapshot2
    When method POST
    Then status 201
    #   Create record 2
    * record2.generation = null
    Given path 'source-storage','records'
    And request record2
    When method POST
    Then status 201
    #   Verify records generation
    Given path 'source-storage', 'records', recordId
    When method GET
    Then status 200
    And assert response.generation == 1

  Scenario: Test return error for duplicate records if snapshot is not committed
    * def instanceId = uuid()
    * def hrId = 'inst000000000020'
    Given call postInstanceFeature

    * print 'Create snapshot, create record, create another snapshot, save record with the same matched id, verify records generation'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordPath)

    * def snapshotId = uuid()
    * def snapshot2 = read(snapshotPath)

    * def recordId = uuid()
    * def record2 = read(recordPath)
    * record2.matchedId = record1.id
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Create snapshot 2
    Given path 'source-storage','snapshots'
    And request snapshot2
    When method POST
    Then status 201
    #   Create record 2
    Given path 'source-storage','records'
    And request record2
    When method POST
    Then status 500

    Given path 'source-storage', 'records', record1.id
    When method GET
    Then status 200
    And assert response.generation == 0

  Scenario: Test return of record by external id
    * print 'Create snapshot, create record with external id, find record by external id'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    * def externalId = uuid()
    * record1.externalIdsHolder.instanceId = externalId
    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Find record by external id
    Given path 'source-storage', 'source-records'
    And param externalId = externalId
    When method GET
    Then status 200
    And assert response.totalRecords == 1

  Scenario: Test return of deleted record by id
    * print 'Create snapshot, create record, delete snapshot, find deleted record by id'
    * def snapshotId = uuid()
    * def snapshot1 = read(snapshotPath)

    * def recordId = uuid()
    * def record1 = read(recordWith999fieldPath)
    * record1.externalIdsHolder.instanceId = uuid()

    #   Create snapshot 1
    Given path 'source-storage','snapshots'
    And request snapshot1
    When method POST
    Then status 201
    #   Create record 1
    Given path 'source-storage','records'
    And request record1
    When method POST
    Then status 201
    #   Delete record 1
    Given path 'source-storage', 'records', recordId
    When method DELETE
    Then status 204
    #   Not found deleted record with default state
    Given path 'source-storage', 'source-records', recordId
    When method GET
    Then status 200
    And assert response.additionalInfo.suppressDiscovery == true
    #   Find deleted record by matched id
    Given path 'source-storage', 'source-records', recordId
    And param state = 'DELETED'
    When method GET
    Then status 200
    And assert response.deleted == true
