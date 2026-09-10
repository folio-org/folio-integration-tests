@parallel=false
Feature: FAT-26991 Delete MARC Authority job summary reports deleted, no action and error

  # UXPROD-4627 - delete authority records via data import.
  # One delete job is given three incoming records that each end differently:
  #   Record A - matches exactly one authority                 -> deleted
  #   Record B - its authority was deleted beforehand          -> no action (discarded)
  #   Record C - its 010 $a is carried by two authorities      -> error (multiple matches)
  # The job summary must report one of each. metadata-provider/jobSummary is the API behind the
  # "Deleted", "No action" and "Error" rows of the Log details summary table.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature'
    * def javaWriteData = Java.type('test.java.WriteData')

    # Identifies everything this run creates, so parallel runs and re-runs never match each other's records
    * def runId = epoch + randomString(5)
    * configure retry = { count: 30, interval: 5000 }

  @C1504469
  Scenario: Job summary shows deleted, no action and error rows for one delete job
    # First seed supplies all three incoming records
    * def seedOne = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId + "a")' }
    * def recordAAuthorityId = seedOne.linkedAuthorityId
    * def recordBAuthorityId = seedOne.unlinkedAuthorityId
    * def recordCAuthorityId = seedOne.nonMatchAuthorityId

    # Second seed only exists to give Record C's 010 $a a duplicate, so that matching on 010 $a
    # finds two authorities and reports an error
    * def seedTwo = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId + "b")', nonMatchLccnOverride: '#(seedOne.nonMatchLccn)' }
    * def duplicateAuthorityId = seedTwo.nonMatchAuthorityId

    # Export the three records that will be imported with the delete action
    * def authorityIdsToExport = ['#(recordAAuthorityId)', '#(recordBAuthorityId)', '#(recordCAuthorityId)']
    * def exportFileName = 'FAT-26991-summary-export-' + runId
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }

    * def deleteFileName = 'FAT-26991-summary-delete-' + runId
    * javaWriteData.writeByteArrayToFile(exported.exportedBinaryMarcRecord, 'target/' + deleteFileName + '.mrc')

    # Record B is deleted before the import, so its incoming record matches nothing
    Given path 'authority-storage/authorities', recordBAuthorityId
    And headers headersUser
    When method DELETE
    Then status 204

    # Job profile: match on 010 $a -> Default - Delete MARC Authority records
    * def profiles = call read(commonFeature + '@CreateDeleteJobProfile') { runId: '#(runId)', profileName: 'FAT-26991 delete authority job summary', matchField: '010', matchSubfield: 'a', ind1: ' ', ind2: ' ' }
    * def jobProfileId = profiles.jobProfileId

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    Then match status != 'ERROR'
    * def deleteJobExecutionId = jobExecutionId

    # The summary reports one record in each of the three states. A record that ended in an error is
    # counted in totalDiscardedEntities as well as in totalErrors, so the "No action" row of the Log
    # details summary table is totalDiscardedEntities minus totalErrors - here 2 - 1 = 1 (Record B).
    Given path 'metadata-provider/jobSummary', deleteJobExecutionId
    And headers headersUser
    And retry until response.sourceRecordSummary.totalDeletedEntities == 1 && response.sourceRecordSummary.totalErrors == 1 && response.sourceRecordSummary.totalDiscardedEntities == 2
    When method GET
    Then status 200
    # Deleted row - Record A
    And match response.sourceRecordSummary.totalDeletedEntities == 1
    And match response.authoritySummary.totalDeletedEntities == 1
    # Error row - Record C, matched two authorities on 010 $a
    And match response.sourceRecordSummary.totalErrors == 1
    And match response.authoritySummary.totalErrors == 1
    # No action row - Record B, whose authority no longer exists
    And match response.sourceRecordSummary.totalDiscardedEntities == 2
    And match response.authoritySummary.totalDiscardedEntities == 2
    # match does not evaluate arithmetic on the left-hand side, so the derivation is computed first
    * def sourceRecordNoActionCount = response.sourceRecordSummary.totalDiscardedEntities - response.sourceRecordSummary.totalErrors
    * def authorityNoActionCount = response.authoritySummary.totalDiscardedEntities - response.authoritySummary.totalErrors
    And match sourceRecordNoActionCount == 1
    And match authorityNoActionCount == 1

    # The same three outcomes are visible per record in the job log
    Given path 'metadata-provider/jobLogEntries', deleteJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 3
    When method GET
    Then status 200
    * def deletedEntries = response.entries.filter(e => e.relatedAuthorityInfo.actionStatus == 'DELETED')
    * def erroredEntries = response.entries.filter(e => e.error != null && e.error != '')
    And match karate.sizeOf(deletedEntries) == 1
    And match karate.sizeOf(erroredEntries) == 1
    And match deletedEntries[0].relatedAuthorityInfo.idList contains recordAAuthorityId

    # Only Record A is gone
    Given path 'authority-storage/authorities', recordAAuthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # The pair that produced the error is untouched
    Given path 'authority-storage/authorities', recordCAuthorityId
    And headers headersUser
    When method GET
    Then status 200

    Given path 'authority-storage/authorities', duplicateAuthorityId
    And headers headersUser
    When method GET
    Then status 200
