Feature: Test export authority deleted with deleted profile

  Background:
    * url baseUrl
    * configure readTimeout = 1200000

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def snapshotId = '7003a35f-315e-4955-9f6b-f155b2bb46a8'
    * call read('classpath:global/mod_srs_init_data.feature@PostSnapshot') {snapshotId:'#(snapshotId)'}

    * callonce loadTestVariables
    * json deletedAuthoritiesDeletedProfileRequest = read('classpath:samples/deleted_authorities_deleted_profile.json')

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * configure retry = { interval: 5000, count: 10 }

  Scenario: Test export deleted authority with deleted profile
    # check how may deleted records already exist
    Given path 'authority-storage/authorities'
    And param deleted = true
    When method GET
    Then status 200
    And def numExistingDeletedAuthorities = response.totalRecords
    And def numNeededToCreate = 100 - numExistingDeletedAuthorities
    And def existingDeletedAuthorities = response.authorities

    # fetch existing deleted marc authority records
    * def funGetExistingMarcAuthorities = function(i){ return karate.call('classpath:global/mod_srs_init_data.feature@GetMarcAuthorityRecordByAuthorityId', {authorityId: existingDeletedAuthorities[i].id}) }
    * def marcAuthorities = karate.repeat(numExistingDeletedAuthorities, funGetExistingMarcAuthorities)

    # will hold all authorities (newly created and existing deleted), 100
    * def authorities = []

    # create numNeededToCreate authorities that will be deleted
    * def genAuthorities = function(i){ authorities.push({authorityId: uuid(), authorityRecordId: uuid(), snapshotId: snapshotId}) }
    * karate.repeat(numNeededToCreate, genAuthorities)
    * def funCreateAuth = function(i){ karate.call('classpath:global/inventory_data_setup_util.feature@PostAuthority', {authorityId: authorities[i].authorityId}) }
    * def funCreateAuthRec = function(i){ karate.call('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord', {authorityId: authorities[i].authorityId, snapshotId: authorities[i].snapshotId, recordId: authorities[i].authorityRecordId}) }
    * karate.repeat(numNeededToCreate, funCreateAuth)
    * karate.repeat(numNeededToCreate, funCreateAuthRec)

    * pause(5000)

    # delete authorities
    * def funDelAuth = function(i){ karate.call('classpath:global/delete_authority.feature@DeleteAuthority', {authorityId: authorities[i].authorityId}) }
    * karate.repeat(numNeededToCreate, funDelAuth)

    * pause(5000)

    # add existing deleted authorities to the authorities array (no need to delete them again)
    * def funFillOutExistingDeleted = function(i){ authorities.push({authorityId: existingDeletedAuthorities[i].id, authorityRecordId: marcAuthorities[i].response.id, snapshotId: marcAuthorities[i].response.snapshotId}) }
    * karate.repeat(numExistingDeletedAuthorities, funFillOutExistingDeleted)

    # get total number of job executions before export
    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL)'
    When method GET
    Then status 200
    And def totalRecords = response.totalRecords

    # export deleted authority
    Given path 'data-export/export-authority-deleted'
    And request deletedAuthoritiesDeletedProfileRequest
    When method POST
    Then status 200
    And def jobExecutionIdOfDeleted = response.jobExecutionId

    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL) sortBy completedDate/sort.descending'
    And param limit = 1000
    And retry until response.totalRecords == totalRecords + 1 && response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id
    And match jobExecutionIdOfDeleted == jobExecutionId
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And match response.jobExecutions[0].progress == {exported:100, failed:0, duplicatedSrs:0, total:100, readIds:100}
    And match response.jobExecutions[0].jobProfileName == 'Deleted authority export job profile'

    #should return download link for authority of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #download link content should not be empty
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'

    # validate that exported marc file has required fields
    And def Checker = Java.type("org.folio.utils.MarcFileInstanceFieldsExistenceChecker")
    And def checker = new Checker(response)

    # iterate over all authorities in the array and check whether the .mrc file contains all 100 ids of deleted authorities
    * def authorityChecks = authorities.map(x => checker.checkDeletedAuthority(x.authorityId, x.authorityRecordId))
    * match karate.sizeOf(authorityChecks) == 100
    * match authorityChecks == authorities.map(() => true)
