Feature: Create marc records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'

  Scenario: Create MARC Authority via Data Import
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthority', jobName:'createAuthority' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

    * def testAuthorityId = response.sourceRecords[0].externalIdsHolder.authorityId
    * def testAuthorityRecordId = response.sourceRecords[0].recordId

    * setSystemProperty('authorityId', testAuthorityId)
    * setSystemProperty('authorityRecordId', testAuthorityRecordId)

  Scenario: Create MARC Authority via Data Import (not valid 1XX)
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityInvalid1XX', jobName:'createAuthority' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200

    * def testAuthorityId = response.sourceRecords[0].externalIdsHolder.authorityId
    * def testAuthorityRecordId = response.sourceRecords[0].recordId

    * setSystemProperty('invalidAuthorityId', testAuthorityId)
    * setSystemProperty('invalidAuthorityRecordId', testAuthorityRecordId)

  Scenario: Create MARC-BIB record via Data Import
    Given call read(utilFeature+'@ImportRecord') { fileName:'marc-bib', jobName:'createInstance' }
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
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldings', jobName:'createHoldings' }
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



