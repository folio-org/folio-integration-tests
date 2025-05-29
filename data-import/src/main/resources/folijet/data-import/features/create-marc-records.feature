Feature: Create marc records

  Background:
    * url baseUrl
    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'

  Scenario: Create all MARC records and return IDs
    # Create MARC Authority
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthority', jobName:'createAuthority' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    * def authorityId = response.sourceRecords[0].externalIdsHolder.authorityId
    * def authorityRecordId = response.sourceRecords[0].recordId

    # Create MARC Authority (invalid 1XX)
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityInvalid1XX', jobName:'createAuthority' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    * def invalidAuthorityId = response.sourceRecords[0].externalIdsHolder.authorityId
    * def invalidAuthorityRecordId = response.sourceRecords[0].recordId

    # Create MARC-BIB record
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcBib', jobName:'createInstance' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    * def instanceRecordId = response.sourceRecords[0].recordId

    # Create MARC-HOLDINGS record
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcHoldings', jobName:'createHoldings' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_HOLDING'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    * def holdingsRecordId = response.sourceRecords[0].recordId
    
    # Return all IDs as the result
    * def result = { instanceRecordId: instanceRecordId, holdingsRecordId: holdingsRecordId, authorityId: authorityId, authorityRecordId: authorityRecordId, invalidAuthorityId: invalidAuthorityId, invalidAuthorityRecordId: invalidAuthorityRecordId }