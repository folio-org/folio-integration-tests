Feature: init srs data feature

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def prepareRecord = function(record, recordId, snapshotId, instanceId) {return record.replaceAll("replace_recordId", recordId).replaceAll("replace_snapshotId", snapshotId).replaceAll("replace_instanceId", instanceId);}

    @PostSnapshot
    Scenario: create snapshot
      * def snapshot = { 'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS' }
      Given path 'source-storage/snapshots'
      And request snapshot
      When method POST
      Then status 201

    @PostRecord
    Scenario: create srs record
      * string recordTemplate = read('classpath:samples/marc_record.json')
      * def record = prepareRecord(recordTemplate, recordId, snapshotId, instanceId)
      Given path 'source-storage/records'
      And request record
      When method POST
      Then status 201

