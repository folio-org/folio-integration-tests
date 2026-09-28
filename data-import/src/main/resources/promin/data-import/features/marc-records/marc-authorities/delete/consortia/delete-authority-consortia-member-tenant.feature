@parallel=false
Feature: Delete MARC Authority records in a Consortia environment via Data Import

  # Uses the shared "SeedAuthorities" util from authority-delete-common.feature to prepare
  # the two authority records described by the TestRail case:
  #   - Record A: the seed's "unlinked" authority - not linked to any bib field.
  #   - Record B: the seed's "linked" authority - linked to a bib's 100 field before deletion.
  # Both records are created in, exported from, and deleted from the university Member tenant,
  # through the "Default - Delete MARC Authority records" job profile. After deletion,
  # neither record is discoverable in the Member tenant,
  # and the MARC Bib field previously linked to Record B is no longer linked.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def authorityUtilFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature'

    # Shipped "Default - Delete MARC Authority records" job profile, which matches on 999 ff $s
    * def defaultDeleteAuthorityJobProfileId = '1a338fcd-3efc-4a03-b007-394eeb0d5fb9'

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }

    # Login under universityUser1 provides "okapitoken" variable to the context,
    # that is used by util import-record.feature@ImportRecord scenario
    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': '*/*' }
    * def universityHeadersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': '*/*' }

    # Declare testTenant, testUser, headersUser variables so every
    # data-import util features (auth.feature, import-record.feature, authority-delete-common.feature, etc.)
    # could operates against the university tenant instead of the default single tenant
    * def testTenant = universityTenant
    * def testUser = universityUser1
    * def headersUser = headersUniversity

    # Clear 'configure headers' made by initData.feature's Background (Content-Type: application/json),
    # so export-authority-record.feature's 'And headers headersUserOctetStream' takes effect
    * configure headers = null
    * configure retry = { count: 30, interval: 5000 }
    * def runId = epoch

  @C1504480
  Scenario: Default delete job profile deletes local authority records linked and not linked to bib fields from Member tenant.
    # Create Record A (unlinked) and Record B (linked) in the university member tenant
    * def seed = call read(authorityUtilFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def recordAAuthorityId = seed.unlinkedAuthorityId
    * def recordARecordId = seed.unlinkedRecordId
    * def recordAControlNumber = seed.unlinkedControlNumber
    * def recordBAuthorityId = seed.linkedAuthorityId
    * def recordBRecordId = seed.linkedRecordId
    * def recordBControlNumber = seed.linkedControlNumber

    # Link a MARC Bib to authority Record B in the member tenant
    * def linkingRes = call read(authorityUtilFeature + '@LinkBibToAuthority') { runId: '#(runId)', authorityId: '#(recordBAuthorityId)', authorityNaturalId: '#(recordBControlNumber)' }
    * def instanceId = linkingRes.instanceId

    # Export Record A and Record B from the Member tenant to build the file for deletion, per
    # the precondition ("exported from Member tenant and downloaded")
    * def authorityIdsToExport = ['#(recordAAuthorityId)', '#(recordBAuthorityId)']
    * def exportFileName = 'C1504480-export-' + runId
    * def headersUserOctetStream = universityHeadersUserOctetStream
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }

    * def deleteFileName = 'C1504480-delete-' + runId
    * javaWriteData.writeByteArrayToFile(exported.exportedBinaryMarcRecord, 'target/' + deleteFileName + '.mrc')

    # Import the exported .mrc file into the member tenant using the
    # "Default - Delete MARC Authority records" job profile
    * def jobProfileId = defaultDeleteAuthorityJobProfileId
    * def res = call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    * match res.jobExecution.status == 'COMMITTED'
    * def deleteJobExecutionId = res.jobExecution.id

    # Check job log entries via mod-source-record-manager that both MARC Authority records were deleted
    Given path 'metadata-provider/jobLogEntries', deleteJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 2
    When method GET
    Then status 200
    And match each response.entries[*].sourceRecordActionStatus == 'DELETED'
    And match each response.entries[*].relatedAuthorityInfo.actionStatus == 'DELETED'
    And def deletedAuthorityIds = karate.map(response.entries, e => e.relatedAuthorityInfo.idList[0])
    And match deletedAuthorityIds contains recordAAuthorityId
    And match deletedAuthorityIds contains recordBAuthorityId

    # Record A and Record B authorities are not found any longer
    Given path 'authority-storage/authorities', recordAAuthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    Given path 'authority-storage/authorities', recordBAuthorityId
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # Both MARC Autority records are marked deleted in SRS
    Given path 'source-storage/records', recordARecordId
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.state == 'DELETED'

    Given path 'source-storage/records', recordBRecordId
    And headers headersUser
    And retry until response.deleted == true
    When method GET
    Then status 200
    And match response.state == 'DELETED'

    # Neither Record A nor Record B authorities are found anymore
    Given path 'search/authorities'
    And param query = 'keyword all "Kirby, Jack"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'search/authorities'
    And param query = 'keyword all "Lee, Stan,"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Verify via quickMARC (records-editor/records) that in the MARC Bib record linked to Record B
    # previously linked field is no longer linked
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    And retry until karate.get("response.fields.find(f => f.tag == '100').linkDetails") == null
    When method GET
    Then status 200
    And def bibField100 = response.fields.find(f => f.tag == '100')
    And match bibField100.content !contains '$9'
    And match bibField100.linkDetails == '##null'
