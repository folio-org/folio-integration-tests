Feature: Test quickMARC authority records

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * configure readTimeout = 300000

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }

    * def testAuthorityId = karate.properties['authorityId']

  # ================= positive test cases =================

  Scenario: Edit quick-marc record tags
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response
    And def tag = karate.jsonPath(record, "$.fields[?(@.tag=='551')]")[0]

    * def newTagContent = '$a Updated Content'
    * set tag.content = newTagContent
    * remove record.fields[?(@.tag=='551')]
    * record.fields.push(tag)
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match karate.jsonPath(response, "$.fields[?(@.tag=='551')]")[0].content == newTagContent

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method GET
    Then status 200
    And match response.sourceRecords[0].parsedRecord.content.fields[*].551 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.saftGeographicName[0] == "Updated Content"

  Scenario: Edit quick-marc record delete not required tag
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * remove record.fields[?(@.tag=='551')]
    * set record.relatedRecordVersion = 2
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='551')] == []

    Given path '/source-storage/source-records', record.parsedRecordDtoId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields[*].551 == []

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.saftGeographicName == []

  Scenario: Edit quick-marc record add new tag, should be updated in SRS
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def fields = record.fields
    * def newField = { "tag": "550", "content": "$z Test tag", "indicators": [ "\\", "\\" ], "isProtected":false }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 3
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields contains newField

    Given path '/source-storage/source-records', record.parsedRecordDtoId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method GET
    Then status 200
    Then match response.parsedRecord.content.fields[*].550 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    Then match response.saftTopicalTerm contains "Test tag"

  Scenario: Should update record twice without any errors
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
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
    And param externalId = testAuthorityId
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
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    Then match record.updateInfo.recordState == "ACTUAL"
    And match response.fields contains newField

 #   ================= negative test cases =================

  Scenario: Attempt to create a duplicate 100
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def fields = record.fields
    * def newField = { "tag": "100", "content": "$a Johnson, W. Brad", "isProtected":false }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 4
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.issues == '#[3]'
    Then match each response.issues[*].severity == "error"
    Then match each response.issues[*].definitionType == "field"
    Then match response.issues[*].tag contains only ["100[0]", "100[1]", "100[1]"]
    Then match response.issues[*].message contains only ["Field 1XX is non-repeatable and required.", "Field 1XX is non-repeatable and required.", "Field is non-repeatable."]

  Scenario: Attempt to delete 100
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * remove record.fields[?(@.tag=='100')]
    * set record.relatedRecordVersion = 7
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.issues == '#[1]'
    Then match response.issues[0].severity == "error"
    Then match response.issues[0].definitionType == "field"
    Then match response.issues[0].tag == "1XX[0]"
    Then match response.issues[0].message == "Field 1XX is non-repeatable and required."

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.personalName == "Johnson"
