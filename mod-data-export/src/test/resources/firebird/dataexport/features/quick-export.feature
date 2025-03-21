Feature: Test quick export

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure retry = { interval: 15000, count: 10 }

  Scenario: Quick export should return 200 status, with jobExecutionId and jobExecutionHrId
    Given path 'data-export/quick-export'
    And request
    """
    {
    "uuids": ["1762b035-f87b-4b6f-80d8-c02976e03575"],
    "type": "uuid",
    "recordType": "INSTANCE"
    }
    """
    When method POST
    Then status 200
    And match response == {jobExecutionId: '#uuid', jobExecutionHrId: '#number'}
    And def jobExecutionId = response.jobExecutionId

  ## verify job execution for quick export
    * call pause 3000
    * call read('classpath:firebird/dataexport/features/get-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecutions = response.jobExecutions
    * def jobExecution = karate.jsonPath(jobExecutions, "$.[?(@.id=='" + jobExecutionId + "')]")[0]
    And assert jobExecution.status == 'COMPLETED'
    And assert jobExecution.progress.exported == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
    * def hrId = '' + jobExecution.hrId
    And match jobExecution.exportedFiles[0].fileName contains hrId

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204
