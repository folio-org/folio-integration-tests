Feature: init srs data feature

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * def prepareMarcBibRecord = function(record, recordId, snapshotId, instanceId) {return record.replaceAll("replace_recordId", recordId).replaceAll("replace_snapshotId", snapshotId).replaceAll("replace_instanceId", instanceId);}
    * def prepareMarcHoldingRecord = function(record, recordId, snapshotId, instanceId) {return record.replaceAll("replace_recordId", recordId).replaceAll("replace_snapshotId", snapshotId).replaceAll("replace_holdingId", holdingId);}

  @PostSnapshot
  Scenario: create snapshot
    * def snapshot = { 'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS' }
    Given path 'source-storage/snapshots'
    And request snapshot
    When method POST
    Then status 201

  @PostMarcBibRecord
  Scenario: create srs record
    * string recordTemplate = read('classpath:samples/marc_bib_record.json')
    * def record = prepareMarcBibRecord(recordTemplate, recordId, snapshotId, instanceId)
    Given path 'source-storage/records'
    And request record
    When method POST
    Then status 201

  @PostMarcHoldingRecord
  Scenario: create srs record
    * string recordTemplate = read('classpath:samples/marc_holding_record.json')
    * def record = prepareMarcHoldingRecord(recordTemplate, recordId, snapshotId, holdingId)
    Given path 'source-storage/records'
    And request record
    When method POST
    Then status 201

  @PostMarcAuthorityRecord
  Scenario: create srs record
    Given path 'source-storage/records'
    And request read('classpath:samples/marc_authority_record.json')
    When method POST
    Then status 201

  @PostMarcAuthorityRecord2
  Scenario: create srs record
    Given path 'source-storage/records'
    And request read('classpath:samples/marc_authority_record2.json')
    When method POST
    Then status 201

  @PostMarcAuthorityRecord3
  Scenario: create srs record
    Given path 'source-storage/records'
    And request read('classpath:samples/marc_authority_record3.json')
    When method POST
    Then status 201

  @PostMarcAuthorityRecord4
  Scenario: create srs record
    Given path 'source-storage/records'
    And request read('classpath:samples/marc_authority_record4.json')
    When method POST
    Then status 201