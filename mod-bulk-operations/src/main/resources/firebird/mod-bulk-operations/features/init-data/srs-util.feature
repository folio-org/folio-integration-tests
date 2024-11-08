Feature: setup marc data feature

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)' }

  @PostMarcInstances
  Scenario: POST marc-instances
    Given path 'source-storage/records'
    And request marcInstances
    When method POST
    Then status 201

  @PostSnapshot
  Scenario: POST snapshot
    * def snapshot = { 'jobExecutionId':'1094db4e-3be2-4cbc-bb61-34375edcba81', 'status':'PARSING_IN_PROGRESS' }
    Given path 'source-storage/snapshots'
    And request snapshot
    When method POST
    Then status 201