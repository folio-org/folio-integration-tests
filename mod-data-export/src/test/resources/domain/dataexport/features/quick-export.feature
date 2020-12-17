Feature: Test quick export

  Background:
    * configure afterScenario =
        """
      function() {
        // load java type into js engine
        var Thread = Java.type('java.lang.Thread');
        Thread.sleep(5000); // sleep for 5 Seconds
      }
      """
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }

    * configure headers = headersUser

  Scenario: Quick export should return 200 status, with jobExecutionId and jobExecutionHrId
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

  ## verify job execution for quick export
    * callonce getJobExecutions
    * def jobExecutions = response.jobExecutions
    * def jobExecution = karate.jsonPath(jobExecutions, "$.[?(@.id=='" + jobExecutionId + "')]")[0]
    And assert jobExecution.status == 'COMPLETED'
    And assert jobExecution.progress.exported == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
    * def hrId = '' + jobExecution.hrId
    And match jobExecution.exportedFiles[0].fileName contains hrId

  Scenario: Quick export should return 200 status, with jobExecutionId and jobExecutionHrId and custom fileName
    Given path 'data-export/quick-export'
    And request
    """
    {
    "criteria": "(languages=\"eng\")",
    "uuids": ["b73eccf0-57a6-495e-898d-32b9b2210f2f"],
    "type": "uuid",
    "recordType": "INSTANCE",
    "fileName": "test"
    }
    """
    When method POST
    Then status 200
    And match response == {jobExecutionId: '#uuid', jobExecutionHrId: '#number'}
    And def jobExecutionId = response.jobExecutionId

  ## verify job execution for quick export
    * call getJobExecutions
    * def jobExecutions = response.jobExecutions
    * def jobExecution = karate.jsonPath(jobExecutions, "$.[?(@.id=='" + jobExecutionId + "')]")[0]
    And assert jobExecution.status == 'COMPLETED'
    And assert jobExecution.progress.exported == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
    * def hrId = '' + jobExecution.hrId
    And match jobExecution.exportedFiles[0].fileName contains hrId
    And match jobExecution.exportedFiles[0].fileName contains 'test'