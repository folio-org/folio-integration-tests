Feature: Prepare MARC json

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

  Scenario: Retrieve existing quickMarcJson by instanceId
    Given path 'records-editor/records'
    And param instanceId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
