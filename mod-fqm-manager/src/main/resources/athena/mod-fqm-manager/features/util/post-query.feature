Feature: Post a query
  Background:
    * url baseUrl
  Scenario: Post a query
    Given path 'query'
    And request queryRequest
    When method POST
    Then status 201
    * def queryId = $.queryId
    * def pollingAttempts = 0
    * def maxPollingAttempts = 3
    Given path 'query', queryId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.status == 'SUCCESS')
    When method GET
    Then status 200
    * def queryId = $.queryId
