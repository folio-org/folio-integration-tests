Feature: FAT-21076 - Update existing record using marc-to-marc match with 00x field

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')
    * configure retry = { interval: 5000, count: 30 }

  @C422000
  Scenario: FAT-21076 Update existing MARC Bib record using 008 field match
    # Import FAT-21076.mrc with the "Default - Create instance and SRS MARC Bib" job profile to create instance
    * def res = call read(utilFeature+'@ImportRecord') { fileName:'FAT-21076', jobName:'createInstance' }
    * match res.jobExecution.status == 'COMMITTED'

    # Check job log entries to confirm that instance and MARC-Bib record were created.
    * call login testUser
    Given path 'metadata-provider/jobLogEntries', res.jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == 'CREATED'
    And match response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And match response.entries[0].error == ''

    # Step 3: Create mapping profile for MARC-Bibliographic record update
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And def recordType = 'MARC_BIBLIOGRAPHIC'
    And def mappingProfileName = 'FAT-21076 Updating file by 008 match'
    And request read(samplePath + 'profiles/update-entire-marc-record-mapping-profile.json')
    When method POST
    Then status 201
    * def mappingProfileId = $.id

    # Create UPDATE MARC-Bibliographic action profile
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And def actionProfileName = 'FAT-21076 Updating file by 008 match'
    And request read(samplePath + 'profiles/action-update.json')
    When method POST
    Then status 201
    * def actionProfileId = $.id

    # Create match profile that matches by 008 field.
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def matchProfileName = 'FAT-21076 Updating file by 008 match'
    And def incomeField = '008'
    And def existingField = '008'
    And def ind1 = ''
    And def ind2 = ''
    And def incomeSubField = ''
    And def existingSubField = ''
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    * def matchProfileId = $.id

    # Create job profile for MARC-Bib update
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'FAT-21076 Updating file by 008 match'
    And request read(samplePath + 'profiles/job-profile.json')
    When method POST
    Then status 201
    * def updateJobProfileId = $.id

    # Import the updated file FAT-21076-UPDATED.mrc where value in the 245$a is prepended by "TEST"
    * def jobProfileId = updateJobProfileId
    * def res = call read(utilFeature+'@ImportRecord') { fileName:'FAT-21076-UPDATED', jobName:'customJob' }
    * match res.jobExecution.status == 'COMMITTED'

    # Check job log entries that MARC-Bibliographic record and instance were updated.
    Given path 'metadata-provider/jobLogEntries', res.jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == 'UPDATED'
    And match response.entries[0].relatedInstanceInfo.actionStatus == "UPDATED"
    And match response.entries[0].error == ''
    And def updatedInstanceId = response.entries[0].relatedInstanceInfo.idList[0]

    # Verify that updated MARC Bibliographic record contains the changed 245$a value ("TEST" prefix)
    # same as in the imported file FAT-21076-UPDATED.mrc
    Given path 'source-storage/records', updatedInstanceId, 'formatted'
    And headers headersUser
    And param idType = 'INSTANCE'
    When method GET
    Then status 200
    And def srsFields = response.parsedRecord.content.fields
    And def field245List = karate.jsonPath(srsFields, "$[?(@['245'])]")
    And match field245List == '#[1]'
    And def subfields245 = field245List[0]['245'].subfields
    And def subfieldA = karate.jsonPath(subfields245, "$[?(@['a'])].a")[0]
    And match subfieldA contains 'TEST'
