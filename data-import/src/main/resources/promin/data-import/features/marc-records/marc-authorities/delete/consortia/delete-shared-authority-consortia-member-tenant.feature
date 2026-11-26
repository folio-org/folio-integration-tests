Feature: Delete MARC Authority records in a Consortia environment via Data Import

  # Uses the shared "SeedAuthorities" util from authority-delete-common.feature to prepare
  # the two shared authority records described by the TestRail case:
  #   - Record A: the seed's "unlinked" authority - not linked to any bib field.
  #   - Record B: the seed's "linked" authority - linked to a bib's 100 field.
  # Both records are created in and exported from the Central tenant (so they are shared records),
  # then the exported .mrc file is imported in the college Member tenant through the
  # "Default - Delete MARC Authority records" job profile. Data import initiated from a member tenant
  # does not delete shared MARC Authority records.is not allowed to delete,
  # so both records are discarded and are still found in the member tenant.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/common-functions.feature')

    * def login = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def authorityUtilFeature = 'classpath:promin/data-import/global/authority-delete-common.feature'
    * def exportAuthorityFeature = 'classpath:promin/data-import/global/export-authority-record.feature@exportAuthorityRecords'

    * configure retry = { count: 30, interval: 5000 }
    * def runId = epoch

  @C1504481
  Scenario: Delete of Shared MARC Authority record via data import will have no action from member tenant
    # Preconditions: Create Shared Record A (unlinked) and Shared Record B (linked) in the Central tenant.
    # Declare testTenant, testUser, headersUser variables so the data-import util features
    # operate against the Central tenant while the preconditions are prepared
    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    * def centralHeadersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': '*/*' }
    * def testTenant = centralTenant
    * def testUser = consortiaAdmin
    * def headersUser = headersConsortia

    * def seedRes = call read(authorityUtilFeature + '@SeedAuthorities') { runId: '#(runId)' }
    * def recordAAuthorityId = seedRes.unlinkedAuthorityId
    * def recordARecordId = seedRes.unlinkedRecordId
    * def recordAControlNumber = seedRes.unlinkedControlNumber
    * def recordBAuthorityId = seedRes.linkedAuthorityId
    * def recordBRecordId = seedRes.linkedRecordId
    * def recordBControlNumber = seedRes.linkedControlNumber
    * def recordA100FieldValue = 'Kirby, Jack'
    * def recordB100FieldValue = 'Lee, Stan,'

    # Link a MARC Bib to Shared Authority Record B in the Central tenant
    * def linkingRes = call read(authorityUtilFeature + '@LinkBibToAuthority') { runId: '#(runId)', authorityId: '#(recordBAuthorityId)', authorityNaturalId: '#(recordBControlNumber)' }
    * def instanceId = linkingRes.instanceId

    # Preconditions: Export Record A and Record B from the Central tenant to build the .mrc file for authority deletion
    # Clear 'configure headers' made by initData.feature's Background (Content-Type: application/json),
    # so export-authority-record.feature's 'And headers headersUserOctetStream' takes effect
    * configure headers = null
    * def headersUserOctetStream = centralHeadersUserOctetStream
    * def authorityIdsToExport = ['#(recordAAuthorityId)', '#(recordBAuthorityId)']
    * def exportFileName = 'C1504481-export-' + runId
    * def exportRes = call read(exportAuthorityFeature) { authorityIds: '#(authorityIdsToExport)', fileName: '#(exportFileName)' }
    * def deleteFileName = 'C1504481-delete-' + runId
    * javaWriteData.writeByteArrayToFile(exportRes.exportedBinaryMarcRecord, 'target/' + deleteFileName + '.mrc')

    # Switch to the college Member tenant for all the test steps
    * call login collegeUser1
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': '*/*' }
    * def testTenant = collegeTenant
    * def testUser = collegeUser1
    * def headersUser = headersCollege

    # Import the exported .mrc file into the member tenant using the
    # "Default - Delete MARC Authority records" job profile
    * def jobProfileId = defaultDeleteAuthorityJobProfileId
    * def res = call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    * match res.jobExecution.status == 'COMMITTED'
    * def deleteJobExecutionId = res.jobExecution.id

    # Check job log entries that Record A and Record B were not deleted
    Given path 'metadata-provider/jobLogEntries', deleteJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') == 2
    When method GET
    Then status 200
    And match each response.entries[*].sourceRecordActionStatus == 'DISCARDED'
    And match each response.entries[*].error == ''
    And match each response.entries[*].relatedAuthorityInfo.actionStatus == 'DISCARDED'
    And match each response.entries[*].relatedAuthorityInfo.error == ''

    # Search for Record A and Record B by their headings using "Keyword" search - both records are still found
    # It's expected that the enpoint can return several entries (heading expansion entry) for one authority entity
    Given path 'search/authorities'
    And param query = 'keyword all "' + recordA100FieldValue + '"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords != 0

    Given path 'search/authorities'
    And param query = 'keyword all "' + recordB100FieldValue + '"'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords != 0
