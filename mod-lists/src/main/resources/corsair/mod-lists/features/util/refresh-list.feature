Feature: Delete list
  Background:
    * url baseUrl

  Scenario: Refresh list
    Given path 'lists/' + listId + '/refresh/'
    When method POST
    Then status 200

    * def pollingAttempts = 0
    * def maxPollingAttempts = 3
    Given path 'lists/' + listId
    And retry until (pollingAttempts++ >= maxPollingAttempts || response.inProgressRefresh == null)
    When method GET
    Then status 200