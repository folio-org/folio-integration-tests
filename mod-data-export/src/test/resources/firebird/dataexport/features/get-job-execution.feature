Feature: Get job execution by id

  Background:
    * url baseUrl
    * def getJobStatusById = function(id) {var job = karate.filter(response.jobExecutions, function(x){ return x.id == id }); return job[0].status }
    * configure retry = { interval: 3000, count: 10 }

  @getJobWhenJobStatusCompleted
  Scenario: wait until job status will be 'completed'
    Given path 'data-export/job-executions'
    And param query = 'id=' + jobExecutionId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And retry until getJobStatusById(jobExecutionId) == 'COMPLETED'
    When method GET
    Then status 200