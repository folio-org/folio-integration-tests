Feature: Test Data-Import authority records

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:folijet/data-import/samples/'
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'

    * def testAuthorityId = karate.properties['authorityId']
    * def testAuthorityRecordId = karate.properties['authorityRecordId']
    * def testInvalidAuthorityId = karate.properties['invalidAuthorityId']
    * def testInvalidAuthorityRecordId = karate.properties['invalidAuthorityRecordId']
    * def defaultActionCreateId = "7915c72e-c6af-4962-969d-403c7238b051"

    * def recordType = "MARC_AUTHORITY"

  # ================= positive test cases =================

  Scenario: Record should contains a valid 1XX
    Given path '/source-storage/source-records', testAuthorityRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].100 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    And def personalName = response.personalName
    And match personalName != null
    And match personalName == "Johnson, W. Brad"

  Scenario: Record should contains a 001 value
    Given path '/source-storage/source-records', testAuthorityRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].001 != null

    Given path 'authority-storage/authorities', testAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def identifiers = response.identifiers
    And match identifiers != null
    And match identifiers[0].value == "n  00001263 "

  Scenario: Record should update 551 field by matching on a repeatable 680 MARC field
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def mappingProfileName = 'Update repeatable - Authority mapping profile'
    And request read(samplePath + 'profiles/authority-mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'Update repeatable - Authority action profile'
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def incomeField = 680
    And def incomeSubField = 'a'
    And def existingField = 680
    And def existingSubField = 'b'
    And def ind1 = ''
    And def ind2 = ''
    And def matchProfileName = 'Update repeatable - Authority match profile'
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'Update repeatable - Authority job profile'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import file
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityMatchedRepeatable', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = recordType
    And param snapshotId = jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].551.subfields[*].a contains only "Updated record"

  Scenario: Record should update 551 field by matching on non-repeatable 010 MARC field
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def mappingProfileName = 'Update non-repeatable - Authority mapping profile'
    And request read(samplePath + 'profiles/authority-mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'Update non-repeatable - Authority action profile'
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def incomeField = '010'
    And def incomeSubField = 'a'
    And def existingField = '010'
    And def existingSubField = 'a'
    And def ind1 = ' '
    And def ind2 = ' '
    And def matchProfileName = 'Update non-repeatable - Authority match profile'
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'Update non-repeatable - Authority job profile'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import file
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityMatchedNonRepeatable', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = recordType
    And param snapshotId = jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].551.subfields[*].a contains only "Updated record by non-repeatable field"

  Scenario: Create MARC Authority by non-match profile
    # Create field mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def mappingProfileName = 'Create by non-match - Authority mapping profile'
    And request read(samplePath + 'profiles/authority-mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create match profile
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def matchProfileName = 'Create by non-match - Authority match profile'
    And def incomeField = '100'
    And def incomeSubField = 'a'
    And def existingField = '100'
    And def existingSubField = 'a'
    And def ind1 = '1'
    And def ind2 = ''
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    And def matchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def nonMatchActionProfileId = defaultActionCreateId
    And def jobProfileName = 'Create by non-match - Authority job profile'
    And request read(samplePath + 'profiles/non-match-job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

    # Import file
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityNonMatched', jobName:'customJob' }
    Then match status != 'ERROR'

    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And param snapshotId = jobExecutionId
    And headers headersUser
    And retry until response.totalRecords > 0 && karate.sizeOf(response.sourceRecords[0].externalIdsHolder) > 0
    When method get
    Then status 200
    Then match response.sourceRecords[0].parsedRecord.content.fields[*].100.subfields[*].a contains only "Create record by non match"

  Scenario: Test includes more than one Authority record
    Given path '/source-storage/source-records'
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    And retry until response.totalRecords > 1
    When method get
    Then status 200

  # ================= negative test cases =================

  Scenario: Record should contains an invalid 1XX
    Given path '/source-storage/source-records', testInvalidAuthorityRecordId
    And param recordType = 'MARC_AUTHORITY'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].100 == []

    Given path 'authority-storage/authorities', testInvalidAuthorityId
    And headers headersUser
    When method GET
    Then status 200
    And def personalNameTitle = response.personalNameTitle
    And match personalNameTitle == null


  Scenario: Record should contains No 001 value
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcAuthorityInvalid', jobName:'createAuthority' }
    Then match status == 'ERROR'
