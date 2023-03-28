Feature: Test Data-Import bib records
  # The following tests relies on folijet/data-import/samples/mrc-files/marcBib.mrc to be imported only once.
  # This should have been imported by create-marc-records.feature

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    * def recordType = "MARC_BIBLIOGRAPHIC"

  Scenario: Record should update 260 field by matching on a repeatable 250 MARC field
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def field = 260
    And def mappingProfileName = 'Update repeatable - Bib mapping profile'
    And request read(samplePath + 'profiles/mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'Update repeatable - Bib action profile'
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
    And def ind1 = ''
    And def ind2 = ''
    And def matchProfileName = 'Update repeatable - Bib match profile'
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'Update repeatable - Bib job profile'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import file
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcBibMatchedRepeatable', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].260.subfields[*].a contains only "Updated record"

  Scenario: Record should update 260 field by matching on a non-repeatable 245 MARC field
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def field = 260
    And def mappingProfileName = 'Update non-repeatable - Bib mapping profile'
    And request read(samplePath + 'profiles/mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'Update non-repeatable - Bib action profile'
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def incomeField = 245
    And def incomeSubField = 'a'
    And def existingField = 245
    And def existingSubField = 'a'
    And def ind1 = '1'
    And def ind2 = '0'
    And def matchProfileName = 'Update non-repeatable - Bib match profile'
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'Update non-repeatable - Bib job profile'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import file
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcBibMatchedNonRepeatable', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_BIB'
    And param snapshotId = jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].260.subfields[*].a contains only "Updated non-repeatable field"

