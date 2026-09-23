Feature: Delete MARC Authority records with multiple matches (by 010 $a then 100 $a)

  # Three authorities share the same 010 $a but contains different 100 $a values: Record A,
  # Record B and Record C (both should be deleted). A job profile for authority deletion
  # contains two match profiles - 010 $a then 100 $a - before the action profile
  # for authority deletion, so only MARC Authorities matching on both fields are removed.
  # Record B and Record C should be deleted. Record A8 is not present in the file for delete authority import,
  # so it should be retained.

  Background:
    * url baseUrl
    * call read('classpath:promin/data-import/global/auth.feature')
    * call read('classpath:promin/data-import/global/common-functions.feature')

    # Authority creation source file carries three records identified by these fixed 001 values; the delete
    # source file carries the last two of them
    * def seedRecordAControlNumber = '13389'
    * def seedRecordBControlNumber = '2426190'
    * def seedRecordCControlNumber = '7394284'
    * def creationFilePath = samplePath + 'mrc-files/C1504488-three-authorities.mrc'
    * def deletionFilePath = samplePath + 'mrc-files/C1504488-two-authorities.mrc'
    * def runId = epoch

  @C1504488
  Scenario: Delete MARC Authority records with multiple matches (by 010 $a then 100 $a)
    # Every run gets its own 001 values and a shared 010 $a, so records left behind by an earlier
    # run against the same tenant never collide with this run's matches
    * def shared010Value = 'n2000012345' + runId
    * def recordB100FieldValue = 'Jones, Mary, ' + runId
    * def recordC100FieldValue = 'Brown, Robert, ' + runId

    # Make 010 and 100 fields value unique for create authorities file per test run so re-runs against reused tenant
    # never match a record left over by the test previous execution.
    * def creationFile = read(creationFilePath)
    * def creationFile = javaWriteData.setFieldValueByControlNumber(creationFile, seedRecordAControlNumber, '010', 'a', shared010Value)
    * def creationFile = javaWriteData.setFieldValueByControlNumber(creationFile, seedRecordBControlNumber, '010', 'a', shared010Value)
    * def creationFile = javaWriteData.setFieldValueByControlNumber(creationFile, seedRecordCControlNumber, '010', 'a', shared010Value)
    * def creationFile = javaWriteData.setFieldValueByControlNumber(creationFile, seedRecordBControlNumber, '100', 'a', recordB100FieldValue)
    * def creationFile = javaWriteData.setFieldValueByControlNumber(creationFile, seedRecordCControlNumber, '100', 'a', recordC100FieldValue)

    * def createFileName = 'C1504488-create-' + runId
    * javaWriteData.writeByteArrayToFile(creationFile, 'target/' + createFileName + '.mrc')

    # Make 010 and 100 fields value unique for delete authorities file per test run so re-runs against reused tenant
    # never match a record left over by the test previous execution.
    * def deleteFile = read(deletionFilePath)
    * def deleteFile = javaWriteData.setFieldValueByControlNumber(deleteFile, seedRecordBControlNumber, '010', 'a', shared010Value)
    * def deleteFile = javaWriteData.setFieldValueByControlNumber(deleteFile, seedRecordCControlNumber, '010', 'a', shared010Value)
    * def deleteFile = javaWriteData.setFieldValueByControlNumber(deleteFile, seedRecordBControlNumber, '100', 'a', recordB100FieldValue)
    * def deleteFile = javaWriteData.setFieldValueByControlNumber(deleteFile, seedRecordCControlNumber, '100', 'a', recordC100FieldValue)

    * def deleteFileName = 'C1504488-delete-' + runId
    * javaWriteData.writeByteArrayToFile(deleteFile, 'target/' + deleteFileName + '.mrc')

    * def res = call read(utilFeature + '@ImportRecord') { fileName: '#(createFileName)', jobName: 'createAuthority', filePathFromSourceRoot: '#("file:target/" + createFileName + ".mrc")' }
    * match res.jobExecution.status == 'COMMITTED'

    # Check job log entries to confirm that three MARC Authority records and their authorities were created
    Given path 'metadata-provider/jobLogEntries', res.jobExecution.id
    And headers headersUser
    And retry until karate.get('response.entries.length') == 3
    When method GET
    Then status 200
    And match each response.entries[*].sourceRecordActionStatus == 'CREATED'
    And match each response.entries[*].relatedAuthorityInfo.actionStatus == 'CREATED'
    # verifies that for all log entries idList size is 1
    And match each response.entries[*].relatedAuthorityInfo.idList == '#[1]'
    * def authorityIdA = response.entries[0].relatedAuthorityInfo.idList[0]
    * def authorityIdB = response.entries[1].relatedAuthorityInfo.idList[0]
    * def authorityIdC = response.entries[2].relatedAuthorityInfo.idList[0]

    # # Create match profile that matches by 010 $a field
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def matchProfileName1 = 'C1504488 match profile 010a ' + runId
    And def recordType = 'MARC_AUTHORITY'
    And def matchProfileName = matchProfileName1
    And def incomeField = '010'
    And def existingField = '010'
    And def incomeSubField = 'a'
    And def existingSubField = 'a'
    And def ind1 = ' '
    And def ind2 = ' '
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    * def matchProfileId1 = $.id

    # Create nested match profile that matches by 100 $a field
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And def matchProfileName = 'C1504488 match profile 100a ' + runId
    And def incomeField = '100'
    And def existingField = '100'
    And def incomeSubField = 'a'
    And def existingSubField = 'a'
    And def ind1 = ' '
    And def ind2 = ' '
    And request read(samplePath + 'profiles/match-profile.json')
    When method POST
    Then status 201
    * def matchProfileId2 = $.id

    # Create job profile for authority deletion with matching by 010 $a and submatching by 100 $a field
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And def jobProfileName = 'C1504488 delete MARC Authority with multiple matching ' + runId
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileId1)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(matchProfileId1)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(matchProfileId2)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(matchProfileId2)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(defaultDeleteAuthorityActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    # Import the file containing Record B and Record C, using the prepared job profile for authority deletion
    * def res = call read(utilFeature + '@ImportRecord') { fileName: '#(deleteFileName)', jobName: 'customJob', filePathFromSourceRoot: '#("file:target/" + deleteFileName + ".mrc")' }
    * match res.jobExecution.status == 'COMMITTED'

    # Check job log entries to confirm that both records were deleted
    Given path 'metadata-provider/jobLogEntries', res.jobExecution.id
    And headers headersUser
    And retry until karate.get('response.entries.length') == 2
    When method GET
    Then status 200
    And match each response.entries[*].sourceRecordActionStatus == 'DELETED'
    And match each response.entries[*].relatedAuthorityInfo.actionStatus == 'DELETED'
    And def deletedAuthorityIds = karate.map(response.entries, e => e.relatedAuthorityInfo.idList[0])
    And match deletedAuthorityIds contains authorityIdB
    And match deletedAuthorityIds contains authorityIdC

    # Record B and Record C are not found
    Given path 'authority-storage/authorities', authorityIdB
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    Given path 'authority-storage/authorities', authorityIdC
    And headers headersUser
    And retry until responseStatus == 404
    When method GET
    Then status 404

    # Record A is present, since Record A is not present in the delete file
    Given path 'authority-storage/authorities', authorityIdA
    And headers headersUser
    When method GET
    Then status 200
    And match response.id == authorityIdA

    # Neither Record B nor Record C is found anymore
    Given path 'search/authorities'
    And param query = 'keyword all "Jones, Mary, "'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'search/authorities'
    And param query = 'keyword all "Brown, Robert, "'
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0
