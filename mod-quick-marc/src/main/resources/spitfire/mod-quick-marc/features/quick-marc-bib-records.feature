Feature: Test quickMARC
  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def testInstanceId = karate.properties['instanceId']
    * def linkedAuthorityId = karate.properties['linkedAuthorityId']
    * def authorityNaturalId = karate.properties['authorityNaturalId']

  # ================= positive test cases =================
  Scenario: Retrieve existing quickMarcJson by instanceId
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def result = $
    * def linkContent = ' $0 ' + authorityNaturalId + ' $9 ' + linkedAuthorityId
    * def fieldWithLink = {"tag": "240", "indicators": [ "\\", "\\" ], "content":'#("$a Johnson" + linkContent)', "isProtected":false, "linkDetails":{ "authorityId":#(linkedAuthorityId), "authorityNaturalId":#(authorityNaturalId), "linkingRuleId":5, "status":"ACTUAL" } }
    * def repeatedFieldNoLink = {"tag": "100", "indicators": [ "1", "\\" ], "content":"$a Chabon", "isProtected":false }
    * def repeatedFieldWithLink = {"tag": "100", "indicators": [ "\\", "1" ], "content":'#("$a Johnson" + linkContent)', "isProtected":false, "linkDetails":{ "authorityId":#(linkedAuthorityId), "authorityNaturalId":#(authorityNaturalId), "linkingRuleId":1, "status":"ACTUAL" } }
    And match result.fields contains fieldWithLink
    And match result.fields contains repeatedFieldNoLink
    And match result.fields contains repeatedFieldWithLink

  Scenario: Edit quickMarcJson
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
    * def recordId = quickMarcJson.parsedRecordId
    * def fields = quickMarcJson.fields
    * def newField = { "tag": "500", "indicators": [ "\\", "\\" ], "content": "$a Test note", "isProtected":false }
    * fields.push(newField)
    * set quickMarcJson.fields = fields
    * set quickMarcJson.relatedRecordVersion = 2
    * set quickMarcJson._actionType = 'edit'
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

  Scenario: PUT quickMarc with linked and unlinked fields
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $
    * def recordId = quickMarcJson.parsedRecordId
    * def fields = quickMarcJson.fields
    * def linkContent = ' $0 ' + authorityNaturalId + ' $9 ' + linkedAuthorityId
    * def newField = { "tag": "600", "indicators": [ "\\", "\\" ], "content":'#("$a Test note" + linkContent)', "isProtected":false, "linkDetails":{ "authorityId":#(linkedAuthorityId), "authorityNaturalId":#(authorityNaturalId), "linkingRuleId": 8, "status":"ERROR", "errorCause":"test"  } }
    * fields.push(newField)
    * set quickMarcJson.fields = fields
    * set quickMarcJson.relatedRecordVersion = 3
    * set quickMarcJson._actionType = 'edit'
    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 202

    * def newLink = { "id":3, "authorityId": #(linkedAuthorityId), "authorityNaturalId": #(authorityNaturalId), "instanceId": #(testInstanceId), "linkingRuleId": #(newField.linkDetails.linkingRuleId), "status":"ACTUAL" }

    Given path 'links/instances', testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def result = $
    And match result.links == '#[3]'
    And match result.links contains newLink

  Scenario: Should update record twice without any errors
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def fields = record.fields
    * def newField = { "tag": "500", "indicators": [ "\\", "\\" ], "content": "$a Test note", "isProtected":false }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 4
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response
    Then match record.updateInfo.recordState == "ACTUAL"
    Then match record.fields contains newField

    * def fields = record.fields
    * def newField = { "tag": "550", "content": "$z Test tag", "indicators": [ "\\", "\\" ], "isProtected":false }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 5
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    Then match record.updateInfo.recordState == "ACTUAL"
    And match response.fields contains newField

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
    * set quickMarcJson.relatedRecordVersion = 1
    * def recordId = quickMarcJson.parsedRecordId
    * set quickMarcJson._actionType = 'edit'

    Given path 'records-editor/records', recordId
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 422
    And match response.message == "Invalid Date1 field length, must be 4 characters"

  Scenario: Record id mismatch for updating
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    * def quickMarcJson = $

    * def wrongRecordId = 'c56b70ce-4ef6-47ef-8bc3-c470bafa0b8c'
    * set quickMarcJson.relatedRecordVersion = 1
    * set quickMarcJson._actionType = 'edit'

    Given path 'records-editor/records', wrongRecordId
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
    * set quickMarcJson._actionType = 'edit'

    Given path 'records-editor/records', 'invalidUUID'
    And headers headersUser
    And request quickMarcJson
    When method PUT
    Then status 400
