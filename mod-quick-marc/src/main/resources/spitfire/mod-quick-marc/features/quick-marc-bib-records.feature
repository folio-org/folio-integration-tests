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
    * def fieldWithLink = {"tag": "100", "indicators": [ "\\", "1" ], "content":'#("$a Johnson" + linkContent)', "isProtected":false, "linkDetails":{ "authorityId":#(linkedAuthorityId), "authorityNaturalId":#(authorityNaturalId), "linkingRuleId":1, "status":"ACTUAL" } }
    * def repeatedFieldNoLink = {"tag": "600", "indicators": [ "0", "1" ], "content":"$a Linkable field", "isProtected":false }
    * def repeatedFieldWithLink = {"tag": "600", "indicators": [ "\\", "\\" ], "content":'#("$a Johnson" + linkContent)', "isProtected":false, "linkDetails":{ "authorityId":#(linkedAuthorityId), "authorityNaturalId":#(authorityNaturalId), "linkingRuleId":8, "status":"ACTUAL" } }
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
    * def newField1 = { "tag": "500", "indicators": [ "\\", "\\" ], "content": "$a Test note", "isProtected":false }
    * def newField2 = { "tag": "248", "indicators": [ "a", "b" ], "content": "$a Local field $b repeatable1 $b repeatable2", "isProtected":false }
    * fields.push(newField1)
    * fields.push(newField2)
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
    And match result.fields contains newField1
    And match result.fields contains newField2

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
    * def newField = { "tag": "240", "indicators": [ "\\", "\\" ], "content":'#("$a Test note" + linkContent)', "isProtected":false, "linkDetails":{ "authorityId":#(linkedAuthorityId), "authorityNaturalId":#(authorityNaturalId), "linkingRuleId": 5, "status":"ERROR", "errorCause":"test"  } }
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

  Scenario: Create bib record
    * def quickMarcJson =
    """
    {
        "externalId": "00000000-0000-0000-0000-000000000000",
        "leader": "00000naa\\a2200000uu\\4500",
        "parsedRecordDtoId": "00000000-0000-0000-0000-000000000000",
        "relatedRecordVersion": 1,
        "marcFormat": "BIBLIOGRAPHIC",
        "suppressDiscovery": false,
        "updateInfo": {
            "recordState": "NEW"
        },
        "_actionType": "create",
        "parsedRecordId": "00000000-0000-0000-0000-000000000000",
        "fields": [{"tag": "008","id": "91d9fe1e-a0a5-441a-abf8-7e99076a5ee5","content": {"Type": "a","BLvl": "a","DtSt": "|","Date1": "\\\\\\\\","Date2": "\\\\\\\\","Ctry": "\\\\\\","Ills": ["\\","\\","\\","\\"],"Audn": "\\","Form": "\\","Cont": ["\\","\\","\\","\\"],"GPub": "\\","Conf": "|","Fest": "|","Indx": "|","LitF": "|","Biog": "\\","Lang": "\\\\\\","MRec": "\\","Srce": "\\"}}]
    }
    """
    * def standardRequiredField = { "tag": "245", "indicators": [ "0", "0" ], "content": "$a Standard required field $1 local subfield $7 st rep 1 $2 loc rep 1 $7 st rep 2 $2 loc rep 2", "isProtected":false }
    * def localRequiredField = { "tag": "249", "indicators": [ "0", "0" ], "content": "$a Local required", "isProtected":false }
    * def undefinedField = { "tag": "666", "indicators": [ "0", "0" ], "content": "$a Undefined field", "isProtected":false }
    * def standardField = { "tag": "600", "indicators": [ "0", "0" ], "content": "$a Standard field", "isProtected":false }
    * def localField = { "tag": "248", "indicators": [ "a", "b" ], "content": "$a Local field $b rep 1 $b rep 2", "isProtected":false }
    * quickMarcJson.fields.push(standardRequiredField, localRequiredField, undefinedField, standardField, localField)

    * def validateFields = quickMarcJson.fields
    * validateFields.push({"tag": "001", "content": "hrid0000001"})
    * def marcRecordValidate = {"leader": #(quickMarcJson.leader), "marcFormat": #(quickMarcJson.marcFormat), "fields": #(validateFields)}
    Given path 'records-editor/validate'
    And headers headersUser
    And request marcRecordValidate
    When method POST
    Then status 200
    Then match response.issues == '#[1]'
    Then match response.issues[0].tag == "666[0]"
    Then match response.issues[0].severity == "warn"
    Then match response.issues[0].message == "Field is undefined."

    Given path 'records-editor/records'
    And headers headersUser
    And request quickMarcJson
    When method POST
    Then status 201

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

  Scenario: Record specification violation
    * def quickMarcJson =
    """
    {
        "externalId": "00000000-0000-0000-0000-000000000000",
        "leader": "00000naa\\a2200000uu\\4500",
        "parsedRecordDtoId": "00000000-0000-0000-0000-000000000000",
        "relatedRecordVersion": 1,
        "marcFormat": "BIBLIOGRAPHIC",
        "suppressDiscovery": false,
        "updateInfo": {
            "recordState": "NEW"
        },
        "_actionType": "create",
        "parsedRecordId": "00000000-0000-0000-0000-000000000000",
        "fields": [{"tag": "008","id": "91d9fe1e-a0a5-441a-abf8-7e99076a5ee5","content": {"Type": "a","BLvl": "a","DtSt": "|","Date1": "\\\\\\\\","Date2": "\\\\\\\\","Ctry": "\\\\\\","Ills": ["\\","\\","\\","\\"],"Audn": "\\","Form": "\\","Cont": ["\\","\\","\\","\\"],"GPub": "\\","Conf": "|","Fest": "|","Indx": "|","LitF": "|","Biog": "\\","Lang": "\\\\\\","MRec": "\\","Srce": "\\"}}]
    }
    """
    * def standardRequiredField = { "tag": "245", "indicators": [ "0", "0" ], "content": "$7 rep subfield", "isProtected":false }
    * def localRequiredField = { "tag": "249", "indicators": [ "0", "0" ], "content": "$a Local required", "isProtected":false }
    * def localField = { "tag": "248", "indicators": [ "a", "b" ], "content": "$b rep subfield", "isProtected":false }
    * quickMarcJson.fields.push(standardRequiredField, localRequiredField, localField)

    Given path 'records-editor/records'
    And headers headersUser
    And request quickMarcJson
    When method POST
    Then status 422
    Then match response.issues == '#[3]'
    Then match each response.issues[*].severity == "error"
    Then match each response.issues[*].definitionType == "subfield"
    Then match response.issues[*].tag contains only ["245[0]", "245[0]", "248[0]"]
    Then match response.issues[*].message contains only ["Subfield 'a' is required.", "Subfield 'a' is required.", "Subfield '1' is required."]

    * set standardRequiredField.content = "$a$1 $7 rep subfield"

    Given path 'records-editor/records'
    And headers headersUser
    And request quickMarcJson
    When method POST
    Then status 422
    Then match response.issues == '#[3]'
    Then match each response.issues[*].severity == "error"
    Then match each response.issues[*].definitionType == "subfield"
    Then match response.issues[*].tag contains only ["245[0]", "245[0]", "248[0]"]
    Then match response.issues[*].message contains only ["Subfield 'a' is required.", "Subfield 'a' is required.", "Subfield '1' is required."]

    * set localField.content = "$a req subfield"
    * set quickMarcJson.fields = quickMarcJson.fields.filter(field => field.tag == "008")

    Given path 'records-editor/records'
    And headers headersUser
    And request quickMarcJson
    When method POST
    Then status 422
    Then match response.issues == '#[2]'
    Then match each response.issues[*].severity == "error"
    Then match each response.issues[*].definitionType == "field"
    Then match response.issues[*].tag contains only ["245[0]", "249[0]"]
    Then match response.issues[*].message contains only ["Field 245 is required.", "Field 249 is required."]
