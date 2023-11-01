Feature: Test import with match on identifier and identifier type

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure retry = { interval: 15000, count: 10 }
    * def marcFilesFolderPath = 'classpath:folijet/data-import/samples/mrc-files/'

  Scenario: FAT-1474 Test import with match on identifier and identifier type
    * def name = "FAT-1474: ID Match Test - Update4 (System control number)"
    * def randomNumber = callonce random
    * def fileName = 'FAT-1474-Create.mrc'
    * def filePath =  marcFilesFolderPath + fileName
    * def uiKey = fileName + randomNumber
    * def result = call read('classpath:folijet/data-import/global/common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey: '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#(filePath)'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def jobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = 'false'
    And headers headersUser
    And request
    """
    {
      "uploadDefinition": '#(result.uploadDefinition)',
      "jobProfileInfo": {
        "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
        "name": "Default - Create instance and SRS MARC Bib",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted') { key: '#(sourcePath)' }
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And match jobExecution.progress == '#present'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2

    # Check instance identifiers from the import log file:
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    * def sourceRecordId1 = response.entries[0].sourceRecordId
    * def sourceRecordId2 = response.entries[1].sourceRecordId

    Given path 'source-storage','records', sourceRecordId1
    And headers headersUser
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains {"035": {"ind1": " ","ind2": " ","subfields": [{"a": "(OCoLC)84714376518561876438"}]}}
    And match response.parsedRecord.content.fields contains {"024": {"ind1": "1","ind2": " ","subfields": [{"a": "ORD32671387-4"}]}}
    And match response.parsedRecord.content.fields contains {"500": {"ind1": " ","ind2": " ","subfields": [{"a": "Description based on print version record."}]}}
    And match response.parsedRecord.content.fields contains {"245": {"ind1": "1","ind2": "0","subfields": [{"a": "Competing with idiots :"},{"b": "Herman and Joe Mankiewicz, a dual portrait /"},{"c": "Nick Davis."}]}}

    Given path 'source-storage','records', sourceRecordId2
    And headers headersUser
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains {"035": {"ind1": " ","ind2": " ","subfields": [{"a": "(AMB)84714376518561876438"}]}}
    And match response.parsedRecord.content.fields contains {"024": {"ind1": "1","ind2": " ","subfields": [{"z": "ORD32671387-4"}]}}
    And match response.parsedRecord.content.fields contains {"500": {"ind1": " ","ind2": " ","subfields": [{"a": "IDENTIFIER TEST: Identifier type INVALID UPC has value ORD32671387-4, and Identifier type SYSTEM CONTROL NUMBER has value (AMB)84714376518561876438"}]}}
    And match response.parsedRecord.content.fields contains {"245": {"ind1": "1","ind2": "0","subfields": [{"a": "Letters from a Stoic :"},{"b": "The Ancient Classic  /"},{"c": "Seneca, with a introduction of Donald Robertson."}]}}

    # Create a new "Matching profile" from the "Settings" page
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "#(name)",
        "description": "#(name)",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "INSTANCE",
            "incomingMatchExpression": {
              "dataValueType": "VALUE_FROM_RECORD",
                "fields": [
                  {
                    "label": "field",
                    "value": "035"
                  },
                  {
                    "label": "indicator1",
                    "value": "*"
                  },
                  {
                    "label": "indicator2",
                    "value": "*"
                  },
                  {
                    "label": "recordSubfield",
                    "value": "a"
                  }
                ],
              "qualifier": {
                "qualifierType": "BEGINS_WITH",
                "qualifierValue": "(AMB"
              }
            },
            "matchCriterion": "EXACTLY_MATCHES",
            "existingMatchExpression": {
              "dataValueType": "VALUE_FROM_RECORD",
              "fields": [
                {
                  "label": "field",
                  "value": "instance.identifiers[].value"
                },
                {
                  "label": "identifierTypeId",
                  "value": "7e591197-f335-4afb-bc6d-a6d76ca3bace"
                }
              ],
              "qualifier": {}
            }
          }
        ],
        "deleted": false,
        "parentProfiles": [],
        "childProfiles": [],
        "hidden": false
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def matchProfileId = response.id

    # Create a new "Field mapping profile" from the "Settings" page
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
    "profile": {
    "name": "#(name)",
    "description": "#(name)",
    "incomingRecordType": "MARC_BIBLIOGRAPHIC",
    "existingRecordType": "INSTANCE",
    "mappingDetails": {
      "name": "instance",
      "recordType": "INSTANCE",
      "mappingFields": [
        {
          "name": "staffSuppress",
          "enabled": "true",
          "path": "instance.staffSuppress",
          "value": "",
          "booleanFieldAction": "ALL_FALSE",
          "subfields": []
        },
        {
          "name": "catalogedDate",
          "enabled": "true",
          "path": "instance.catalogedDate",
          "value": "\"2021-12-04\"",
          "subfields": []
        },
        {
          "name": "statusId",
          "enabled": "true",
          "path": "instance.statusId",
          "value": "",
          "subfields": [],
          "acceptedValues": {
            "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
            "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged"
          }
        }
      ]
    }
    },
    "addedRelations": [],
    "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def mappingProfileId = response.id

    # Create a new "Action profile" from the "Settings" page
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "#(name)",
        "description": "#(name)",
        "action": "UPDATE",
        "folioRecord": "INSTANCE"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(mappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def actionProfileId = response.id

    # Create a new "Job profile" from the "Settings" page

    * def jobProfileName = name
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
    "profile": {
        "name": "#(jobProfileName)",
        "description": "#(jobProfileName)",
        "dataType": "MARC",
        "deleted": false,
        "parentProfiles": [],
        "childProfiles": [],
        "hidden": false,
    },
    "addedRelations": [
        {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(matchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0,
        },
        {
            "masterProfileId": "#(matchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(actionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH",
        }
    ],
    "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfilesId = response.id

    # Import "ID Match Test File - Update4.mrc" file using a job profile from the previous step

    * def randomNumber = callonce random
    * def fileName = 'FAT-1474-Update4.mrc'
    * def filePath =  marcFilesFolderPath + fileName
    * def uiKey = fileName + randomNumber
    * def result = call read('classpath:folijet/data-import/global/common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey: '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#(filePath)'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def jobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = 'false'
    And headers headersUser
    And request
    """
    {
      "uploadDefinition": '#(result.uploadDefinition)',
      "jobProfileInfo": {
        "id": "#(jobProfilesId)",
        "name": "#(jobProfileName)",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted') { key: '#(sourcePath)' }
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And match jobExecution.progress == '#present'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2

    # Verify that needed entities updated
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].instanceActionStatus == 'DISCARDED'
    And assert response.entries[1].instanceActionStatus == 'UPDATED'
    * def sourceRecordId2 = response.entries[1].sourceRecordId

    # verify Instance 1
    Given path 'source-storage','records', sourceRecordId1
    And headers headersUser
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains {"500": {"ind1": " ","ind2": " ","subfields": [{"a": "Description based on print version record."}]}}
    And match response.parsedRecord.content.fields contains {"245": {"ind1": "1","ind2": "0","subfields": [{"a": "Competing with idiots :"},{"b": "Herman and Joe Mankiewicz, a dual portrait /"},{"c": "Nick Davis."}]}}

      # verify Instance 2
    Given path 'source-storage','records', sourceRecordId2
    And headers headersUser
    When method GET
    Then status 200
    And match response.parsedRecord.content.fields contains {"500": {"ind1": " ","ind2": " ","subfields": [{"a": "IDENTIFIER UPDATE 4: This note will show in the Instance notes, if the match triggered an update to the instance. 4-4-4-4-4-4-4-4-4-4-4-4-4"}]}}
    And match response.parsedRecord.content.fields contains {"035": {"ind1": " ","ind2": " ","subfields": [{"a": "(AMB)84714376518561876438"}]}}
    And match response.parsedRecord.content.fields contains {"245": {"ind1": "1","ind2": "0","subfields": [{"a": "Letters from a Stoic :"},{"b": "The Ancient Classic  /"},{"c": "Seneca, with a introduction of Donald Robertson."}]}}
