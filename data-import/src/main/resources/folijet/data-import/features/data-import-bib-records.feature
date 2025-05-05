Feature: Test Data-Import bib records
  # This feature tests the ability to import and update MARC bibliographic records
  # It creates its own test records to avoid conflicts with other tests
  # The test focuses on two scenarios:
  # 1. Updating a record by matching on a repeatable 250 MARC field
  # 2. Updating a record by matching on a non-repeatable 245 MARC field

  Background:
    # Set up the base URL and authentication
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenUser = okapitoken

    # Define common headers and paths for API requests
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def getCompletedJobFeature = 'classpath:folijet/data-import/features/get-completed-job-execution.feature'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    # Define the record type for all tests in this feature
    * def recordType = "MARC_BIBLIOGRAPHIC"

  # Main scenario that orchestrates the test flow
  # This is the entry point for the test that calls all the other scenarios in sequence
  Scenario: Import and update MARC-BIB records
    # Step 1: Create the initial MARC-BIB record that will be used for testing
    # This creates a single record that will be matched and updated in the subsequent tests
    * call read('@CreateTestRecords')

    # Step 2: Test updating a record by matching on a repeatable 250 MARC field
    # First create the necessary profiles for the repeatable field test
    * call read('@CreateRepeatableFieldProfiles')
    # Then import a file that matches the record on field 250 and updates field 260
    * call read('@ImportAndVerifyRepeatableFieldUpdate')

    # Step 3: Test updating a record by matching on a non-repeatable 245 MARC field
    # First create the necessary profiles for the non-repeatable field test
    * call read('@CreateNonRepeatableFieldProfiles')
    # Then import a file that matches the record on field 245 and updates field 260
    * call read('@ImportAndVerifyNonRepeatableFieldUpdate')

  @ignore @CreateTestRecords
  Scenario: Create MARC-BIB records for testing
    # This scenario creates a single MARC-BIB record that will be used as the base record
    # for the subsequent update tests. The record is imported using the standard import process.
    # The file 'marcBibDataImport.mrc' contains a MARC record with fields that will be matched
    # in the update tests (fields 245 and 250).
    Given def result = call read(utilFeature+'@ImportRecord') { fileName:'marcBibDataImport', jobName:'createInstance' }
    Then match result.status != 'ERROR'
    * def jobExecutionId = result.jobExecutionId

    # Verify that the job execution completed successfully
    # This ensures that the record was properly imported before proceeding with the tests
    * call read(getCompletedJobFeature + '@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

  @ignore @CreateRepeatableFieldProfiles
  Scenario: Create profiles for repeatable field test
    # This scenario creates all the necessary profiles for testing updates based on matching a repeatable field
    # Four types of profiles are created:
    # 1. Mapping Profile - Defines which fields to update (field 260 in this case)
    # 2. Action Profile - Defines the action to take (update in this case)
    # 3. Match Profile - Defines how to match records (using field 250 in this case)
    # 4. Job Profile - Combines the above profiles into a single job

    # Create field mapping profile - Specifies that field 260 will be updated
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def field = 260
    And def mappingProfileName = 'Update repeatable - Bib mapping profile'
    And request read(samplePath + 'profiles/mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile - Specifies that the record will be updated
    # This profile is linked to the mapping profile created above
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'Update repeatable - Bib action profile'
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile - Specifies how to match records
    # This profile matches on field 250 subfield 'a', which is a repeatable field
    # The indicators are empty, meaning they will be ignored in the matching
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

    # Create job profile - Combines the match, action, and mapping profiles
    # This profile will be used when importing the test file
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'Update repeatable - Bib job profile'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

  @ignore @CreateNonRepeatableFieldProfiles
  Scenario: Create profiles for non-repeatable field test
    # This scenario creates all the necessary profiles for testing updates based on matching a non-repeatable field
    # Four types of profiles are created:
    # 1. Mapping Profile - Defines which fields to update (field 260 in this case)
    # 2. Action Profile - Defines the action to take (update in this case)
    # 3. Match Profile - Defines how to match records (using field 245 in this case)
    # 4. Job Profile - Combines the above profiles into a single job

    # Create field mapping profile - Specifies that field 260 will be updated
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def field = 260
    And def mappingProfileName = 'Update non-repeatable - Bib mapping profile'
    And request read(samplePath + 'profiles/mapping-update.json')
    When method POST
    Then status 201
    And def mappingProfileId = $.id

    # Create action profile - Specifies that the record will be updated
    # This profile is linked to the mapping profile created above
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'Update non-repeatable - Bib action profile'
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    And def actionProfileId = $.id

    # Create match profile - Specifies how to match records
    # This profile matches on field 245 subfield 'a', which is a non-repeatable field
    # The indicators '1' and '0' are specified, meaning they must match exactly
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

    # Create job profile - Combines the match, action, and mapping profiles
    # This profile will be used when importing the test file
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'Update non-repeatable - Bib job profile'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    And def jobProfileId = $.id

  @ignore @ImportAndVerifyRepeatableFieldUpdate
  Scenario: Import and verify repeatable field update
    # This scenario tests updating a record by matching on a repeatable field (250)
    # It imports a file that contains a record with the same 250 field as the record created in the setup
    # The imported record has a different 260 field, which should update the existing record

    # Step 1: Import the test file using the job profile created earlier
    # The file 'marcBibMatchedRepeatable.mrc' contains a record with field 250 matching the base record
    # and field 260 with the value "Updated record" that should replace the existing value
    Given def result = call read(utilFeature+'@ImportRecord') { fileName:'marcBibMatchedRepeatable', jobName:'customJob' }
    Then match result.status != 'ERROR'
    * def jobExecutionId = result.jobExecutionId

    # Pause to allow the job to complete
    * call pause 10000

    # Step 2: Verify that the job execution completed successfully
    * call read(getCompletedJobFeature + '@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Step 3: Verify that the record was updated, not created
    # Check the job log entries to confirm the action status is UPDATED
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'UPDATED'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Step 4: Verify that the 260 field was updated with the new value
    # Retrieve the updated record and check that field 260 subfield 'a' contains "Updated record"
    Given path '/source-storage/source-records', sourceRecordId
    And param recordType = 'MARC_BIB'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].260.subfields[*].a contains only "Updated record"

  @ignore @ImportAndVerifyNonRepeatableFieldUpdate
  Scenario: Import and verify non-repeatable field update
    # This scenario tests updating a record by matching on a non-repeatable field (245)
    # It imports a file that contains a record with the same 245 field as the record created in the setup
    # The imported record has a different 260 field, which should update the existing record

    # Step 1: Import the test file using the job profile created earlier
    # The file 'marcBibMatchedNonRepeatable.mrc' contains a record with field 245 matching the base record
    # and field 260 with the value "Updated non-repeatable field" that should replace the existing value
    Given def result = call read(utilFeature+'@ImportRecord') { fileName:'marcBibMatchedNonRepeatable', jobName:'customJob' }
    Then match result.status != 'ERROR'
    * def jobExecutionId = result.jobExecutionId

    # Pause to allow the job to complete
    * call pause 10000

    # Step 2: Verify that the job execution completed successfully
    * call read(getCompletedJobFeature + '@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Step 3: Verify that the record was updated, not created
    # Check the job log entries to confirm the action status is UPDATED
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'UPDATED'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Step 4: Verify that the 260 field was updated with the new value
    # Retrieve the updated record and check that field 260 subfield 'a' contains "Updated non-repeatable field"
    Given path '/source-storage/source-records', sourceRecordId
    And param recordType = 'MARC_BIB'
    And headers headersUser
    When method get
    Then status 200
    Then match response.parsedRecord.content.fields[*].260.subfields[*].a contains only "Updated non-repeatable field"
