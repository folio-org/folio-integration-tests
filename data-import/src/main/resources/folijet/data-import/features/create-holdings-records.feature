Feature: Create instance and holdings records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

  Scenario: Create MARC-BIB record via Data Import
    Given call read('classpath:folijet/data-import/global/import-record.feature@ImportRecord') { fileName:'marc-bib', jobName:'createInstance' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

    * def testInstanceRecordId = response.sourceRecords[0].recordId

    * setSystemProperty('instanceRecordId', testInstanceRecordId)

  Scenario: Create MARC-HOLDINGS record via Data Import
    Given call read('classpath:folijet/data-import/global/import-record.feature@ImportRecord') { fileName:'marcHoldings', jobName:'createHoldings' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

    * def testHoldingsRecordId = response.sourceRecords[0].recordId

    * setSystemProperty('holdingsRecordId', testHoldingsRecordId)