Feature: Data Import integration tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure retry = { interval: 15000, count: 5 }

    * def javaDemo = Java.type('test.java.WriteData')

    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

  Scenario: FAT-937 Upload MARC file and Create Instance, Holdings, Items.

    ## Create mapping profile for Instance
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

    ## Create action profile for Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Instance action profile FAT-937",
        "description": "",
        "action": "CREATE",
        "folioRecord": "INSTANCE"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(mappingProfileInstanceId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def actionProfileInstanceId = $.id

    ## Create mapping profile for Holdings
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

    ## Create action profile for Holdings
    Given path '/data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Holdings action profile FAT-937",
        "description": "",
        "action": "CREATE",
        "folioRecord": "HOLDINGS"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(mappingProfileHoldingsId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def actionProfileHoldingsId = $.id

    ## Create mapping profile for Item
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

    ## Create action profile for Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "Item action profile FAT-937",
        "description": "",
        "action": "CREATE",
        "folioRecord": "ITEM"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(mappingProfileItemId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def actionProfileItemId = $.id

    ##Create job profile
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
    * def uiKey = 'FAT-937.mrc' + randomNumber

    ## Create file definition for FAT-937.mrc-file
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "FAT-937.mrc"
        }
      ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def jobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/mrc-files/FAT-937.mrc')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = response.fileDefinitions[0].sourcePath

    ##Process file
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

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # verify that needed entities created
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

    # retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # verify that real instance was created with specific fields in inventory and retrieve instance id
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

    # verify that real holding was created with specific fields in inventory and retrieve item id
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

    # verify that real item was created in inventory
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

    ##Delete job profile
    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    When method DELETE
    Then status 204

    ##Delete action profile
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

    ##Delete mapping profile
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

  Scenario: FAT-939 Modify MARC_Bib, update Instances, Holdings, and Items 1

    * print 'Match MARC-to-MARC, modify MARC_Bib and update Instance, Holdings, and Items'

    ## Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: PTF - Modify MARC Bib",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "MARC_BIBLIOGRAPHIC",
        "description": "",
        "mappingDetails": {
          "name": "marcBib",
          "recordType": "MARC_BIBLIOGRAPHIC",
          "marcMappingDetails": [
            {
              "order": 0,
              "field": {
                "subfields": [
                  {
                    "subaction": "ADD_SUBFIELD",
                    "data": {
                      "text": "Test"
                    },
                    "subfield": "a"
                  },
                  {
                    "subfield": "b",
                    "data": {
                      "text": "Addition"
                    }
                  }
                ],
                "field": "947"
              },
              "action": "ADD"
            }
          ],
          "marcMappingOption": "MODIFY"
        }
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToMarcMappingProfileId = $.id

    ## Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: MARC-to-Instance",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "",
        "mappingDetails": {
          "name": "instance",
          "recordType": "INSTANCE",
          "mappingFields": [
            {
              "name": "previouslyHeld",
              "enabled": true,
              "path": "instance.previouslyHeld",
              "value": "",
              "subfields": [],
              "booleanFieldAction": "ALL_TRUE"
            },
            {
              "name": "statusId",
              "enabled": true,
              "path": "instance.statusId",
              "value": "\"Temporary\"",
              "subfields": [],
              "acceptedValues": {
                "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary"
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
                      "acceptedValues": {
                        "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)"
                      },
                      "value": "\"ARL (Collection stats): books - Book, print (books)\""
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

    * def marcToInstanceMappingProfileId = $.id

    ## Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: MARC-to-Holdings",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "formerIds",
              "enabled": true,
              "path": "holdings.formerIds[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.formerIds[]",
                  "fields": [
                    {
                      "name": "formerId",
                      "enabled": true,
                      "path": "holdings.formerIds[]",
                      "value": "901$a"
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "statisticalCodeIds",
              "enabled": true,
              "path": "holdings.statisticalCodeIds[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.statisticalCodeIds[]",
                  "fields": [
                    {
                      "name": "statisticalCodeId",
                      "enabled": true,
                      "path": "holdings.statisticalCodeIds[]",
                      "value": "\"ARL (Collection stats): books - Book, print (books)\"",
                      "acceptedValues": {
                        "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)"
                      }
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "temporaryLocationId",
              "enabled": true,
              "path": "holdings.temporaryLocationId",
              "value": "\"Annex (KU/CC/DI/A)\"",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)"
              }
            },
            {
              "name": "callNumberPrefix",
              "enabled": true,
              "path": "holdings.callNumberPrefix",
              "subfields": [],
              "value": "505"
            },
            {
              "name": "callNumberSuffix",
              "enabled": true,
              "path": "holdings.callNumberSuffix",
              "value": "657",
              "subfields": []
            },
            {
              "name": "illPolicyId",
              "enabled": true,
              "path": "holdings.illPolicyId",
              "value": "\"Limited lending policy\"",
              "subfields": [],
              "acceptedValues": {
                "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy"
              }
            },
            {
              "name": "notes",
              "enabled": true,
              "path": "holdings.notes[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.notes[]",
                  "fields": [
                    {
                      "name": "noteType",
                      "enabled": true,
                      "path": "holdings.notes[].holdingsNoteTypeId",
                      "value": "\"Action note\"",
                      "acceptedValues": {
                        "d6510242-5ec3-42ed-b593-3585d2e48fd6": "Action note"
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "holdings.notes[].note",
                      "value": "\"some notes\""
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

    * def marcToHoldingsMappingProfileId = $.id

    ## Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: PTF - Update item",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "ITEM",
        "description": "",
        "mappingDetails": {
          "name": "item",
          "recordType": "ITEM",
          "mappingFields": [
            {
              "name": "barcode",
              "enabled": true,
              "path": "item.barcode",
              "value": "\"123456\"",
              "subfields": []
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "item.copyNumber",
              "value": "\"12345\"",
              "subfields": []
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
                      "value": "\"Action note\"",
                      "acceptedValues": {
                        "0e40884c-3523-4c6d-8187-d578e3d2794e": "Action note",
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "item.notes[].note",
                      "value": "\"some notes\""
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
              "name": "temporaryLoanType.id",
              "enabled": true,
              "path": "item.temporaryLoanType.id",
              "value": "\"Can circulate\"",
              "subfields": [],
              "acceptedValues": {
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

    * def marcToItemMappingProfileId = $.id

    ## Create action profile for modify MARC bib
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: PTF - Modify MARC bib",
        "description": "",
        "action": "MODIFY",
        "folioRecord": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToMarcMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcBibActionProfileId = $.id

    ## Create action profile for update Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "PTF - Update Instance FAT-939",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "INSTANCE"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToInstanceMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def instanceActionProfileId = $.id

    ## Create action profile for update Holdings
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: PTF - Update Holdings",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "HOLDINGS"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToHoldingsMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def holdingsActionProfileId = $.id

    ## Create action profile for update Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: PTF - Update Item",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "ITEM"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToItemMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def itemActionProfileId = $.id

    ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: MARC-to-MARC 001 to 001",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToMarcMatchProfileId = $.id

    ## Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: MARC-to-Holdings 901a to Holdings HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "901"
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "HOLDINGS",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "holdingsrecord.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "HOLDINGS"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToHoldingsMatchProfileId = $.id

    ## Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: MARC-to-Item 902a to Item HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "902"
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "ITEM",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "item.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "ITEM"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToItemMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-939: Job profile",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToMarcMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(marcToMarcMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(marcBibActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": "#(marcToMarcMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(instanceActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 1,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToHoldingsMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(marcToHoldingsMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(holdingsActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToItemMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(marcToItemMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(itemActionProfileId)",
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

    ## Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
    """
    {
      "size": 2,
      "fileName": "FAT-939.csv",
      "uploadFormat": "csv",
    }
    """
    When method POST
    Then status 201
    And match $.status == 'NEW'

    * def fileDefinitionId = $.id

    ## Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-939.csv')
    When method POST
    Then status 200
    And match $.status == 'COMPLETED'

    * def exportJobExecutionId = $.jobExecutionId

    ## Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    ## Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And headers headersUser
    And request
    """
    {
      "fileDefinitionId": "#(fileDefinitionId)",
      "jobProfileId": "#(defaultJobProfileId)"
    }
    """
    When method POST
    Then status 204

    ## Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 1000

    ## Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200

    * def downloadLink = $.link

    * def fileName = 'FAT-939-1.mrc'

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random

    * def uiKey = fileName + randomNumber

    ## Create file definition for FAT-939-1.mrc-file
    Given url baseUrl
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "#(fileName)"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def importJobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('file:FAT-939-1.mrc')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = $.fileDefinitions[0].sourcePath

    ##Process file
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
            "name": "FAT-939-1.mrc",
            "status": "UPLOADED",
            "jobExecutionId": "#(importJobExecutionId)",
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
        "name": "FAT-939: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

  Scenario: FAT-940 Match MARC-to-MARC and update Instances, Holdings, and Items 2
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    ## Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: MARC-to-Instance",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "",
        "mappingDetails": {
          "name": "instance",
          "recordType": "INSTANCE",
          "mappingFields": [
            {
              "name": "statusId",
              "enabled": true,
              "path": "instance.statusId",
              "subfields": [],
              "acceptedValues": {
                "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary"
              },
              "value": "\"Temporary\""
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
                      "value": "\"ARL (Collection stats): rmusic - Music sound recordings\"",
                      "acceptedValues": {
                        "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings"
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

    * def marcToInstanceMappingProfileId = $.id

    ## Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: MARC-to-Holdings",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "formerIds",
              "enabled": true,
              "path": "holdings.formerIds[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.formerIds[]",
                  "fields": [
                    {
                      "name": "formerId",
                      "enabled": true,
                      "path": "holdings.formerIds[]",
                      "value": "\"Holdings ID 2\""
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "statisticalCodeIds",
              "enabled": true,
              "path": "holdings.statisticalCodeIds[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.statisticalCodeIds[]",
                  "fields": [
                    {
                      "name": "statisticalCodeId",
                      "enabled": true,
                      "path": "holdings.statisticalCodeIds[]",
                      "value": "\"RECM (Record management): UCPress - University of Chicago Press Imprint\"",
                      "acceptedValues": {
                        "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint"
                      }
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "permanentLocationId",
              "enabled": true,
              "path": "holdings.permanentLocationId",
              "value": "\"Popular Reading Collection (KU/CC/DI/P)\"",
              "subfields": [],
              "acceptedValues": {
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)"
              }
            },
            {
              "name": "temporaryLocationId",
              "enabled": true,
              "path": "holdings.temporaryLocationId",
              "value": "\"SECOND FLOOR (KU/CC/DI/2)\"",
              "subfields": [],
              "acceptedValues": {
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "shelvingTitle",
              "enabled": true,
              "path": "holdings.shelvingTitle",
              "value": "\"TEST2\"",
              "subfields": []
            },
            {
              "name": "callNumberPrefix",
              "enabled": true,
            "path": "holdings.callNumberPrefix",
            "value": "\"PREF2\"",
            "subfields": []
            },
            {
              "name": "callNumberSuffix",
              "enabled": true,
              "path": "holdings.callNumberSuffix",
              "value": "\"SUF2\"",
              "subfields": []
            },
            {
              "name": "digitizationPolicy",
              "enabled": true,
              "path": "holdings.digitizationPolicy",
              "subfields": [],
              "value": "\"REMOVE\""
            },
            {
              "name": "retentionPolicy",
              "enabled": true,
              "path": "holdings.retentionPolicy",
              "value": "\"300$a\"",
              "subfields": []
            },
            {
              "name": "notes",
              "enabled": true,
              "path": "holdings.notes[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.notes[]",
                  "fields": [
                    {
                      "name": "noteType",
                      "enabled": true,
                      "path": "holdings.notes[].holdingsNoteTypeId",
                      "value": "\"Note\"",
                      "acceptedValues": {
                        "b160f13a-ddba-4053-b9c4-60ec5ea45d56": "Note"
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "holdings.notes[].note",
                      "value": "\"Did this one get added also (Note 2)?\""
                    },
                    {
                      "name": "staffOnly",
                      "enabled": true,
                      "path": "holdings.notes[].staffOnly",
                      "value": null,
                      "booleanFieldAction": "ALL_TRUE"
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

    * def marcToHoldingsMappingProfileId = $.id

    ## Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: MARC-to-Item",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "ITEM",
        "description": "",
        "mappingDetails": {
          "name": "item",
          "recordType": "ITEM",
          "mappingFields": [
            {
              "name": "itemIdentifier",
              "enabled": true,
              "path": "item.itemIdentifier",
              "value": "\"902$a\"",
              "subfields": []
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "item.copyNumber",
              "value": "\"REMOVE\"",
              "subfields": []
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
                      "value": "\"Note\"",
                      "acceptedValues": {
                        "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note"
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "item.notes[].note",
                      "value": "\"And another one (note 2)\""
                    },
                    {
                      "name": "staffOnly",
                      "enabled": true,
                      "path": "item.notes[].staffOnly",
                      "booleanFieldAction": "ALL_TRUE"
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

    * def marcToItemMappingProfileId = $.id

    ## Create action profile for update Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: Update Instance",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "INSTANCE"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToInstanceMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def instanceActionProfileId = $.id

    ## Create action profile for update Holdings
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: Update Holdings",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "HOLDINGS"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToHoldingsMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def holdingsActionProfileId = $.id

    ## Create action profile for update Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: Update item",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "ITEM"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToItemMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def itemActionProfileId = $.id

    ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: MARC-to-MARC 001 to 001",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToMarcMatchProfileId = $.id

    ## Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: MARC-to-Holdings 901a to Holdings HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "901"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "HOLDINGS",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "holdingsrecord.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "HOLDINGS"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToHoldingsMatchProfileId = $.id

    ## Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: MARC-to-Item 902a to Item HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "902"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "ITEM",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "item.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "ITEM"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToItemMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-940: Job profile",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToMarcMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(marcToMarcMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(instanceActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToHoldingsMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(marcToHoldingsMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(holdingsActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToItemMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(marcToItemMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(itemActionProfileId)",
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

    ## Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
    """
    {
      "size": 2,
      "fileName": "FAT-940.csv",
      "uploadFormat": "csv"
    }
    """
    When method POST
    Then status 201
    And match $.status == 'NEW'

    * def fileDefinitionId = $.id

    ## Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-940.csv')
    When method POST
    Then status 200
    And match $.status == 'COMPLETED'

    * def exportJobExecutionId = $.jobExecutionId

    ## Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    ## Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    ##should export instances and return 204
    Given path 'data-export/export'
    And headers headersUser
    And request
    """
    {
      "fileDefinitionId": "#(fileDefinitionId)",
      "jobProfileId": "#(defaultJobProfileId)"
    }
    """
    When method POST
    Then status 204

    ## Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 1000

    ## Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200

    * def downloadLink = $.link

    * def fileName = 'FAT-940-1.mrc'

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random

    * def uiKey = fileName + randomNumber

    ## Create file definition for FAT-940-1.mrc-file
    Given url baseUrl
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "#(fileName)"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def importJobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('file:FAT-940-1.mrc')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = $.fileDefinitions[0].sourcePath

    ##Process file
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
            "name": "#(fileName)",
            "status": "UPLOADED",
            "jobExecutionId": "#(importJobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 2,
            "uiKey": "#(uiKey)"
          }
        ]
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "FAT-940: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

  Scenario: FAT-941 Match MARC-to-MARC and update Instances, Holdings, and Items 3
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    ## Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-941: MARC-to-Instance",
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "INSTANCE",
            "description": "",
            "mappingDetails": {
                "name": "instance",
                "recordType": "INSTANCE",
                "mappingFields": [
                    {
                        "name": "discoverySuppress",
                        "enabled": true,
                        "path": "instance.discoverySuppress",
                        "value": "",
                        "subfields": [],
                        "booleanFieldAction": "ALL_TRUE"
                    },
                    {
                        "name": "statusId",
                        "enabled": true,
                        "path": "instance.statusId",
                        "subfields": [],
                        "acceptedValues": {
                            "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary"
                        },
                        "value": "\"Temporary\""
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
                                            "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings"
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

    * def marcToInstanceMappingProfileId = $.id

    ## Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-941: MARC-to-Holdings",
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "HOLDINGS",
            "description": "",
            "mappingDetails": {
                "name": "holdings",
                "recordType": "HOLDINGS",
                "mappingFields": [
                    {
                        "name": "formerIds",
                        "enabled": true,
                        "path": "holdings.formerIds[]",
                        "value": "",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "holdings.formerIds[]",
                                "fields": [
                                    {
                                        "name": "formerId",
                                        "enabled": true,
                                        "path": "holdings.formerIds[]",
                                        "value": "\"Holdings ID 3\""
                                    }
                                ]
                            }
                        ],
                        "repeatableFieldAction": "EXTEND_EXISTING"
                    },
                    {
                        "name": "statisticalCodeIds",
                        "enabled": true,
                        "path": "holdings.statisticalCodeIds[]",
                        "value": "",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "holdings.statisticalCodeIds[]",
                                "fields": [
                                    {
                                        "name": "statisticalCodeId",
                                        "enabled": true,
                                        "path": "holdings.statisticalCodeIds[]",
                                        "value": "\"ARL (Collection stats): books - Book, print (books)\"",
                                        "acceptedValues": {
                                            "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)"
                                        }
                                    }
                                ]
                            }
                        ],
                        "repeatableFieldAction": "EXTEND_EXISTING"
                    },
                    {
                        "name": "temporaryLocationId",
                        "enabled": true,
                        "path": "holdings.temporaryLocationId",
                        "value": "\"Main Library (KU/CC/DI/M)\"",
                        "subfields": [],.
                        "acceptedValues": {
                            "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)"
                        }
                    },
                    {
                        "name": "shelvingTitle",
                        "enabled": true,
                        "path": "holdings.shelvingTitle",
                        "subfields": [],
                        "value": "\"TEST3\""
                    },
                    {
                        "name": "callNumberPrefix",
                        "enabled": true,
                        "path": "holdings.callNumberPrefix",
                        "value": "\"PREF3\"",
                        "subfields": []
                    },
                    {
                        "name": "callNumberSuffix",
                        "enabled": true,
                        "path": "holdings.callNumberSuffix",
                        "value": "\"SUF3\"",
                        "subfields": []
                    },
                    {
                        "name": "digitizationPolicy",
                        "enabled": true,
                        "path": "holdings.digitizationPolicy",
                        "value": "300$a",
                        "subfields": []
                    },
                    {
                        "name": "notes",
                        "enabled": true,
                        "path": "holdings.notes[]",
                        "value": "",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "holdings.notes[]",
                                "fields": [
                                    {
                                        "name": "noteType",
                                        "enabled": true,
                                        "path": "holdings.notes[].holdingsNoteTypeId",
                                        "value": "\"Note\"",
                                        "acceptedValues": {
                                            "b160f13a-ddba-4053-b9c4-60ec5ea45d56": "Note"
                                        }
                                    },
                                    {
                                        "name": "note",
                                        "enabled": true,
                                        "path": "holdings.notes[].note",
                                        "value": ""
                                    },
                                    {
                                        "name": "staffOnly",
                                        "enabled": true,
                                        "path": "holdings.notes[].staffOnly",
                                        "value": null,
                                        "booleanFieldAction": "ALL_TRUE"
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

    * def marcToHoldingsMappingProfileId = $.id

    ## Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-941: MARC-to-Item",
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "ITEM",
            "description": "",
            "mappingDetails": {
                "name": "item",
                "recordType": "ITEM",
                "mappingFields": [
                    {
                        "name": "accessionNumber",
                        "enabled": true,
                        "path": "item.accessionNumber",
                        "value": "\"902$a\"",
                        "subfields": []
                    },
                    {
                      "name": "itemIdentifier",
                      "enabled": "true",
                      "path": "item.itemIdentifier",
                      "value": "###REMOVE###",
                      "subfields": []
                    },
                    {
                        "name": "copyNumber",
                        "enabled": true,
                        "path": "item.copyNumber",
                        "subfields": [],
                        "value": "\"REMOVE\""
                    },
                    {
                        "name": "descriptionOfPieces",
                        "enabled": true,
                        "path": "item.descriptionOfPieces",
                        "value": "\"300$c\"",
                        "subfields": []
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
                                        "value": "\"Note\"",
                                        "acceptedValues": {
                                            "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note"
                                        }
                                    },
                                    {
                                        "name": "note",
                                        "enabled": true,
                                        "path": "item.notes[].note",
                                        "value": "\"3\""
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
                        "name": "permanentLocation.id",
                        "enabled": true,
                        "path": "item.permanentLocation.id",
                        "value": "\"Main Library (KU/CC/DI/M)\"",
                        "subfields": [],
                        "acceptedValues": {
                            "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)"
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

    * def marcToItemMappingProfileId = $.id

    ## Create action profile for update Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-941: Update Instance",
            "description": "",
            "action": "UPDATE",
            "folioRecord": "INSTANCE"
        },
        "addedRelations": [
            {
                "masterProfileId": null,
                "masterProfileType": "ACTION_PROFILE",
                "detailProfileId": "#(marcToInstanceMappingProfileId)",
                "detailProfileType": "MAPPING_PROFILE"
            }
        ],
        "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def instanceActionProfileId = $.id

    ## Create action profile for update Holdings
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-941: Update Holdings",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "HOLDINGS"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToHoldingsMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def holdingsActionProfileId = $.id

    ## Create action profile for update Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-941: Update item",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "ITEM"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToItemMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def itemActionProfileId = $.id

        ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-941: MARC-to-MARC 001 to 001",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToMarcMatchProfileId = $.id

    ## Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-941: MARC-to-Holdings 901a to Holdings HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "901"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "HOLDINGS",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "holdingsrecord.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "HOLDINGS"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToHoldingsMatchProfileId = $.id

    ## Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-941: MARC-to-Item 902a to Item HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "902"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "ITEM",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "item.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "ITEM"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToItemMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-941: Job profile",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToMarcMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(marcToMarcMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(instanceActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToHoldingsMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(marcToHoldingsMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(holdingsActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToItemMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(marcToItemMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(itemActionProfileId)",
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

    ## Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
    """
    {
      "size": 2,
      "fileName": "FAT-941.csv",
      "uploadFormat": "csv"
    }
    """
    When method POST
    Then status 201
    And match $.status == 'NEW'

    * def fileDefinitionId = $.id

    ## Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-941.csv')
    When method POST
    Then status 200
    And match $.status == 'COMPLETED'

    * def exportJobExecutionId = $.jobExecutionId

    ## Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    ## Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    ##should export instances and return 204
    Given path 'data-export/export'
    And headers headersUser
    And request
    """
    {
      "fileDefinitionId": "#(fileDefinitionId)",
      "jobProfileId": "#(defaultJobProfileId)"
    }
    """
    When method POST
    Then status 204

    ## Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 1000

    ## Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200

    * def downloadLink = $.link
    * def fileName = 'FAT-941-1.mrc'

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    ## Create file definition for FAT-941-1.mrc-file
    Given url baseUrl
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
      "fileDefinitions": [
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "#(fileName)"
        }
      ]
    }
    """
    When method POST
    Then status 201

    * def response = $
    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def importJobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('file:FAT-941-1.mrc')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = $.fileDefinitions[0].sourcePath

    ##Process file
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
            "name": "#(fileName)",
            "status": "UPLOADED",
            "jobExecutionId": "#(importJobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 2,
            "uiKey": "#(uiKey)"
          }
        ]
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "FAT-941: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

  Scenario: FAT-1117 Default mapping rules updating and verification via data-import
    * print 'FAT-1117 Default mapping rules updating and verification via data-import'

    * def randomNumber = callonce random
    * def uiKey = 'FAT-1117.mrc' + randomNumber

    ## Create file definition for FAT-1117.mrc-file
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "FAT-1117.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201

    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def jobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate


    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/mrc-files/FAT-1117.mrc')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'


    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = response.fileDefinitions[0].sourcePath

     ##Process file
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
            "name": "FAT-1117.mrc",
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
        "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
        "name": "Default - Create instance and SRS MARC Bib",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # verify that needed entities created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].instanceActionStatus == 'CREATED'
    And match response.entries[0].error == '#notpresent'

    * def sourceRecordId = response.entries[0].sourceRecordId

    # retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # verify that real instance was created with specific fields in inventory and retrieve instance id
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].identifiers[0].identifierTypeId == 'fcca2643-406a-482a-b760-7a7f8aec640e'
    And assert response.instances[0].identifiers[0].value == '9780784412763'
    And assert response.instances[0].identifiers[1].identifierTypeId == 'fcca2643-406a-482a-b760-7a7f8aec640e'
    And assert response.instances[0].identifiers[1].value == '0784412766'
    And assert response.instances[0].notes[0].instanceNoteTypeId == '86b6e817-e1bc-42fb-bab0-70e7547de6c1'
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].subjects contains  "Electronic books"
    And match response.instances[0].subjects !contains "United States"

    # Update marc-bib rules
    Given path 'mapping-rules/marc-bib'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-1117-changed-marc-bib-rules.json')
    When method PUT
    Then status 200
    * call pause 5000

    * def randomNumber = callonce random
    * def uiKey = 'FAT-1117.mrc' + randomNumber

    ## Create file definition for FAT-1117.mrc-file
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "FAT-1117.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201

    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def jobExecutionId = response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = response.metaJobExecutionId
    * def createDate = response.fileDefinitions[0].createDate
    * def uploadedDate = createDate


    ## Upload marc-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/mrc-files/FAT-1117.mrc')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'


    ## Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method GET
    Then status 200

    * def sourcePath = response.fileDefinitions[0].sourcePath

     ##Process file
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
            "name": "FAT-1117.mrc",
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
        "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
        "name": "Default - Create instance and SRS MARC Bib",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # verify that needed entities created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].instanceActionStatus == 'CREATED'
    And match response.entries[0].error == '#notpresent'

    * def sourceRecordId = response.entries[0].sourceRecordId

    # retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'

    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # verify that real instance was created with specific fields in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].identifiers[0].identifierTypeId == '4f07ea37-6c7f-4836-add2-14249e628ed1'
    And assert response.instances[0].identifiers[0].value == '9780784412763'
    And assert response.instances[0].identifiers[1].identifierTypeId == '4f07ea37-6c7f-4836-add2-14249e628ed1'
    And assert response.instances[0].identifiers[1].value == '0784412766'
    And assert response.instances[0].notes[0].instanceNoteTypeId == '6a2533a7-4de2-4e64-8466-074c2fa9308c'
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].subjects contains "Engineering collection. United States"
    And match response.instances[0].subjects  !contains "Electronic books"

    # Revert marc-bib rules to default
    Given path 'mapping-rules/marc-bib'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/default-marc-bib-rules.json')
    When method PUT
    Then status 200

  @Undefined
  Scenario: FAT-942 Match MARC-to-MARC and update Instances, Holdings, and Items 4
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    ## Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-942: MARC-to-Instance",
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "INSTANCE",
            "description": "",
            "mappingDetails": {
                "name": "instance",
                "recordType": "INSTANCE",
                "mappingFields": [
                    {
                        "name": "discoverySuppress",
                        "enabled": "true",
                        "path": "instance.discoverySuppress",
                        "value": "",
                        "booleanFieldAction": "ALL_FALSE",
                        "subfields": []
                    },
                    {
                        "name": "staffSuppress",
                        "enabled": "true",
                        "path": "instance.staffSuppress",
                        "value": "",
                        "booleanFieldAction": "AS_IS",
                        "subfields": []
                    },
                    {
                        "name": "previouslyHeld",
                        "enabled": "true",
                        "path": "instance.previouslyHeld",
                        "value": "",
                        "booleanFieldAction": "AS_IS",
                        "subfields": []
                    },
                    {
                        "name": "statusId",
                        "enabled": true,
                        "path": "instance.statusId",
                        "value": "\"Other\"",
                        "subfields": [],
                        "acceptedValues": {
                            "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other"
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
                                        "value": "\"RECM (Record management): UCPress - University of Chicago Press Imprint\"",
                                        "acceptedValues": {
                                            "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint"
                                        }
                                    }
                                ]
                            }
                        ],
                        "repeatableFieldAction": "EXCHANGE_EXISTING"
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

    * def marcToInstanceMappingProfileId = $.id

    ## Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-942: MARC-to-Holdings",
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "HOLDINGS",
            "description": "",
            "mappingDetails": {
                "name": "holdings",
                "recordType": "HOLDINGS",
                "mappingFields": [
                    {
                        "name": "discoverySuppress",
                        "enabled": "true",
                        "path": "holdings.discoverySuppress",
                        "value": "",
                        "booleanFieldAction": "AS_IS",
                        "subfields": []
                    },
                    {
                        "name": "formerIds",
                        "enabled": true,
                        "path": "holdings.formerIds[]",
                        "value": "",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "holdings.formerIds[]",
                                "fields": [
                                    {
                                        "name": "formerId",
                                        "enabled": true,
                                        "path": "holdings.formerIds[]",
                                        "value": "\"Holdings ID 4\""
                                    }
                                ]
                            }
                        ],
                        "repeatableFieldAction": "EXCHANGE_EXISTING"
                    },
                    {
                        "name": "statisticalCodeIds",
                        "enabled": true,
                        "path": "holdings.statisticalCodeIds[]",
                        "value": "",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "holdings.statisticalCodeIds[]",
                                "fields": [
                                    {
                                        "name": "statisticalCodeId",
                                        "enabled": true,
                                        "path": "holdings.statisticalCodeIds[]",
                                        "value": "\"ARL (Collection stats): ebooks - Books, electronic (ebooks)\"",
                                        "acceptedValues": {
                                            "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)"
                                        }
                                    }
                                ]
                            }
                        ],
                        "repeatableFieldAction": "EXCHANGE_EXISTING"
                    },
                    {
                        "name": "permanentLocationId",
                        "enabled": true,
                        "path": "holdings.permanentLocationId",
                        "value": "\"Main Library (KU/CC/DI/M)\"",
                        "subfields": [],
                        "acceptedValues": {
                            "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)"
                        }
                    },
                    {
                        "name": "temporaryLocationId",
                        "enabled": true,
                        "path": "holdings.temporaryLocationId",
                        "value": "###REMOVE###",
                        "subfields": []
                    },
                    {
                        "name": "shelvingTitle",
                        "enabled": true,
                        "path": "holdings.shelvingTitle",
                        "subfields": [],
                        "value": "\"TEST4\""
                    },
                    {
                        "name": "copyNumber",
                        "enabled": true,
                        "path": "holdings.copyNumber",
                        "value": "300$a",
                        "subfields": []
                    },
                    {
                        "name": "callNumberPrefix",
                        "enabled": true,
                       "path": "holdings.callNumberPrefix",
                        "value": "\"PREF4\"",
                        "subfields": []
                    },
                    {
                        "name": "callNumberSuffix",
                        "enabled": true,
                        "path": "holdings.callNumberSuffix",
                        "value": "\"SUF4\"",
                        "subfields": []
                    },
                    {
                        "name": "numberOfItems",
                        "enabled": true,
                        "path": "holdings.numberOfItems",
                        "value": "300$a",
                        "subfields": []
                    },
                    {
                        "name": "digitizationPolicy",
                        "enabled": true,
                        "path": "holdings.digitizationPolicy",
                        "value": "###REMOVE###",
                        "subfields": []
                    },
                    {
                        "name": "notes",
                        "enabled": true,
                        "path": "holdings.notes[]",
                        "value": "",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "holdings.notes[]",
                                "fields": [
                                    {
                                        "name": "noteType",
                                        "enabled": true,
                                        "path": "holdings.notes[].holdingsNoteTypeId",
                                        "acceptedValues": {
                                            "b160f13a-ddba-4053-b9c4-60ec5ea45d56": "Note"
                                        },
                                        "value": "\"Note\""
                                    },
                                    {
                                        "name": "note",
                                        "enabled": true,
                                        "path": "holdings.notes[].note",
                                        "value": "\"Looks like this record needs another note (Note 4)\""
                                    },
                                    {
                                        "name": "staffOnly",
                                        "enabled": true,
                                        "path": "holdings.notes[].staffOnly",
                                        "value": null,
                                        "booleanFieldAction": "ALL_TRUE"
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

    * def marcToHoldingsMappingProfileId = $.id

    ## Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
        "profile": {
            "name": "FAT-942: MARC-to-Item",
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingRecordType": "ITEM",
            "description": "",
            "mappingDetails": {
                "name": "item",
                "recordType": "ITEM",
                "mappingFields": [
                    {
                        "name": "accessionNumber",
                        "enabled": true,
                        "path": "item.accessionNumber",
                        "subfields": [],
                        "value": "###REMOVE###"
                    },
                    {
                        "name": "copyNumber",
                        "enabled": true,
                        "path": "item.copyNumber",
                        "value": "902$a",
                        "subfields": []
                    },
                    {
                        "name": "numberOfPieces",
                        "enabled": true,
                        "path": "item.numberOfPieces",
                        "value": "300$c",
                        "subfields": []
                    },
                    {
                        "name": "descriptionOfPieces",
                        "enabled": true,
                        "path": "item.descriptionOfPieces",
                        "value": "###REMOVE###",
                        "subfields": []
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
                                        "value": "\"Note\"",
                                        "acceptedValues": {
                                            "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note"
                                        }
                                    },
                                    {
                                        "name": "note",
                                        "enabled": true,
                                        "path": "item.notes[].note",
                                        "value": "\"4\""
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
                        "name": "temporaryLoanType.id",
                        "enabled": true,
                        "path": "item.temporaryLoanType.id",
                        "value": "\"Reading room\"",
                        "subfields": [],
                        "acceptedValues": {
                            "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room"
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

    * def marcToItemMappingProfileId = $.id

        ## Create action profile for update Instance
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: Update Instance",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "INSTANCE"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToInstanceMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def instanceActionProfileId = $.id

    ## Create action profile for update Holdings
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: Update Holdings",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "HOLDINGS"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToHoldingsMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def holdingsActionProfileId = $.id

    ## Create action profile for update Item
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: Update item",
        "description": "",
        "action": "UPDATE",
        "folioRecord": "ITEM"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "ACTION_PROFILE",
          "detailProfileId": "#(marcToItemMappingProfileId)",
          "detailProfileType": "MAPPING_PROFILE"
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def itemActionProfileId = $.id

    ## Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: MARC-to-MARC 001 to 001",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "MARC_BIBLIOGRAPHIC",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "001"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": ""
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "MARC_BIBLIOGRAPHIC"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToMarcMatchProfileId = $.id

    ## Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: MARC-to-Holdings 901a to Holdings HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "901"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "HOLDINGS",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "holdingsrecord.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "HOLDINGS"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToHoldingsMatchProfileId = $.id

    ## Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: MARC-to-Item 902a to Item HRID",
        "description": "",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "902"
                },
                {
                  "label": "indicator1",
                  "value": ""
                },
                {
                  "label": "indicator2",
                  "value": ""
                },
                {
                  "label": "recordSubfield",
                  "value": "a"
                }
              ],
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "ITEM",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "item.hrid"
                }
              ],
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "matchCriterion": "EXACTLY_MATCHES"
          }
        ],
        "existingRecordType": "ITEM"
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def marcToItemMatchProfileId = $.id

    ## Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-942: Job profile",
        "description": "",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToMarcMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(marcToMarcMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(instanceActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToHoldingsMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(marcToHoldingsMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(holdingsActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(marcToItemMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(marcToItemMatchProfileId)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(itemActionProfileId)",
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

  @Undefined
  Scenario: FAT-943 Match MARC-to-MARC and update Instances, Holdings, and Items 5
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

  @Undefined
  Scenario: FAT-944 Match MARC-to-MARC and update Instances, fail to update Holdings and Items
    * print 'Match MARC-to-MARC and update Instance, fail to update Holdings and Items'

  @Undefined
  Scenario: FAT-945 Match MARC-to-MARC and update Instances, Holdings, fail to update Items
    * print 'Match MARC-to-MARC and update Instance, Holdings, fail to update Items'

