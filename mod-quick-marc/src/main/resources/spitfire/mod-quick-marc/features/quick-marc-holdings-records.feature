Feature: Test quickMARC holdings records
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/setup/samples/'

    * def testInstanceId = karate.properties['instanceId']
    * def testHoldingsId = karate.properties['holdingsId']
    * def externalHrid = 'in00000000002'

  # ================= positive test cases =================

  Scenario: Record should contains a valid 004 field
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def instanceHrid = response.externalHrid

    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='004')]")[0]
    Then match tag.content == instanceHrid

  Scenario: Record should contains a 008 tag
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='008')].content != null

  Scenario: Record should contains a valid 852 location code
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='852')]")[0]
    Then match tag.content != null
    Then match tag.content contains "$b olin"

  Scenario: Record should be created via quick-marc
    #Create record
    * def record = read(samplePath + 'parsed-records/holdings.json')
    * set record._actionType = 'create'

    Given path 'records-editor/records'
    And headers headersUser
    And request record
    When method POST
    Then status 201
    Then assert response.status == 'NEW' || response.status == 'IN_PROGRESS'
    And def jobExecutionId = response.jobExecutionId

    #Check status
    Given path 'records-editor/records/status'
    And param qmRecordId = response.qmRecordId
    And headers headersUser
    And retry until response.status == 'CREATED' || response.status == 'ERROR'
    When method GET
    Then status 200
    Then match response.status != 'ERROR'
    And def recordId = response.externalId

    #Check srs creation
    Given path 'source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And match response.totalRecords != 0

    #Check inventory creation
    Given path 'holdings-storage/holdings', recordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.formerIds contains 'Test 035 tag'
    And match response.callNumber == 'Test 852h tag'
    And match response.holdingsStatements contains {"statement": "Test 866 tag"}
    And match response.holdingsStatementsForIndexes contains {"statement": "Test 868 tag"}

    #Should contains a valid 004 field
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def instanceHrid = response.externalHrid

    Given path 'records-editor/records'
    And param externalId = recordId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='004')]")[0]
    Then match tag.content == instanceHrid

    #Should contains a 008 tag
    Given path 'records-editor/records'
    And param externalId = recordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='008')].content != null

    #Should contains a valid 852 location code
    Given path 'records-editor/records'
    And param externalId = recordId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='852')]")[0]
    Then match tag.content != null
    Then match tag.content contains "$b permanentLocationId $h Test 852h tag"

  Scenario: Edit quick-marc record tags
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response
    And def tag = karate.jsonPath(record, "$.fields[?(@.tag=='867')]")[0]

    * def newTagContent = '$a Updated Content'
    * set tag.content = newTagContent
    * remove record.fields[?(@.tag=='867')]
    * record.fields.push(tag)
    * set record.relatedRecordVersion = 1
    * set record._actionType = 'edit'
    * set record.externalHrid = externalHrid

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match karate.jsonPath(response, "$.fields[?(@.tag=='867')]")[0].content == newTagContent

    Given path 'holdings-storage/holdings', testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.holdingsStatementsForSupplements[0].statement == 'Updated Content'

  Scenario: Edit quick-marc record remove not required tag
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * remove record.fields[?(@.tag=='867')]
    * set record.relatedRecordVersion = 2
    * set record._actionType = 'edit'
    * set record.externalHrid = externalHrid

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='867')] == []

    Given path 'source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = karate.properties['snapshotId']
    And headers headersUser
    When method get
    Then status 200
    And match response.sourceRecords[0].parsedRecord.content.fields[*].867 == []

    Given path 'holdings-storage/holdings', testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.holdingsStatementsForSupplements == []

  Scenario: Edit quick-marc record add new tag, should be updated in SRS
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def fields = record.fields
    * def newField = { "tag": "035", "content": "$a Test tag", "isProtected":false, "indicators": [ "\\", "\\" ] }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 3
    * set record._actionType = 'edit'
    * set record.externalHrid = externalHrid

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields contains newField

    Given path 'source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = karate.properties['holdingsJobId']
    And headers headersUser
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].035 != null

    Given path 'holdings-storage/holdings', testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    Then match response.formerIds contains "Test tag"

  Scenario: Should update record twice without any errors
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
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
    * set record.externalHrid = externalHrid

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 202

    Given path 'records-editor/records'
    And param externalId = testHoldingsId
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
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    Then match record.updateInfo.recordState == "ACTUAL"
    And match response.fields contains newField

  #   ================= negative test cases =================

  Scenario: Quick-marc record contains invalid 004 and not linked to instance record HRID
    * def expectedMessage = "The 004 tag of the Holdings doesn't has a link to the Bibliographic record"
    * def holdings = read(samplePath + 'parsed-records/holdings.json')
    * set holdings.fields[?(@.tag=='004')].content = 'wrongHrid'
    * set holdings._actionType = 'create'

    Given path 'records-editor/records'
    And headers headersUser
    And request holdings
    When method POST
    Then status 201
    And retry until response.status != 'IN_PROGRESS'

    Given path 'records-editor/records/status'
    And param qmRecordId = response.qmRecordId
    And headers headersUser
    When method GET
    Then status 200
    Then match response.status == 'ERROR'
    Then match response.errorMessage == expectedMessage

  Scenario: Attempt to create a duplicate 004
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def fields = record.fields
    * def newField = { "tag": "004", "content": "in00000000002", "isProtected":false }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 4
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.message == 'Is unique tag'

  Scenario: Attempt to create a duplicate 852
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * def fields = record.fields
    * def newField = { "tag": "852", "content": "$b Test", "isProtected": false, "indicators": [ "0", "1" ] }
    * fields.push(newField)
    * set record.fields = fields
    * set record.relatedRecordVersion = 4
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.message == 'Is unique tag'

  Scenario: Attempt to delete 852
    Given path 'records-editor/records'
    And param externalId = testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def record = response

    * remove record.fields[?(@.tag=='852')]
    * set record.relatedRecordVersion = 4
    * set record._actionType = 'edit'

    Given path 'records-editor/records', record.parsedRecordId
    And headers headersUser
    And request record
    When method PUT
    Then status 422
    Then match response.message == 'Is required tag'

    Given path 'holdings-storage/holdings', testHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.callNumber == 'BR140 .J86'
