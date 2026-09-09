@parallel=false
Feature: FAT-26991 Delete MARC Authority record using the default delete job profile

  # UXPROD-4627 - delete authority records via data import.
  # Imports a single exported MARC authority record through the shipped
  # "Default - Delete MARC Authority records" job profile, and
  # verifies the record is deleted

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature'
    * def javaWriteData = Java.type('test.java.WriteData')

    # Shipped "Default - Delete MARC Authority records" job profile
    * def defaultDeleteAuthorityJobProfileId = '1a338fcd-3efc-4a03-b007-394eeb0d5fb9'

    # Identifies everything this run creates, so parallel runs and re-runs never match each other's records
    * def runId = epoch + randomString(5)
    * configure retry = { count: 30, interval: 5000 }

  @C1434631
  Scenario: Delete a MARC Authority record via data import using the default delete job profile
    # The shared seed creates three authorities; this scenario deletes only the unlinked one, so the
    # delete job processes exactly one record
    * def seed = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def authorityId = seed.unlinkedAuthorityId
    * def recordId = seed.unlinkedRecordId

    # Export the record to be deleted
    * def authorityIdsToExport = ['#(authorityId)']
    * def exportFileName = 'FAT-26991-default-export-' + runId
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }

    * def deleteFileName = 'FAT-26991-default-delete-' + runId
    * javaWriteData.writeByteArrayToFile(exported.exportedBinaryMarcRecord, 'target/' + deleteFileName + '.mrc')

    # Import through the default delete job profile
    * def jobProfileId = defaultDeleteAuthorityJobProfileId
    Given call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    Then match status != 'ERROR'
    * def deleteJobExecutionId = jobExecutionId

    # Exactly one record is reported as deleted
    Given path 'metadata-provider/jobLogEntries', deleteJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 1
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == 'DELETED'
    And match response.entries[0].relatedAuthorityInfo.actionStatus == 'DELETED'
    And match response.entries[0].relatedAuthorityInfo.idList contains authorityId

    # The authority can no longer be retrieved
    Given path 'authority-storage/authorities', authorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # ... but is still returned when deleted authorities are requested
    Given path 'authority-storage/authorities'
    And param deleted = true
    And param query = 'id==' + authorityId
    And headers headersUser
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.authorities[0].id == authorityId

    # The SRS record is marked deleted
    Given path 'source-storage/records', recordId
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.deleted == true
    And match response.state == 'DELETED'
    And match response.leaderRecordStatus == 'd'
