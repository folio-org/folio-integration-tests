@parallel=false
Feature: Test export deleted IDs

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables
    * json deletedIdsRequest = read('classpath:samples/deleted_ids.json')
    * json deletedIdsNotFoundRequest = read('classpath:samples/deleted_ids_not_found.json')
    * json deletedIdsInvalidFromRequest = read('classpath:samples/deleted_ids_invalid_from.json')
    * json deletedIdsInvalidToRequest = read('classpath:samples/deleted_ids_invalid_to.json')
    * json deletedIdsInvalidDateRangeRequest = read('classpath:samples/deleted_ids_invalid_date_range.json')

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * configure retry = { interval: 15000, count: 10 }

  @PostSnapshot
  Scenario: create snapshot
    * def snapshot = { 'jobExecutionId':'fbc59c05-f8e8-48e1-b22d-e2e61b3ab10e', 'status':'PARSING_IN_PROGRESS' }
    Given path 'source-storage/snapshots'
    And request snapshot
    When method POST
    Then status 201

  @PostMarcBibRecordDeleted
  Scenario: create srs record
    * string recordTemplate = read('classpath:samples/marc_bib_record_deleted.json')
    * def record = recordTemplate
    Given path 'source-storage/records'
    And request record
    When method POST
    Then status 201

  Scenario: Test get deleted record
    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL)'
    When method GET
    Then status 200
    And def totalRecords = response.totalRecords

    Given path 'data-export/export-deleted'
    And request deletedIdsRequest
    When method POST
    Then status 200

    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL) sortBy completedDate/sort.descending'
    And param limit = 1000
    And retry until response.totalRecords == totalRecords + 1 && response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:1}

    #should return download link for instance of uploaded file
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

  Scenario: Test get deleted record nothing found
    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL)'
    When method GET
    Then status 200
    And def totalRecords = response.totalRecords

    Given path 'data-export/export-deleted'
    And request deletedIdsNotFoundRequest
    When method POST
    Then status 200

    Given path 'data-export/job-executions'
    And param query = 'status=(COMPLETED OR COMPLETED_WITH_ERRORS OR FAIL) sortBy completedDate/sort.descending'
    And param limit = 1000
    And retry until response.totalRecords == totalRecords + 1 && response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And match response.jobExecutions[0].progress == {exported:0, failed:0, duplicatedSrs:0, total:0, readIds:0}

    #error logs should be saved
    Given path 'data-export/logs'
    And param query = 'jobExecutionId==' + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.readingFromInputFile'

  #Negative scenarios

  Scenario: Invalid date format in 'from'
    Given path 'data-export/export-deleted'
    And request deletedIdsInvalidFromRequest
    When method POST
    Then status 400
    And match response == 'Invalid date format for payload'

  Scenario: Invalid date format in 'to'
    Given path 'data-export/export-deleted'
    And request deletedIdsInvalidToRequest
    When method POST
    Then status 400
    And match response == 'Invalid date format for payload'

  Scenario: Invalid date range
    Given path 'data-export/export-deleted'
    And request deletedIdsInvalidDateRangeRequest
    When method POST
    Then status 400
    And match response == "Invalid date range for payload: date 'from' cannot be after date 'to'."
