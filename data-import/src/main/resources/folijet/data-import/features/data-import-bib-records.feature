Feature: Test Data-Import bib records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    * def recordType = "MARC_BIBLIOGRAPHIC"

  Scenario: Record should update 260 field by matching on a repeatable MARC field
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def field = 260
    And request read(samplePath + 'profiles/mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def incomeField = 250
    And def incomeSubField = 'a'
    And def existingField = 250
    And def existingSubField = 'a'
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import file
    Given call read(utilFeature+'@ImportRecord') { fileName:'marc-bib-matched', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].260.subfields contains "Updated record"

