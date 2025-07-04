Feature: Test Data-Import holdings records

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'

    * def testInstanceRecordId = karate.properties['instanceRecordId']
    * def testHoldingsRecordId = karate.properties['holdingsRecordId']

  Scenario: Record should contain valid 004 field
    Given path '/source-storage/source-records', testInstanceRecordId
    And param recordType = 'MARC_BIB'
    And headers headersUser
    When method get
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    And def instanceHrid = response.externalIdsHolder.instanceHrid

    Given path '/source-storage/source-records', testHoldingsRecordId
    And param recordType = 'MARC_HOLDING'
    And headers headersUser
    When method get
    Then status 200
    And match response.parsedRecord.content.fields[*].004 contains only instanceHrid

  Scenario: Record should contain 008 tag
    Given path '/source-storage/source-records', testHoldingsRecordId
    And param recordType = 'MARC_HOLDING'
    And headers headersUser
    When method get
    Then status 200
    And match response.parsedRecord.content.fields[*].008 != null

  Scenario: Record should contain valid 852 location code
    Given path '/source-storage/source-records', testHoldingsRecordId
    And param recordType = 'MARC_HOLDING'
    And headers headersUser
    When method get
    Then status 200
    And match response.parsedRecord.content.fields[*].852.subfields[*].b contains only "KU/CC/DI/A"

    #   ================= negative test cases =================

  Scenario: Record contains invalid 004 and not linked to instance record HRID
    * def expectedMessage = "The 004 tag of the Holdings doesn't has a link to the Bibliographic record"

    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsNotValid004', jobName:'createHoldings' }
    Then match jobExecution.status == 'ERROR'
    Then match response.entries[*].error contains only ['#(expectedMessage)', '']

  Scenario: Record does not contain a MARC 008 tag
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsWithout008', jobName:'createHoldings' }
    Then match jobExecution.status == 'COMMITTED'

  Scenario: Record does not contain a valid 852 $b location code
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsInvalid852', jobName:'createHoldings' }
    Then match jobExecution.status == 'ERROR'

  Scenario: File contains missing MARC tags
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldingsWith290Tag', jobName:'createHoldings' }
    Then match jobExecution.status == 'COMMITTED'
