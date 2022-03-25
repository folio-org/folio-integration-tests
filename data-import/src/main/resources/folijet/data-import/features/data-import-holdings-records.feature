Feature: Test Data-Import holdings records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'

    * def testInstanceRecordId = karate.properties['instanceRecordId']
    * def testHoldingsRecordId = karate.properties['holdingsRecordId']

  Scenario: Record should contains a valid 004 field
    Given path '/source-storage/source-records', testInstanceRecordId
    And param recordType = 'MARC_BIB'
    And headers headersUser
    When method get
    Then status 200
    And def instanceHrid = response.externalIdsHolder.instanceHrid

    Given path '/source-storage/source-records', testHoldingsRecordId
    And param recordType = 'MARC_HOLDING'
    And headers headersUser
    When method get
    Then status 200
    And def tag = response.parsedRecord.content.fields[*].004
    Then match tag.content == instanceHrid

  Scenario: Record should contains a 008 tag
    Given path '/source-storage/source-records', testHoldingsRecordId
    And param recordType = 'MARC_HOLDING'
    And headers headersUser
    When method get
    Then status 200
    And match response.parsedRecord.content.fields[*].008 != null

  Scenario: Record should contains a valid 852 location code
    Given path '/source-storage/source-records', testHoldingsRecordId
    And param recordType = 'MARC_HOLDING'
    And headers headersUser
    When method get
    Then status 200
    And def tag = response.parsedRecord.content.fields[*].004
    Then match tag.content != null
    Then match tag.content contains "$b KU/CC/DI/A"

  #   ================= negative test cases =================

  Scenario: Record contains invalid 004 and not linked to instance record HRID
    * def expectedMessage = "The 004 tag of the Holdings doesn't has a link to the Bibliographic record"

    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsNotValid004', jobName:'createHoldings' }
    Then match status == 'ERROR'
    Then match errorMessage == expectedMessage

  Scenario: Record does not contain a MARC 008 tag
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsWithout008', jobName:'createHoldings' }
    Then match status == 'COMMITTED'

  Scenario: Does not contain a valid 852 $b location code
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsInvalid852', jobName:'createHoldings' }
    Then match status == 'ERROR'

  Scenario: File contains missing MARC tags
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsWith290Tag', jobName:'createHoldings' }
    Then match status == 'ERROR'