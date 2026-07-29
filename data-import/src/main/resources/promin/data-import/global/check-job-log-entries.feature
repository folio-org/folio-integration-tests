Feature: Check job log entries

  Background:
    * url baseUrl
    * configure retry = { interval: 2000, count: 30 }

  Scenario: check job log entries for errors
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200