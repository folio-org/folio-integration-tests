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

    * configure retry = { interval: 15000, count: 10 }

  Scenario: Test export deleted authority
    # create 100 authorities that will be deleted
    * call login testUser
    * def okapiUserToken = okapitoken
    * def authorities = []
    * def genAuthorities = function(i){ authorities.push({authorityId: uuid(), authorityRecordId: uuid(), snapshotId: snapshotId}) }
    * karate.repeat(100, genAuthorities)
    * def funCreateAuth = function(i){ karate.call('classpath:global/inventory_data_setup_util.feature@PostAuthority', {authorityId: authorities[i].authorityId}) }
    * def funCreateAuthRec = function(i){ karate.call('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord', {authorityId: authorities[i].authorityId, snapshotId: authorities[i].snapshotId, authorityRecordId: authorities[i].authorityRecordId}) }
    * karate.repeat(100, funCreateAuth)
    * karate.repeat(100, funCreateAuthRec)

    * pause(5000)

    # delete authorities
    * def funDelAuth = function(i){ karate.call('classpath:global/delete_authority.feature@DeleteAuthority', {authorityId: authorities[i].authorityId}) }
    * karate.repeat(100, funDelAuth)

    * pause(5000)

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
    * def authorityChecks = authorities.map(x => checker.checkAuthorityIdExists(x.authorityId, x.authorityRecordId))
    * match authorityChecks == authorities.map(() => true)
