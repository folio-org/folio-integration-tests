Feature: Test quickMARC holdings records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def utilFeature = 'classpath:spitfire/mod-quick-marc/features/setup/import-record.feature'

    * def testInstanceId = karate.properties['instanceId']
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
    When method get
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
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].550 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    Then match response.saftTopicalTerm contains "Test tag"

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
    Then match response.errors[0].message == 'Is unique tag'

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
    Then match response.errors[0].message == 'Is required tag'

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And match response.personalName == "Johnson, W. Brad"