Feature: Get job execution by id

  Background:
    * url baseUrl

    Scenario: Get job executions
    Given path 'data-export/job-executions'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    When method GET
    Then status 200
      * def response = response