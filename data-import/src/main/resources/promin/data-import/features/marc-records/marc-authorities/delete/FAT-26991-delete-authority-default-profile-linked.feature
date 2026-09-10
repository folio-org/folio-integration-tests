@parallel=false
Feature: FAT-26991 Delete a linked MARC Authority record using the default delete job profile

  # UXPROD-4627 - delete authority records via data import.
  # Imports a single exported MARC authority record that a MARC bib is linked to, through the shipped
  # "Default - Delete MARC Authority records" job profile, and verifies the authority is deleted and
  # the bib field is no longer linked.
  #
  # The default job profile carries its own match profile on 999 ff $s, so this also covers deletion
  # matched by 999 ff $s.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def commonFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature'
    * def javaWriteData = Java.type('test.java.WriteData')

    # Shipped "Default - Delete MARC Authority records" job profile, which matches on 999 ff $s
    * def defaultDeleteAuthorityJobProfileId = '1a338fcd-3efc-4a03-b007-394eeb0d5fb9'

    # Identifies everything this run creates, so parallel runs and re-runs never match each other's records
    * def runId = epoch + randomString(5)
    * configure retry = { count: 30, interval: 5000 }

  @C1504474
  Scenario: Delete a MARC Authority record linked to a bib using the default delete job profile
    # The shared seed creates three authorities; only the linked one is exported and deleted here,
    # so the delete job processes exactly one record
    * def seed = call read(commonFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def authorityId = seed.linkedAuthorityId
    * def recordId = seed.linkedRecordId
    * def authorityControlNumber = seed.linkedControlNumber

    # Link a MARC bib to the authority that is about to be deleted
    * def linked = call read(commonFeature + '@LinkBibToAuthority') { runId: '#(runId)', authorityId: '#(authorityId)', authorityNaturalId: '#(authorityControlNumber)' }
    * def instanceId = linked.instanceId

    # Export the record to be deleted
    * def authorityIdsToExport = ['#(authorityId)']
    * def exportFileName = 'FAT-26991-default-linked-export-' + runId
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }

    * def deleteFileName = 'FAT-26991-default-linked-delete-' + runId
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

    # ... and its MARC record is marked deleted in SRS
    Given path 'source-storage/records', recordId
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.state == 'DELETED'

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
