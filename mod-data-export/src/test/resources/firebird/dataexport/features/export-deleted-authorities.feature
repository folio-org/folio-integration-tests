@parallel=false
Feature: Test export authority deleted

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def snapshotId = '6993a35f-315e-4955-9f6b-f155b2bb46a8'
    * call read('classpath:global/mod_srs_init_data.feature@PostSnapshot') {snapshotId:'#(snapshotId)'}

    * callonce loadTestVariables
    * json deletedAuthoritiesRequest = read('classpath:samples/deleted_authorities.json')
    * json deletedAuthoritiesTooBigLimitRequest = read('classpath:samples/deleted_authorities_too_big_limit.json')
    * json deletedAuthoritiesInvalidQueryRequest = read('classpath:samples/deleted_authorities_invalid_query.json')

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * configure retry = { interval: 15000, count: 10 }

  Scenario: Test export deleted authority
    # create authority that will be deleted
    * def authorityDeletedId = '0410f607-60eb-4a5d-9951-28f3794941ec'
    * def authorityDeletedRecordId = '926e148b-7f5b-4d77-9425-655b7e980098'
    * def authorityRecordId = authorityDeletedRecordId
    * def authorityId = authorityDeletedId
    * call read('classpath:global/inventory_data_setup_util.feature@PostAuthority') {authorityId:'#(authorityId)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord') {recordId:'#(authorityRecordId)', snapshotId:'#(snapshotId)', authorityId:'#(authorityId)'}

    # create authority that will not be deleted
    * def authorityNotDeletedId = '8a7b8c92-10c0-4dd9-83cd-754fab0c2ff2'
    * def authorityNotDeletedRecordId = 'de164016-d7fc-420e-a960-f0fc8e4c3592'
    * def authorityRecordId = authorityNotDeletedRecordId
    * def authorityId = authorityNotDeletedId
    * call read('classpath:global/inventory_data_setup_util.feature@PostAuthority') {authorityId:'#(authorityId)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord') {recordId:'#(authorityRecordId)', snapshotId:'#(snapshotId)', authorityId:'#(authorityId)'}

    * pause(5000)

    # delete authority
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    Given path 'authority-storage/authorities/', authorityDeletedId
    When method DELETE
    Then status 204
    And def authorityDeletedId = response.id

    * pause(5000)

    # get total number of job executions before export
    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL)'
    When method GET
    Then status 200
    And def totalRecords = response.totalRecords

    # export deleted authority
    Given path 'data-export/export-authority-deleted'
    And request deletedAuthoritiesRequest
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
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:1}

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

  #Negative scenarios

  Scenario: Test export deleted authority when invalid query
    Given path 'data-export/export-authority-deleted'
    And request deletedAuthoritiesInvalidQueryRequest
    When method POST
    Then status 400
    And match response == '#notnull'

  Scenario: Test export deleted authority when limit is too big
    Given path 'data-export/export-authority-deleted'
    And request deletedAuthoritiesTooBigLimitRequest
    When method POST
    Then status 400
    And match response == '#notnull'
