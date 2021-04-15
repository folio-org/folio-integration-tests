Feature: Test quickMARC
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def deleteHeaders = { 'Content-Type': 'text/plain', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'text/plain'  }

  Scenario: Find and remove record from SRS and inventory
    Given path '/source-storage/source-records'
    And headers headersUser
    When method get
    Then status 200
    * def sourceRecordId = response.sourceRecords[0].recordId
    * def instanceId = response.sourceRecords[0].externalIdsHolder.instanceId

    Given path '/source-storage/records', sourceRecordId
    And headers deleteHeaders
    When method delete
    Then status 204

    Given path '/inventory/instances', instanceId
    And headers deleteHeaders
    When method delete
    Then status 204

  Scenario: Retrieve and remove instance-type
    Given path 'instance-types'
    And headers headersUser
    When method get
    Then status 200
    * def instanceTypeId = response.instanceTypes[0].id

    Given path 'instance-types', instanceTypeId
    And headers deleteHeaders
    When method delete
    Then status 204