Feature: init srs data feature

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
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

