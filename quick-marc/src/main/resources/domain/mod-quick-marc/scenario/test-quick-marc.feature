Feature: Test quickMARC
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

  Scenario: prepare sample data
    * def srsSnapshotId = callonce uuid
    * def matchedId = callonce uuid
    * def instanceId = callonce uuid
    * def parsedRecordContent = read('samples/parsed-record-content.json')

    # create snapshot
    Given path 'source-storage/snapshots'
    And headers headersAdmin
    And request
    """
      {
        "jobExecutionId": '#(srsSnapshotId)',
        "status": "PARSING_IN_PROGRESS"
      }
    """
    When method POST
    Then status 201

    # create record
    Given path '/source-storage/records'
    And headers headersAdmin
    And request
    """
      {
        "snapshotId": '#(srsSnapshotId)',
        "matchedId": '#(matchedId)',
        "recordType": "MARC",
        "rawRecord": {
          "content": "marc data goes here"
        },
        "externalIdsHolder": {
           "instanceId": '#(instanceId)'
        },
        "parsedRecord": {
          "content": '#(parsedRecordContent)'
        }
      }
    """
    When method POST
    Then status 201

  # ================= positive test cases =================
  Scenario: Retrieve existing quickMarcJson by instanceId
    Given path 'records-editor/records'
    And param instanceId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

  Scenario: Edit quickMarcJson
    # add new field 500 with valid content
    * def recordId = quickMarcJson.parsedRecordId
    * def fields = quickMarcJson.fields
    * def newField = { "tag": "500", "indicators": [ " ", " " ], "content": "$a Test note" }
    * def void = (fields.add(newField))
    * set quickMarcJson.fields = fields
    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 202

    # retrieve record to check update
    Given path 'records-editor/records'
    And param instanceId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def result = $
    * match result.fields contains newField
    * match result.updateInfo.recordState == 'ACTUAL'

  # ================= negative test cases =================
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
    Given path 'records-editor/records', wrongRecordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 400
    And match response.message == "request id and entity id are not equal"

  Scenario: Record missing property
    Given path 'records-editor/records'
    And param instanceId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

    * remove quickMarcJson.instanceId
    * def recordId = quickMarcJson.parsedRecordId

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422
    And match response.errors[0].message == "may not be null"
    And match response.errors[0].parameters[0].key == "instanceId"

  Scenario: Record's invalid id for updating
    Given path 'records-editor/records', 'invalidUUID'
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422

  Scenario: Field number or "tag" invalid format
    Given path 'records-editor/records'
    And param instanceId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

    * set quickMarcJson.fields[?(@.tag=='008')].tag = '08'
    * set quickMarcJson.fields[?(@.tag=='007')].tag = '0007'
    * def recordId = quickMarcJson.parsedRecordId

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422
    And match response.errors[0].message == 'must match \"^[0-9]{3}$\"'
    And match response.errors[1].message == 'must match \"^[0-9]{3}$\"'