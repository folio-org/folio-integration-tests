Feature: Check that the splitting feature is enabled

  Background:
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Splitting feature should be enabled
    * print 'Splitting feature should be enabled'

    Given path '/data-import/splitStatus'
    And headers headersUser
    When method GET
    Then status 200
    * match response == ({ "splitStatus": true })
