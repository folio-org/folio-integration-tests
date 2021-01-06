Feature: Test quick export

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }

    * configure headers = headersUser

  Scenario: Test removing of not existing job execution
    * def randomUuid = callonce uuid
    Given path 'data-export/job-executions', randomUuid
    When method DELETE
    Then status 404

  Scenario: Test successful removing of the job execution
    ## start quick export process to have jobExecution
    Given path 'data-export/quick-export'
    And request
    """
    {
    "criteria": "(languages=\"eng\")",
    "uuids": ["b73eccf0-57a6-495e-898d-32b9b2210f2f"],
    "type": "uuid",
    "recordType": "INSTANCE"
    }
    """
    When method POST
    Then status 200
    And match response == {jobExecutionId: '#uuid', jobExecutionHrId: '#number'}
    And def jobExecutionId = response.jobExecutionId

    ## test removing job execution
    * call pause
    Given path 'data-export/job-executions/' + jobExecutionId
    When method DELETE
    Then status 204
