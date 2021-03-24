Feature: Test quickMARC
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * callonce read('classpath:domain/mod-quick-marc/features/setup/prepare-marc-records.feature')

    * callonce read('classpath:domain/mod-quick-marc/features/setup/prepare-marc-json.feature')

  # ================= positive test cases =================

  Scenario: Edit quickMarcJson
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
    And param instanceId = instanceId
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
    And param instanceId = nonExistentId
    And headers headersUser
    When method GET
    Then status 404

  Scenario: Record's invalid id for retrieving
    Given path 'records-editor/records'
    And param instanceId = 'badUUID'
    And headers headersUser
    When method GET
    Then status 400

  Scenario: Illegal fixed field length for updating
    Given path 'records-editor/records'
    And param instanceId = instanceId
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
    And param instanceId = instanceId
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
    * def wrongRecordId = quickMarcJson.parsedRecordDtoId
    Given path 'records-editor/records', instanceId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 400
    And match response.message == "Request id and entity id are not equal"

  Scenario: Record's invalid id for updating
    Given path 'records-editor/records', 'invalidUUID'
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 400