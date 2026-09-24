Feature: Delete two MARC Authority records using a minimal exported records

  # C1504487 - Delete two MARC authority records via data import using the
  # "Default - Delete MARC Authority records" job profile (matches on 999 ff $s)
  # and using records with minimum required fields.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature'

    # Identifies everything this run creates, so parallel runs and re-runs never collide
    * def runId = epoch
    * configure retry = { count: 30, interval: 5000 }

  @C1504487
  Scenario: Delete two MARC authority records using records containing LDR, 100, 999 fields only
    # Call the util @SeedAuthorities scenario that creates three authorities records to ensure two existing
    # authority records. The current scenario is going to delete only two authority records: record A and record B
    * def seed = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def recordAauthorityId = seed.unlinkedAuthorityId
    * def recordArecordId = seed.unlinkedRecordId
    * def recordBauthorityId = seed.nonMatchAuthorityId
    * def recordBrecordId = seed.nonMatchRecordId

    # Export record A and record B together as a single .mrc file
    * def authorityIdsToExport = ['#(recordAauthorityId)', '#(recordBauthorityId)']
    * def exportFileName = 'C1504487-exported-' + runId
    * def exportRes = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }

    # Remove all fields except LDR, 100, and 999 to have records with minimum required fields only
    * def trimmedFile = javaWriteData.keepOnlyFields(exportRes.exportedBinaryMarcRecord, '100', '999')
    * def deleteFileName = 'C1504487-delete-' + runId
    * javaWriteData.writeByteArrayToFile(trimmedFile, 'target/' + deleteFileName + '.mrc')

    # Import the trimmed file using the "Default - Delete MARC Authority records" job profile
    * def jobProfileId = defaultDeleteAuthorityJobProfileId
    * def res = call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    * match res.jobExecution.status == 'COMMITTED'

    # Check job log entries to confirm that both records show "Deleted" for SRS MARC and Authority
    Given path 'metadata-provider/jobLogEntries', res.jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 2
    When method GET
    Then status 200
    And assert response.entries.length == 2
    And match each response.entries[*].sourceRecordActionStatus == 'DELETED'
    And match each response.entries[*].relatedAuthorityInfo.actionStatus == 'DELETED'
    And def deletedAuthorityIds = karate.jsonPath(response.entries, "$[*].relatedAuthorityInfo.idList[*]")
    And match deletedAuthorityIds contains recordAauthorityId
    And match deletedAuthorityIds contains recordBauthorityId

    # Verify record A authority is no longer found
    Given path 'authority-storage/authorities', recordAauthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # Verify record B authority is no longer found
    Given path 'authority-storage/authorities', recordBauthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # The SRS record A is marked deleted
    Given path 'source-storage/records', recordArecordId
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.deleted == true
    And match response.state == 'DELETED'
    And match response.leaderRecordStatus == 'd'

    # The SRS record B is marked deleted
    Given path 'source-storage/records', recordBrecordId
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.deleted == true
    And match response.state == 'DELETED'
    And match response.leaderRecordStatus == 'd'

