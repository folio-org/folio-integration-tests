Feature: Batch job operations

  Background:
    * url baseUrl

  @assertReindexJobCompleted
  Scenario: Assert reindex batch job completed with expected reindex type
    Given path 'linked-data/batch/status'
    And param jobExecutionId = jobExecutionId
    And retry until response.status == 'COMPLETED' || response.status == 'FAILED'
    When method GET
    Then status 200
    * if (response.status == 'FAILED') karate.fail(expectedReindexType + ' reindex job failed. jobExecutionId=' + jobExecutionId)
    * match response.status == 'COMPLETED'
    * match response.jobName == 'reindexJob'
    * match response.reindexType == expectedReindexType
