Feature: Delete MARC Authority records in a Consortia environment via Data Import

  # Uses the shared "SeedAuthorities" util from authority-delete-common.feature to prepare
  # the two authority records described by the TestRail case:
  #   - Record A: the seed's "unlinked" authority - not linked to any bib field.
  #   - Record B: the seed's "linked" authority - linked to a bib's 100 field before deletion.
  # Both records are created in, exported from, and deleted from the Central tenant,
  # through the "Default - Delete MARC Authority records" job profile. After deletion,
  # neither record is discoverable in the Central tenant or the College member tenant,
  # and the MARC Bib field previously linked to Record B is no longer linked.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def authorityUtilFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature'

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    * def centralHeadersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }

    # Login under collegeUser1 to build member-tenant headers used in step 5
    * call login collegeUser1
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': '*/*' }

    # Re-login as consortiaAdmin so okapitoken is current for the Central-tenant data-import util
    # features (import-record.feature, export-authority-record.feature, authority-delete-common.feature)
    # which rely on okapitoken being tied to the tenant declared in testTenant
    * call login consortiaAdmin

    # Declare testTenant, testUser, headersUser variables so every
    # data-import util feature (auth.feature, import-record.feature, authority-delete-common.feature, etc.)
    # operates against the Central tenant instead of a Member tenant
    * def testTenant = centralTenant
    * def testUser = consortiaAdmin
    * def headersUser = headersConsortia

    # Clear 'configure headers' made by initData.feature's Background (Content-Type: application/json),
    # so export-authority-record.feature's 'And headers headersUserOctetStream' takes effect
    * configure headers = null
    * configure retry = { count: 30, interval: 5000 }
    * def runId = epoch

  @C1504479
  Scenario: Default delete job profile deletes shared authority records linked and not linked to bib fields from Central tenant
    # Create Record A (unlinked) and Record B (linked) in the Central tenant
    * def seed = call read(authorityUtilFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def recordAAuthorityId = seed.unlinkedAuthorityId
    * def recordARecordId = seed.unlinkedRecordId
    * def recordAControlNumber = seed.unlinkedControlNumber
    * def recordBAuthorityId = seed.linkedAuthorityId
    * def recordBRecordId = seed.linkedRecordId
    * def recordBControlNumber = seed.linkedControlNumber
    * def recordA100FieldValue = 'Kirby, Jack'
    * def recordB100FieldValue = 'Lee, Stan,'

    # Link a MARC Bib to Authority Record B in the Central tenant
    * def linkingRes = call read(authorityUtilFeature + '@LinkBibToAuthority') { runId: '#(runId)', authorityId: '#(recordBAuthorityId)', authorityNaturalId: '#(recordBControlNumber)' }
    * def instanceId = linkingRes.instanceId

    # Export Record A and Record B from the Central tenant to build the file for deletion
    * def headersUserOctetStream = centralHeadersUserOctetStream
    * def authorityIdsToExport = ['#(recordAAuthorityId)', '#(recordBAuthorityId)']
    * def exportFileName = 'C1504479-export-' + runId
    * def exported = call read(exportAuthorityFeature + '@exportAuthorityRecords') { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }

    * def deleteFileName = 'C1504479-delete-' + runId
    * javaWriteData.writeByteArrayToFile(exported.exportedBinaryMarcRecord, 'target/' + deleteFileName + '.mrc')

    # Import the exported .mrc file into the Central tenant using the
    # "Default - Delete MARC Authority records" job profile
    * def jobProfileId = defaultDeleteAuthorityJobProfileId
    * def res = call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    * match res.jobExecution.status == 'COMMITTED'
    * def deleteJobExecutionId = res.jobExecution.id

    # Check job log entries via mod-source-record-manager that both MARC Authority records
    # were deleted - "Deleted" value in "SRS MARC" and "Authority" fields for Record A and Record B
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

    # Record A and Record B authority storage entries are no longer found on Central tenant
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

    # Both MARC Authority records are marked deleted in SRS on Central tenant
    Given path 'source-storage/records', recordARecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.state == 'DELETED'
    And match response.deleted == true

    Given path 'source-storage/records', recordBRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.state == 'DELETED'
    And match response.deleted == true

    # Navigate to "MARC authority" app in Central tenant and search for Record A and Record B
    # by their headings using "Keyword" search - neither record should be found
    Given path 'search/authorities'
    And param query = 'keyword all "' + recordA100FieldValue + '"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'search/authorities'
    And param query = 'keyword all "' + recordB100FieldValue + '"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Navigate to the bib record that was linked to Record B (in Central tenant) using
    # quickMARC editor API - the previously linked field is no longer linked
    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    And retry until karate.get("response.fields.find(f => f.tag == '100').linkDetails") == null
    When method GET
    Then status 200
    And def bibField100 = response.fields.find(f => f.tag == '100')
    And match bibField100.content !contains '$9'
    And match bibField100.linkDetails == '##null'

    # Navigate to "MARC authority" app in the college Member tenant and search for
    # Record A and Record B by their headings - neither record should be found in the Member tenant
    Given path 'search/authorities'
    And param query = 'keyword all "' + recordA100FieldValue + '"'
    And headers headersCollege
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'search/authorities'
    And param query = 'keyword all "' + recordB100FieldValue + '"'
    And headers headersCollege
    When method GET
    Then status 200
    And match response.totalRecords == 0
