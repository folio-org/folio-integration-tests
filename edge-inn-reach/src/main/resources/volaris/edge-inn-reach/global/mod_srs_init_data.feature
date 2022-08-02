Feature: init srs data feature

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  @PostSnapshot
  Scenario: create snapshot
    * def snapshot = { 'jobExecutionId':'#(snapshotId)', 'status':'PARSING_IN_PROGRESS' }
    Given path 'source-storage/snapshots'
    And request snapshot
    When method POST
    Then status 201

  @PostMarcBibRecord
  Scenario: create srs record
    Given path '/source-storage/records'
    And request read(samplesPath + 'srs/source-record.json')
    When method POST
    Then status 201
