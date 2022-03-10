Feature: Test quickMARC holdings records
  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def utilFeature = 'classpath:spitfire/mod-quick-marc/features/setup/import-record.feature'
    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/setup/samples/'

    * def testInstanceId = karate.properties['instanceId']
    * def testHoldingsId = karate.properties['holdingsId']
    * def testQMHoldingsId = karate.properties['QMHoldingsId']

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

  Scenario: Quick-marc record should contains a valid 004 field
    Given path 'records-editor/records'
    And param externalId = testInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And def instanceHrid = response.externalHrid

    Given path 'records-editor/records'
    And param externalId = testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='004')]")[0]
    Then match tag.content == instanceHrid

  Scenario: Quick-marc record should contains a 008 tag
    Given path 'records-editor/records'
    And param externalId = testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.fields[?(@.tag=='008')].content != null

  Scenario: Quick-marc record should contains a valid 852 location code
    Given path 'records-editor/records'
    And param externalId = testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And def tag = karate.jsonPath(response, "$.fields[?(@.tag=='852')]")[0]
    Then match tag.content != null
    Then match tag.content contains "$b permanentLocationId $h Test 852h tag"

  Scenario: Quick-marc record should be created in SRS
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = karate.properties['QMHoldingsJobId']
    And headers headersUser
    When method get
    Then status 200
    And match response.totalRecords != 0

  Scenario: Quick-marc record should be created and mapped in Inventory
    Given path 'holdings-storage/holdings', testQMHoldingsId
    And headers headersUser
    When method GET
    Then status 200
    And match response.formerIds contains 'Test 035 tag'
    And match response.callNumber == 'Test 852h tag'
    And match response.holdingsStatements contains {"statement": "Test 866 tag"}
    And match response.holdingsStatementsForIndexes contains {"statement": "Test 868 tag"}

  #   ================= negative test cases =================

  Scenario: Record contains invalid 004 and not linked to instance record HRID
    * def expectedMessage = "The 004 tag of the Holdings doesn't has a link to the Bibliographic record"

    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsNotValid004', jobName:'createHoldings' }
    Then match status == 'ERROR'
    Then match errorMessage == expectedMessage

  Scenario: Quick-marc record contains invalid 004 and not linked to instance record HRID
    * def expectedMessage = "The 004 tag of the Holdings doesn't has a link to the Bibliographic record"
    * def holdings = read(samplePath + 'parsed-records/holdings.json')
    * set holdings.fields[?(@.tag=='004')].content = 'wrongHrid'

    Given path 'records-editor/records'
    And headers headersUser
    And request holdings
    When method POST
    Then status 201
    Then match response.status == 'NEW'

    Given path 'records-editor/records/status'
    And param qmRecordId = response.qmRecordId
    And headers headersUser
    And retry until response.status == 'CREATED' || response.status == 'ERROR'
    When method GET
    Then status 200
    Then match response.status == 'ERROR'
    Then match response.errorMessage == expectedMessage
