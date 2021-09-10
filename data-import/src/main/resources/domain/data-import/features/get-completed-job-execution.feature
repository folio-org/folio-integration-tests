Feature: Get job execution by id

  Background:
    * url baseUrl
    * def getJobStatusById = function(id) {return response.status}
    * configure retry = { count: 40, interval: 30000 }

  @getJobWhenJobStatusCompleted
  Scenario: wait until job status will be 'completed'
    Given path '/change-manager/jobExecutions', jobExecutionId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And headers headersUser
    And retry until getJobStatusById(jobExecutionId) == 'COMMITTED'
    When method GET
    Then status 200