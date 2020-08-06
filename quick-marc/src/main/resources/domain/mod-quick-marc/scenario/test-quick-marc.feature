Feature: Test quickMARC
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

  Scenario: import MARC record
    Given path 'instance-types',
    And headers headersUser
    And request
    """
    {
      "name" : "unspecified",
      "code" : "zzz",
      "source" : "rdacontent"
    }
    """
    When method post
    Then status 201

    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "size": 1,
          "name": "summerland.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('samples/summerland.mrc')
    When method post
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = true
    And headers headersUser
    And request
    """
    {
      "uploadDefinition": '#(uploadDefinition)',
      "jobProfileInfo": {
        "id": "22fafcc3-f582-493d-88b0-3c538480cd83",
        "name": "Create MARC Bibs",
        "dataType": "MARC"
      }
    }
    """
    When method post
    Then status 204

    Given path 'source-storage/records'
    And param snapshotId = jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    * def response = $
    * def instanceId = response.records[0].externalIdsHolder.instanceId

  # ================= positive test cases =================
  Scenario: Retrieve existing quickMarcJson by instanceId
    Given path 'records-editor/records'
    And param instanceId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

  Scenario: Edit quickMarcJson
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

    * def pause = function(mills){ java.lang.Thread.sleep(mills) }
    * def void = pause(1000)

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
    * def recordId = quickMarcJson.parsedRecordId

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422
    And match response.errors[0].message == 'must match \"^[0-9]{3}$\"'