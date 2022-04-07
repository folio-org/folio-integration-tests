Feature: Test quickMARC authority records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def utilFeature = 'classpath:spitfire/mod-quick-marc/features/setup/import-record.feature'

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
    * set record.relatedRecordVersion = 2

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
    * set record.relatedRecordVersion = 3

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

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method GET
    Then status 200
    And match response.sourceRecords[0].parsedRecord.content.fields[*].551 == []

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
    * set record.relatedRecordVersion = 4

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

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method GET
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].550 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    Then match response.saftTopicalTerm contains "Test tag"

  @Report=false
  #Should be removed after fixing bug with deleting authority
  Scenario: Delete authority record
    Given path 'records-editor/records', karate.properties['authorityIdForDelete']
    And headers headersUser
    When method DELETE

  Scenario: Delete quick-marc record, should be deleted in SRS and inventory
    * def authorityIdForDelete = karate.properties['authorityIdForDelete']

    Given path 'records-editor/records', authorityIdForDelete
    And headers headersUser
    When method DELETE
    Then assert responseStatus == 204 || responseStatus == 400

    Given path 'records-editor/records'
    And param externalId = authorityIdForDelete
    And headers headersUser
    When method GET
    Then status 404
    And match response.code == "NOT_FOUND"

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    And match response.sourceRecords[1].state == "DELETED"
    And match response.sourceRecords[1].deleted == true

    Given path 'authority-storage/authorities', authorityIdForDelete
    And headers headersUser
    When method GET
    Then status 404

  Scenario: FAT-1619 Should update record twice without any errors
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
    * set record.relatedRecordVersion = 5

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
    Then match record.fields contains newField

    * def fields = record.fields
    * def newField = { "tag": "550", "content": "$z Test tag", "indicators": [ "\\", "\\" ], "isProtected":false }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 6

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
    * set record.relatedRecordVersion = 5

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.message == 'Is unique tag'

  Scenario: Attempt to delete 100
    Given path 'records-editor/records'
    And param externalId = testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * remove record.fields[?(@.tag=='100')]
    * set record.relatedRecordVersion = 5

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.message == 'Is required tag'

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.personalName == "Johnson, W. Brad"

  Scenario: Attempt to delete record with invalid id
    Given path 'records-editor/records', 'invalidId'
    And headers headersUser
    When method DELETE
    Then status 400
    And match response.message == "Parameter 'id' is invalid"

  Scenario: Attempt to delete not existed record
    Given path 'records-editor/records', '00000000-0000-0000-0000-000000000000'
    And headers headersUser
    When method DELETE
    Then status 404
    And match response.code == "NOT_FOUND"