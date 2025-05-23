Feature: FAT-1473

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-1473 Test OCLC import doesn't duplicate control fields
    * def profileId = 'f26df83c-aa25-40b6-876e-96852c3d4fd4'
    * def externalIdentifierType = "439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef"

    # Assign authentication
    Given path 'copycat/profiles', profileId
    And headers headersUser
    And request
      """
      {
        "id": "#(profileId)",
        "name": "OCLC WorldCat",
        "url": "zcat.oclc.org/OLUCWorldCat",
        "authentication": "100481406/PAOLF",
        "externalIdQueryMap": "@attr 1=1211 $identifier",
        "internalIdEmbedPath": "999ff$i",
        "createJobProfileId": "d0ebb7b0-2f0f-11eb-adc1-0242ac120002",
        "updateJobProfileId": "91f9b8d6-d80e-4727-9783-73fb53e3c786",
        "allowedCreateJobProfileIds": ["d0ebb7b0-2f0f-11eb-adc1-0242ac120002"],
        "allowedUpdateJobProfileIds": ["91f9b8d6-d80e-4727-9783-73fb53e3c786"],
        "targetOptions": {
          "charset": "utf-8"
        },
        "externalIdentifierType": "#(externalIdentifierType)",
        "enabled": true
      }
      """
    When method PUT
    Then status 204

    # Import OCLC record
    Given path 'copycat/imports'
    And headers headersUser
    And request
      """
      {
        "externalIdentifier": "42668854",
        "profileId": "#(profileId)"
      }
      """
    When method POST
    Then status 200

    # Retrieve import id
    Given path 'metadata-provider/jobExecutions'
    And headers headersUser
    And retry until response.jobExecutions[0].status == 'COMMITTED' || response.jobExecutions[0].status == 'ERROR' || response.jobExecutions[0].status == 'DISCARDED'
    And param fileName = "No file name"
    And param sortBy = "completed_date,desc"
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id

    # Check imported file name
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.entries[0].sourceRecordTitle == 'Space architecture : the work of John Frassanito & Associates for NASA / John Zukowsky ; with a preface by Buzz Aldrin.'
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance source
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def instanceId = response.externalIdsHolder.instanceId
    * def parsedRecord = response.parsedRecord

    # Overlay source bibliographic record
    Given path 'copycat/imports'
    And headers headersUser
    And request
      """
      {
        "externalIdentifier": "42668854",
        "internalIdentifier": "#(instanceId)",
        "profileId": "#(profileId)"
      }
      """
    When method POST
    Then status 200

    # Retrieve import id
    Given path 'metadata-provider/jobExecutions'
    And headers headersUser
    And retry until response.jobExecutions[0].status == 'COMMITTED' || response.jobExecutions[0].status == 'ERROR' || response.jobExecutions[0].status == 'DISCARDED'
    And param fileName = "No file name"
    And param sortBy = "started_date,desc"
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id

    # Check imported file name
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.entries[0].sourceRecordTitle == 'Space architecture : the work of John Frassanito & Associates for NASA / John Zukowsky ; with a preface by Buzz Aldrin.'
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Compare instance source data
    Given path 'source-storage/source-records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def overlayParsedRecord = response.parsedRecord
    And match overlayParsedRecord.content.fields[0] == parsedRecord.content.fields[0]
    And match $overlayParsedRecord.content.fields[?(@.005)] != $parsedRecord.content.fields[?(@.005)]
    And match containsDuplicatesOfFields(overlayParsedRecord.content.fields, ['006', '007', '008']) == false
