@parallel=false
Feature: FAT-26991 Delete MARC Authority records matched by 999 ff $s

  # UXPROD-4627 - delete authority records via data import.
  # Imports a file through a job profile where the shipped "Default - Delete MARC Authority records"
  # action profile sits under a match profile on 999 ff $s, and verifies that the matched authority is
  # deleted, the non-matched authority survives, and the bib linked to the deleted authority is unlinked.

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

  # TODO: TestRail case id - add @C<id> once the case exists
  Scenario: Delete MARC Authority matched by 999 ff $s
    # Seed one authority to be deleted and one that must survive the same job
    * def seed = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def targetAuthorityId = seed.targetAuthorityId
    * def targetRecordId = seed.targetRecordId
    * def targetControlNumber = seed.targetControlNumber
    * def controlAuthorityId = seed.controlAuthorityId
    * def controlControlNumber = seed.controlControlNumber

    # Link a MARC bib to the authority that is about to be deleted
    * def linked = call read(commonFeature + '@LinkBibToAuthority') { runId: '#(runId)', authorityId: '#(targetAuthorityId)', authorityNaturalId: '#(targetControlNumber)' }
    * def instanceId = linked.instanceId

    # Job profile: match on 999 ff $s -> Default - Delete MARC Authority records
    * def profiles = call read(commonFeature + '@CreateDeleteJobProfile') { runId: '#(runId)', profileName: 'FAT-26991 delete authority by 999 ff s', matchField: '999', matchSubfield: 's', ind1: 'f', ind2: 'f' }
    * def jobProfileId = profiles.jobProfileId

    # Export both authorities to build the file that will be re-imported with the delete action
    # Embedded expressions are required here: Karate parses a bare [a, b] as a JSON array of
    # string literals, which would send the variable names to data export instead of the ids
    * def authorityIdsToExport = ['#(targetAuthorityId)', '#(controlAuthorityId)']
    * def exportFileName = 'FAT-26991-export-' + runId
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }
    * def exportedFile = exported.exportedBinaryMarcRecord

    # Make the second record non-matching, so the same job carries a matched and a non-matched record
    # A random SRS record UUID that does not exist
    * def deleteFile = javaWriteData.setFieldValueByControlNumber(exportedFile, controlControlNumber, '999', 's', uuid())
    * def deleteFileName = 'FAT-26991-delete-' + runId
    * javaWriteData.writeByteArrayToFile(deleteFile, 'target/' + deleteFileName + '.mrc')

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    Then match status != 'ERROR'
    * def deleteJobExecutionId = jobExecutionId

    # The matched record is reported as deleted, the non-matched one as discarded
    Given path 'metadata-provider/jobLogEntries', deleteJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 2
    When method GET
    Then status 200
    * def deletedEntry = response.entries.find(e => e.relatedAuthorityInfo.actionStatus == 'DELETED')
    * def discardedEntry = response.entries.find(e => e.relatedAuthorityInfo.actionStatus == 'DISCARDED')
    And match deletedEntry != null
    And match discardedEntry != null
    And match deletedEntry.sourceRecordActionStatus == 'DELETED'
    And match deletedEntry.relatedAuthorityInfo.idList contains targetAuthorityId
    And match discardedEntry.sourceRecordActionStatus == 'DISCARDED'

    # The matched authority is gone
    Given path 'authority-storage/authorities', targetAuthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # ... and its MARC record is marked deleted in SRS
    Given path 'source-storage/source-records', targetRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.deleted == true

    # The non-matched authority is untouched
    Given path 'authority-storage/authorities', controlAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.id == controlAuthorityId

    # The bib linked to the deleted authority is unlinked
    Given path 'links/instances', instanceId
    And headers headersUser
    And retry until response.totalRecords == 0
    When method GET
    Then status 200
    And match response.links == []

    # ... and the $9 subfield is removed from its 100 field
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    And retry until karate.get("response.fields.find(f => f.tag == '100').linkDetails") == null
    When method GET
    Then status 200
    * def bibField100 = response.fields.find(f => f.tag == '100')
    And match bibField100.content !contains '$9'
    And match bibField100.linkDetails == '##null'
