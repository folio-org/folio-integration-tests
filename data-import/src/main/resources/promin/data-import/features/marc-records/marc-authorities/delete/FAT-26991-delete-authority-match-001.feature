@parallel=false
Feature: FAT-26991 Delete MARC Authority records matched by 001

  # UXPROD-4627 - delete authority records via data import.
  # A job profile puts the shipped "Default - Delete MARC Authority records" action profile under a
  # match profile on 001. The imported file carries three records: one authority that is linked to
  # a bib and one that is not - both match and must be deleted - plus one that does not match and must
  # survive. The bib linked to the deleted authority must end up unlinked.

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

  @C1504476
  Scenario: Delete MARC Authority matched by 001
    # Seed two authorities that will be matched and deleted, and one that must survive
    * def seed = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def linkedAuthorityId = seed.linkedAuthorityId
    * def linkedRecordId = seed.linkedRecordId
    * def linkedControlNumber = seed.linkedControlNumber
    * def unlinkedAuthorityId = seed.unlinkedAuthorityId
    * def unlinkedRecordId = seed.unlinkedRecordId
    * def nonMatchAuthorityId = seed.nonMatchAuthorityId
    * def nonMatchControlNumber = seed.nonMatchControlNumber

    # Link a MARC bib to one of the authorities that is about to be deleted
    * def linked = call read(commonFeature + '@LinkBibToAuthority') { runId: '#(runId)', authorityId: '#(linkedAuthorityId)', authorityNaturalId: '#(linkedControlNumber)' }
    * def instanceId = linked.instanceId

    # Job profile: match on 001 -> Default - Delete MARC Authority records
    * def profiles = call read(commonFeature + '@CreateDeleteJobProfile') { runId: '#(runId)', profileName: 'FAT-26991 delete authority by 001', matchField: '001', matchSubfield: '', ind1: '', ind2: '' }
    * def jobProfileId = profiles.jobProfileId

    # Export all three authorities to build the file that will be re-imported with the delete action
    # Embedded expressions are required here: Karate parses a bare [a, b] as a JSON array of
    # string literals, which would send the variable names to data export instead of the ids
    * def authorityIdsToExport = ['#(linkedAuthorityId)', '#(unlinkedAuthorityId)', '#(nonMatchAuthorityId)']
    * def exportFileName = 'FAT-26991-export-' + runId
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }
    * def exportedFile = exported.exportedBinaryMarcRecord

    # Only the third record is made non-matching; the other two keep the values they were exported with
    # A 001 that no authority in the tenant carries
    * def deleteFile = javaWriteData.setFieldValueByControlNumber(exportedFile, nonMatchControlNumber, '001', ' ', 'FAT26991X' + runId)
    * def deleteFileName = 'FAT-26991-delete-' + runId
    * javaWriteData.writeByteArrayToFile(deleteFile, 'target/' + deleteFileName + '.mrc')

    Given call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    Then match status != 'ERROR'
    * def deleteJobExecutionId = jobExecutionId

    # Two matched records are reported as deleted, the non-matched one as discarded
    Given path 'metadata-provider/jobLogEntries', deleteJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 3
    When method GET
    Then status 200
    * def deletedEntries = response.entries.filter(e => e.relatedAuthorityInfo.actionStatus == 'DELETED')
    * def discardedEntries = response.entries.filter(e => e.relatedAuthorityInfo.actionStatus == 'DISCARDED')
    And match karate.sizeOf(deletedEntries) == 2
    And match karate.sizeOf(discardedEntries) == 1
    * def deletedAuthorityIds = karate.map(deletedEntries, function(e){ return e.relatedAuthorityInfo.idList[0] })
    And match deletedAuthorityIds contains linkedAuthorityId
    And match deletedAuthorityIds contains unlinkedAuthorityId
    And match deletedEntries[0].sourceRecordActionStatus == 'DELETED'
    And match discardedEntries[0].sourceRecordActionStatus == 'DISCARDED'

    # Both matched authorities are gone
    Given path 'authority-storage/authorities', linkedAuthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    Given path 'authority-storage/authorities', unlinkedAuthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # ... and their MARC records are marked deleted in SRS
    Given path 'source-storage/source-records', linkedRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200

    Given path 'source-storage/source-records', unlinkedRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200

    # The non-matched authority is untouched
    Given path 'authority-storage/authorities', nonMatchAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.id == nonMatchAuthorityId

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
