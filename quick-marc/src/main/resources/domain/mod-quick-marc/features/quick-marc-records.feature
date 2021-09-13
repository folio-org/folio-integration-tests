Feature: Test quickMARC
  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def result = callonce read('classpath:domain/mod-quick-marc/features/setup/setup.feature')
    * def testInstanceId = result.response.sourceRecords[0].externalIdsHolder.instanceId

  # ================= positive test cases =================
   Scenario: Retrieve existing quickMarcJson by instanceId
      Given path 'records-editor/records'
      And param externalId = testInstanceId
      And headers headersUser
      When method GET
      Then status 200

  Scenario: Edit quickMarcJson
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
    * def recordId = quickMarcJson.parsedRecordId
    * def fields = quickMarcJson.fields
    * def newField = { "tag": "500", "indicators": [ "\\", "\\" ], "content": "$a Test note" }
    * def void = (fields.add(newField))
    * set quickMarcJson.fields = fields
    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    And retry until response.updateInfo.recordState == 'ACTUAL'
    When method GET
    Then status 200
    * def result = $
    And match result.fields contains newField

#   ================= negative test cases =================
  Scenario: Record not found for retrieving
    * def nonExistentId = call uuid
    Given path 'records-editor/records'
    And param externalId = nonExistentId
    And headers headersUser
    When method GET
    Then status 404

  Scenario: Record's invalid id for retrieving
    Given path 'records-editor/records'
    And param externalId = 'badUUID'
    And headers headersUser
    When method GET
    Then status 400

  Scenario: Illegal fixed field length for updating
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

    * set quickMarcJson.fields[?(@.tag=='008')].content.Date1 = '123'
    * def recordId = quickMarcJson.parsedRecordId

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422
    And match response.message == "Invalid Date1 field length, must be 4 characters"

  Scenario: Illegal leader/008 mismatch
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

    * set quickMarcJson.fields[?(@.tag=='008')].content.ELvl = 'a'
    * set quickMarcJson.fields[?(@.tag=='008')].content.Desc = 'b'
    * def recordId = quickMarcJson.parsedRecordId

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422
    And match response.message == "The Leader and 008 do not match"

  Scenario: Record id mismatch for updating
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
    * def wrongRecordId = quickMarcJson.parsedRecordDtoId
    Given path 'records-editor/records', testInstanceId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 400
    And match response.message == "Request id and entity id are not equal"

  Scenario: Record's invalid id for updating
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
    Given path 'records-editor/records', 'invalidUUID'
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 400