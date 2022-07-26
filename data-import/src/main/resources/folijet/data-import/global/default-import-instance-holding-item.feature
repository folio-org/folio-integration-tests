Feature: Util feature to import instance, holding, item. Based on FAT-937 scenario steps.

  Background:
    * def entitiesIdMap = {}

  @importInstanceHoldingItem
  Scenario: Import Instance, Holdings, Items. Based on FAT-937 scenario steps.
    * print 'Import Instance, Holdings, Items based on FAT-937 scenario steps'

    # Create mapping profile for Instance
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Instance Mapping profile FAT-937",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "",
        "mappingDetails": {
          "name": "instance",
          "recordType": "INSTANCE",
          "mappingFields": [
            {
              "name": "catalogedDate",
              "enabled": true,
              "path": "instance.catalogedDate",
              "value": "###TODAY###",
              "subfields": []
            },
            {
              "name": "statusId",
              "enabled": true,
              "path": "instance.statusId",
              "value": "\"Batch Loaded\"",
              "subfields": [],
              "acceptedValues": {
                "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged"
              }
            },
            {
              "name": "statisticalCodeIds",
              "enabled": true,
              "path": "instance.statisticalCodeIds[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "instance.statisticalCodeIds[]",
                  "fields": [
                    {
                      "name": "statisticalCodeId",
                      "enabled": true,
                      "path": "instance.statisticalCodeIds[]",
                      "value": "\"ARL (Collection stats): books - Book, print (books)\"",
                      "acceptedValues": {
                        "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                        "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)"
                      }
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for CREATE Instance
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-937'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileInstanceId = $.id

    # Create mapping profile for Holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Holdings Mapping profile FAT-937",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "holdingsTypeId",
              "enabled": "true",
              "path": "holdings.holdingsTypeId",
              "value": "\"Electronic\"",
              "subfields": [],
              "acceptedValues": {
                "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic"
              }
            },
            {
              "name": "permanentLocationId",
              "enabled": "true",
              "path": "holdings.permanentLocationId",
              "value": "\"Online (E)\"",
              "subfields": [],
              "acceptedValues": {
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)"
              }
            },
            {
              "name": "callNumberTypeId",
              "enabled": "true",
              "path": "holdings.callNumberTypeId",
              "value": "\"Library of Congress classification\"",
              "subfields": [],
              "acceptedValues": {
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification"
              }
            },
            {
              "name": "callNumber",
              "enabled": "true",
              "path": "holdings.callNumber",
              "value": "050$a \" \" 050$b",
              "subfields": []
            },
            {
              "name": "electronicAccess",
              "enabled": "true",
              "path": "holdings.electronicAccess[]",
              "value": "",
              "repeatableFieldAction": "EXTEND_EXISTING",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.electronicAccess[]",
                  "fields": [
                    {
                      "name": "relationshipId",
                      "enabled": "true",
                      "path": "holdings.electronicAccess[].relationshipId",
                      "value": "\"Resource\"",
                      "subfields": [],
                      "acceptedValues": {
                        "3b430592-2e09-4b48-9a0c-0636d66b9fb3": "Version of resource",
                        "f5d0068e-6272-458e-8a81-b85e7b9a14aa": "Resource"
                      }
                    },
                    {
                      "name": "uri",
                      "enabled": "true",
                      "path": "holdings.electronicAccess[].uri",
                      "value": "856$u",
                      "subfields": []
                    },
                    {
                      "name": "linkText",
                      "enabled": "true",
                      "path": "holdings.electronicAccess[].linkText",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "materialsSpecification",
                      "enabled": "true",
                      "path": "holdings.electronicAccess[].materialsSpecification",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "publicNote",
                      "enabled": "true",
                      "path": "holdings.electronicAccess[].publicNote",
                      "value": "",
                      "subfields": []
                    }
                  ]
                }
              ]
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
    * def mappingProfileHoldingsId = $.id

    # Create action profile for CREATE Holdings
    * def mappingProfileEntityId = mappingProfileHoldingsId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-937'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileHoldingsId = $.id

    # Create mapping profile for Item
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Item Mapping profile FAT-937",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "ITEM",
        "description": "",
        "mappingDetails": {
          "name": "item",
          "recordType": "ITEM",
          "mappingFields": [
            {
              "name": "materialType.id",
              "enabled": true,
              "path": "item.materialType.id",
              "value": "\"electronic resource\"",
              "subfields": [],
              "acceptedValues": {
                "1a54b431-2e4f-452d-9cae-9cee66c9a892": "book",
                "615b8413-82d5-4203-aa6e-e37984cb5ac3": "electronic resource"
              }
            },
            {
              "name": "notes",
              "enabled": true,
              "path": "item.notes[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "item.notes[]",
                  "fields": [
                    {
                    "name": "itemNoteTypeId",
                      "enabled": true,
                      "path": "item.notes[].itemNoteTypeId",
                      "value": "\"Electronic bookplate\"",
                      "acceptedValues": {
                        "0e40884c-3523-4c6d-8187-d578e3d2794e": "Action note",
                        "f3ae3823-d096-4c65-8734-0c1efd2ffea8": "Electronic bookplate"
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "item.notes[].note",
                      "value": "\"Smith Family Foundation\""
                    },
                    {
                      "name": "staffOnly",
                      "enabled": true,
                      "path": "item.notes[].staffOnly",
                      "value": null,
                      "booleanFieldAction": "ALL_TRUE"
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "permanentLoanType.id",
              "enabled": true,
              "path": "item.permanentLoanType.id",
              "value": "\"Can circulate\"",
              "subfields": [],
              "acceptedValues": {
                "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
              }
            },
            {
              "name": "status.name",
              "enabled": true,
              "path": "item.status.name",
              "value": "\"Available\"",
              "subfields": []
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
    * def mappingProfileItemId = $.id

    # Create action profile for CREATE Item
    * def mappingProfileEntityId = mappingProfileItemId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-937'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileItemId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Job profile FAT-937",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileInstanceId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileHoldingsId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileItemId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 2
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def fileName = 'FAT-937.mrc'
    * def uiKey = fileName + randomNumber

    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-937.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def jobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = 'false'
    And headers headersUser
    And request
    """
    {
      "uploadDefinition": {
        "id": "#(uploadDefinitionId)",
        "metaJobExecutionId": "#(metaJobExecutionId)",
        "status": "LOADED",
        "createDate": "#(createDate)",
        "fileDefinitions": [
          {
            "id": "#(fileId)",
            "sourcePath": "#(sourcePath)",
            "name": "FAT-937.mrc",
            "status": "UPLOADED",
            "jobExecutionId": "#(jobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 2,
            "uiKey": "#(uiKey)",
          }
        ]
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "Job profile FAT-937",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].instanceActionStatus == 'CREATED'
    And assert response.entries[0].holdingsActionStatus == 'CREATED'
    And assert response.entries[0].itemActionStatus == 'CREATED'
    And match response.entries[0].error == '#notpresent'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify that real instance was created with specific fields in inventory and retrieve instance id
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And match response.instances[0].catalogedDate == '#present'
    And assert response.instances[0].statusId == '52a2ff34-2a12-420d-8539-21aa8d3cf5d8'
    And assert response.instances[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    * def instanceId = response.instances[0].id

    # Verify that real holding was created with specific fields in inventory and retrieve item id
    Given path 'holdings-storage/holdings'
    And headers headersUser
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '996f93e2-5b5e-4cf2-9168-33ced1f95eed'
    And assert response.holdingsRecords[0].permanentLocationId == '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
    And assert response.holdingsRecords[0].callNumberTypeId == '95467209-6d7b-468b-94df-0f5d7ad2747d'
    And assert response.holdingsRecords[0].callNumber == 'BT162.D57 P37 2021'
    And assert response.holdingsRecords[0].electronicAccess[0].relationshipId == 'f5d0068e-6272-458e-8a81-b85e7b9a14aa'
    And assert response.holdingsRecords[0].electronicAccess[0].uri == 'https://www.taylorfrancis.com/books/9781003105602'
    * def holdingsId = response.holdingsRecords[0].id
    * def holdingsSourceId = response.holdingsRecords[0].sourceId

    # Verify holdings source id that should be FOLIO
    Given path 'holdings-sources', holdingsSourceId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.name == 'FOLIO'

    # Verify that real item was created in inventory
    Given path 'inventory/items'
    And headers headersUser
    And param query = 'holdingsRecordId==' + holdingsId
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.items[0].notes[0].itemNoteTypeId == 'f3ae3823-d096-4c65-8734-0c1efd2ffea8'
    And assert response.items[0].notes[0].note == 'Smith Family Foundation'
    And assert response.items[0].notes[0].staffOnly == true
    And assert response.items[0].permanentLoanType.name == 'Can circulate'
    And assert response.items[0].permanentLoanType.id == '2b94c631-fca9-4892-a730-03ee529ffe27'
    And assert response.items[0].status.name == 'Available'
    And match response.items[0].status.date == '#present'

    # Delete job profile
    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    When method DELETE
    Then status 204

    # Delete action profiles
    Given path 'data-import-profiles/actionProfiles', actionProfileInstanceId
    And headers headersUser
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/actionProfiles', actionProfileHoldingsId
    And headers headersUser
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/actionProfiles', actionProfileItemId
    And headers headersUser
    When method DELETE
    Then status 204

    #Delete mapping profiles
    Given path 'data-import-profiles/mappingProfiles', mappingProfileInstanceId
    And headers headersUser
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/mappingProfiles', mappingProfileHoldingsId
    And headers headersUser
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/mappingProfiles', mappingProfileItemId
    And headers headersUser
    When method DELETE
    Then status 204

    * set entitiesIdMap.instanceId = instanceId