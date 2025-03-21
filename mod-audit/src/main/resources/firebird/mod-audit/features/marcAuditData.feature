Feature: Audit log for MARC Bib record changes

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def samplesPath = 'classpath:firebird/mod-audit/features/samples/'
    * def snapshotPath = samplesPath + 'FAT-17478/snapshot.json'
    * def recordPath = samplesPath + 'FAT-17478/record.json'
    * def instanceHrid = 'inst000000000001'
    * def instanceId = uuid()


  # This function will be called with different parameters
  # recordType: "MARC_BIB" or "MARC_AUTHORITY"
  # auditPath: "audit-data/marc/bib" or "audit-data/marc/authority"
  @Ignore
  @CreateRecordAndValidateAuditLogs
  Scenario: create record and validate audit logs
    * def recordType = __arg.recordType
    * def auditPath = __arg.auditPath

    # Create snapshot
    * def snapshotId = uuid()
    * def snapshot = read(snapshotPath)
    * snapshot.jobExecutionId = snapshotId

    Given path 'source-storage', 'snapshots'
    And request snapshot
    When method POST
    Then status 201

    # Create MARC Bib record
    * def recordId = uuid()
    * def record = read(recordPath)
    * record.id = recordId
    * record.snapshotId = snapshotId

    Given path 'source-storage', 'records'
    And request record
    When method POST
    Then status 201
    * def record = response

    # First Update - Add a field
    * record.generation = record.generation + 1
    * record.parsedRecord.content.fields.push({ "260": { "ind1": " ", "ind2": " ", "subfields": [ { "a": "New Publisher" } ] } })
    Given path 'source-storage', 'records', recordId
    And request record
    When method PUT
    Then status 200
    * def record = response

    # Second Update - Remove a field
    * record.generation = record.generation + 1
    * record.parsedRecord.content.fields = karate.filter(record.parsedRecord.content.fields, function(f){ return !f.hasOwnProperty("260") })
    Given path 'source-storage', 'records', recordId
    And request record
    When method PUT
    Then status 200
    * def record = response

    # Third Update - Modify an existing field
    * record.generation = record.generation + 1
    * record.parsedRecord.content.fields = karate.map(record.parsedRecord.content.fields, function(f){ return f["001"] ? { "001": { "ind1": " ", "ind2": " ", "subfields": [ { "a": "Updated Control Number" } ] } } : f })
    Given path 'source-storage', 'records', recordId
    And request record
    When method PUT
    Then status 200
    * def record = response

    # Fourth Update - Modify repeatable fields
    * record.generation = record.generation + 1
    * record.parsedRecord.content.fields = karate.map(record.parsedRecord.content.fields, function(f){ if (f["700"]) { f["700"].subfields = karate.map(f["700"].subfields, function(sf) { if (sf["a"] == "Hassanieh, Haitham") { sf["a"] = "Updated Name" } return sf }) } return f })
    Given path 'source-storage', 'records', recordId
    And request record
    When method PUT
    Then status 200

    * call pause 10000

    # Validate audit logs
    Given path auditPath, recordId
    When method GET
    Then status 200

    # Verify the status of the item with action 'CREATED'
    * def createdItem = karate.filter(response.marcAuditItems, function(x){ return x.action == 'CREATED' })[0]
    And match createdItem != null

    # Verify the field changes and collection changes for 'UPDATED' actions
    * def updatedItems = karate.filter(response.marcAuditItems, function(x){ return x.action == 'UPDATED' })

    # Verify First Update
    * def firstUpdate = updatedItems[3]
    And match firstUpdate.diff.fieldChanges[0].changeType == 'ADDED'
    And match firstUpdate.diff.fieldChanges[0].fieldName == '260'
    And match firstUpdate.diff.fieldChanges[0].newValue == '   $a New Publisher'

    # Verify Second Update
    * def secondUpdate = updatedItems[2]
    And match secondUpdate.diff.fieldChanges[0].changeType == 'REMOVED'
    And match secondUpdate.diff.fieldChanges[0].fieldName == '260'
    And match secondUpdate.diff.fieldChanges[0].oldValue == '   $a New Publisher'

    # Verify Third Update
    * def thirdUpdate = updatedItems[1]
    And match thirdUpdate.diff.fieldChanges[0].changeType == 'MODIFIED'
    And match thirdUpdate.diff.fieldChanges[0].fieldName == '001'
    And match thirdUpdate.diff.fieldChanges[0].newValue == '   $a Updated Control Number'

    # Verify Fourth Update
    * def fourthUpdate = updatedItems[0]
    And match fourthUpdate.diff.collectionChanges[0].collectionName == '700'
    And match fourthUpdate.diff.collectionChanges[0].itemChanges[0].changeType == 'REMOVED'
    And match fourthUpdate.diff.collectionChanges[0].itemChanges[0].oldValue == '1  $a Hassanieh, Haitham $e VeranstalterIn $4 orm'
    And match fourthUpdate.diff.collectionChanges[0].itemChanges[1].changeType == 'ADDED'
    And match fourthUpdate.diff.collectionChanges[0].itemChanges[1].newValue == '1  $a Updated Name $e VeranstalterIn $4 orm'

  Scenario: Validate MARC_BIB Audit Logs
    * call read('@CreateRecordAndValidateAuditLogs') { recordType: 'MARC_BIB', auditPath: 'audit-data/marc/bib' }

  Scenario: Validate MARC_AUTHORITY Audit Logs
    * call read('@CreateRecordAndValidateAuditLogs') { recordType: 'MARC_AUTHORITY', auditPath: 'audit-data/marc/authority' }