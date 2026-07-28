@ignore
Feature: Util feature to retrieve data import logs
  # parameters: jobExecutionId, logEntriesLimit

  Background:
    * url baseUrl
    * configure retry = { interval: 5000, count: 30 }

  @getJobLogEntriesByJobId
  Scenario: Get job log entries by job id
    * print 'Starting getJobLogEntriesByJobId scenario, jobExecutionId: ', jobExecutionId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And param limit = logEntriesLimit
    And headers headersUser
    And retry until response.entries.length == logEntriesLimit
    When method GET
    Then status 200
    And def jobLogEntries = response