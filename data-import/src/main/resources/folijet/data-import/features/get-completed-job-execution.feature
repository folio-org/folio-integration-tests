Feature: Get job execution by id

  Background:
    * url baseUrl
    * configure retry = { interval: 2000, count: 30 }

  @getJobWhenJobStatusCompleted
  Scenario: wait until job status will be 'completed'
    Given path '/change-manager/jobExecutions', jobExecutionId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And headers headersUser
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method GET
    Then status 200
