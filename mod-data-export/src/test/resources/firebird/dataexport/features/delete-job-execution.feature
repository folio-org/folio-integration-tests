Feature: Test removing job execution

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * configure retry = { interval: 3000, count: 10 }

  Scenario: Test removing of not existing job execution
    * def randomUuid = callonce uuid
    Given path 'data-export/job-executions', randomUuid
    When method DELETE
    Then status 404

  Scenario: Test successful removing of the job execution
    ## start quick export process to have jobExecution
    Given path 'data-export/quick-export'
    And def fileName = randomString(10)
    And request
    """
    {
    "uuids": ["b73eccf0-57a6-495e-898d-32b9b2210f2f"],
    "type": "uuid",
    "recordType": "INSTANCE",
    "fileName" : "#(fileName)"
    }
    """
    When method POST
    Then status 200
    And match response == {jobExecutionId: '#uuid', jobExecutionHrId: '#number'}
    And def jobExecutionId = response.jobExecutionId

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:{duplicatedSrs:0, otherFailed:0}, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    ## test removing job execution
    Given path 'data-export/job-executions/' + jobExecutionId
    When method DELETE
    Then status 204

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204