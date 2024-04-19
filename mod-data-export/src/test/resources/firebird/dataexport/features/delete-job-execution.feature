Feature: Test removing job execution

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def deleteHeadersUser = { 'Content-Type': 'text/plain', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain'  }

    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

  Scenario: Test successful removing of the job execution
    ## start quick export process to have jobExecution
    Given path 'data-export/quick-export'
    And request
    """
    {
    "uuids": ["b73eccf0-57a6-495e-898d-32b9b2210f2f"],
    "type": "uuid",
    "recordType": "INSTANCE"
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
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:0}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    ## test removing job execution
    Given path 'data-export/job-executions/' + jobExecutionId
    And headers deleteHeadersUser
    When method DELETE
    Then status 204

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204
