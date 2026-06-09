Feature: Import MARC authority records with non-standard 1XX fields via Data import

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json' }

    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * configure retry = { count: 30, interval: 5000 }

  @C554637
  Scenario: Import MARC authority file containing records with multiple 1XX fields and verify both records are created
    # Import file with 2 authority records:
    # - Record 1 has standard 1XX field 110 and additional 1XX field 185
    # - Record 2 has standard 1XX field 110 and additional 1XX field 199
    Given call read(utilFeature+'@ImportRecord') { fileName:'UIQM-676-multiple-1XX', jobName:'createAuthority' }
    Then match status != 'ERROR'

    # Verify both records were imported successfully
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords >= 2 && karate.sizeOf(response.sourceRecords) >= 2 && karate.sizeOf(response.sourceRecords[1].externalIdsHolder) > 0
    When method get
    Then status 200
    And match response.totalRecords == 2

    # Collect all fields from both imported source records
    * def allFieldsRec0 = response.sourceRecords[0].parsedRecord.content.fields
    * def allFieldsRec1 = response.sourceRecords[1].parsedRecord.content.fields

    # Flatten all field tag keys across both records to verify each contains 110 and its second 1XX
    * def rec0Tags = karate.map(allFieldsRec0, function(f){ return Object.keys(f)[0] })
    * def rec1Tags = karate.map(allFieldsRec1, function(f){ return Object.keys(f)[0] })

    # Each record must have a 110 field
    * match rec0Tags contains '110'
    * match rec1Tags contains '110'

    # Together both records must have the secondary 1XX fields (185 and 199)
    * def bothRecordsTags = rec0Tags.concat(rec1Tags)
    * match bothRecordsTags contains '185'
    * match bothRecordsTags contains '199'

    # Verify each authority record is accessible in authority-storage
    * def authorityId0 = response.sourceRecords[0].externalIdsHolder.authorityId
    * def authorityId1 = response.sourceRecords[1].externalIdsHolder.authorityId

    Given path 'authority-storage/authorities', authorityId0
    And headers headersUser
    When method GET
    Then status 200

    Given path 'authority-storage/authorities', authorityId1
    And headers headersUser
    When method GET
    Then status 200

  @C554638
  Scenario: Import MARC authority file containing a record with undefined 1XX field 114 and verify it is created
    # Import file with 1 authority record that has an undefined 1XX field (114)
    Given call read(utilFeature+'@ImportRecord') { fileName:'UIQM-676-undefined-1XX', jobName:'createAuthority' }
    Then match status != 'ERROR'

    # Verify the record was imported successfully
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    And match response.totalRecords == 1

    # Verify that the undefined 1XX field (114) is present in the imported source record
    * def allFields = response.sourceRecords[0].parsedRecord.content.fields
    * def fieldTags = karate.map(allFields, function(f){ return Object.keys(f)[0] })
    * match fieldTags contains '114'

    # Verify the authority record is accessible in authority-storage
    * def authorityId = response.sourceRecords[0].externalIdsHolder.authorityId

    Given path 'authority-storage/authorities', authorityId
    And headers headersUser
    When method GET
    Then status 200
