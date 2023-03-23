Feature: Data Import integration tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure retry = { interval: 15000, count: 10 }

    * def javaDemo = Java.type('test.java.WriteData')

    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def samplePath = 'classpath:folijet/data-import/samples/'
    * def updateHoldings = 'data-import-integration.feature@UpdateHoldings'

  Scenario: FAT-4701 check that default rules in karate tests matches what is in the SRM under test
    * def javaJsonUtils = Java.type('test.java.JsonUtils')
    Given path 'mapping-rules/marc-bib'
    And headers headersAdmin
    And def expectedJson = JSON.stringify(read('classpath:folijet/data-import/samples/samples_for_upload/default-marc-bib-rules.json'))
    When method GET
    Then status 200
    And def responseJson = JSON.stringify(response)
    And def isEqual = javaJsonUtils.compareJson(responseJson, expectedJson)
    And assert isEqual == true

  Scenario: FAT-937 Upload MARC file and Create Instance, Holdings, Items.
    * print 'Upload MARC file and Create Instance, Holdings, Items.'
    * call read('classpath:folijet/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem') {testIdentifier: "FAT-937"}

  Scenario: FAT-939 Modify MARC_Bib, update Instances, Holdings, and Items 1
    * print 'Match MARC-to-MARC, modify MARC_Bib and update Instance, Holdings, and Items'

    # Create MARC-to-MARC mapping profile
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

    # Create MARC-to-Instance mapping profile
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

    # Create MARC-to-Holdings mapping profile
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

    # Create MARC-to-Item mapping profile
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

    # Create action profile for MODIFY MARC bib
    * def mappingProfileEntityId = marcToMarcMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'MODIFY'
    * def folioRecord = 'MARC_BIBLIOGRAPHIC'
    * def userStoryNumber = 'FAT-939'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def marcBibActionProfileId = $.id

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-939'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create action profile for UPDATE Holdings
    * def mappingProfileEntityId = marcToHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-939'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create action profile for UPDATE Item
    * def mappingProfileEntityId = marcToItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-939: PTF'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def itemActionProfileId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
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

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
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

    # Create match profile for MARC-to-Item 902a to Item HRID
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

    # Create job profile
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

    # Create file definition id for data-export
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

    # Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-939.csv')
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    # Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    # Should export instances and return 204
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

    # Return job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-939-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-939-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'file:FAT-939-1.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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

    # Verify job execution for data-import
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

    # Create MARC-to-Instance mapping profile
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

    # Create MARC-to-Holdings mapping profile
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

    # Create MARC-to-Item mapping profile
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-940'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create action profile for UPDATE Holdings
    * def mappingProfileEntityId = marcToHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-940'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create action profile for UPDATE Item
    * def mappingProfileEntityId = marcToItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-940'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def itemActionProfileId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
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

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
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

    # Create match profile for MARC-to-Item 902a to Item HRID
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

    # Create job profile
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

    # Create file definition id for data-export
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

    # Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-940.csv')
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    # Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
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

    # Return job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-940-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-940-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'file:FAT-940-1.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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

    # Verify job execution for data-import
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

    # Create MARC-to-Instance mapping profile
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

    # Create MARC-to-Holdings mapping profile
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
                        "subfields": [],
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

    # Create MARC-to-Item mapping profile
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
                      "value": "##REMOVE##",
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-941'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create action profile for UPDATE Holdings
    * def mappingProfileEntityId = marcToHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-941'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create action profile for UPDATE Item
    * def mappingProfileEntityId = marcToItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-941'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def itemActionProfileId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
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

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
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

    # Create match profile for MARC-to-Item 902a to Item HRID
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

    # Create job profile
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

    # Create file definition id for data-export
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

    # Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-941.csv')
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    # Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    # Should export instances and return 204
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

    # Return job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-941-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-941-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'file:FAT-941-1.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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

    # Verify job execution for data-import
    # TODO: Fix file import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

  Scenario: FAT-942 Match MARC-to-MARC and update Instances, Holdings, and Items 4
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    # Create MARC-to-Instance mapping profile
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

    # Create MARC-to-Holdings mapping profile
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
                        "value": "##REMOVE##",
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
                        "value": "##REMOVE##",
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

    # Create MARC-to-Item mapping profile
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
                        "value": "##REMOVE##"
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
                        "value": "##REMOVE##",
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-942'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create action profile for UPDATE Holdings
    * def mappingProfileEntityId = marcToHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-942'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create action profile for UPDATE Item
    * def mappingProfileEntityId = marcToItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-942'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def itemActionProfileId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
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

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
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

    # Create match profile for MARC-to-Item 902a to Item HRID
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

    # Create job profile
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

     # Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
    """
    {
      "size": 2,
      "fileName": "FAT-942.csv",
      "uploadFormat": "csv"
    }
    """
    When method POST
    Then status 201
    And match $.status == 'NEW'
    * def fileDefinitionId = $.id

    # Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-942.csv')
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    # Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
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

    # Return job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-942-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-942-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'file:FAT-942-1.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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
        "name": "FAT-942: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
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

    * def fileName = 'FAT-1117.mrc'
    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-1117.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-1117.mrc'}

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
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].identifiers[*].value contains '9780784412763'
    And match response.instances[0].identifiers[*].value contains '0784412766'
    And match response.instances[0].subjects[*].value contains  "Electronic books"
    And match response.instances[0].subjects[*].value !contains "United States"

    # Update marc-bib rules
    Given path 'mapping-rules/marc-bib'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/FAT-1117-changed-marc-bib-rules.json')
    When method PUT
    Then status 200
    * call pause 5000

    * def randomNumber = callonce random
    * def fileName = 'FAT-1117.mrc'
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-1117.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-1117.mrc'}

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
    And match response.entries[0].error == '#notpresent'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify that real instance was created with specific fields in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].identifiers[*].value contains '9780784412763'
    And match response.instances[0].identifiers[*].value contains '0784412766'
    And match response.instances[0].subjects[*].value contains  "Engineering collection. United States"
    And match response.instances[0].subjects[*].value !contains "Electronic books"

    # Revert marc-bib rules to default
    Given path 'mapping-rules/marc-bib'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/default-marc-bib-rules.json')
    When method PUT
    Then status 200

  Scenario: FAT-943 Match MARC-to-MARC and update Instances, Holdings, and Items 5
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

    # Create mapping profile for Instance
    # MARC-to-Instance (Checks Suppress from discovery, changes the statistical code (PTF5), changes status to Uncataloged)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943_New: MARC-to-Instance",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "FAT-943_New: MARC-to-Instance",
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
              "name": "staffSuppress",
              "enabled": true,
              "path": "instance.staffSuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "previouslyHeld",
              "enabled": true,
              "path": "instance.previouslyHeld",
              "value": "",
              "subfields": []
            },
            {
              "name": "hrid",
              "enabled": false,
              "path": "instance.hrid",
              "value": "",
              "subfields": []
            },
            {
              "name": "source",
              "enabled": false,
              "path": "instance.source",
              "value": "",
              "subfields": []
            },
            {
              "name": "catalogedDate",
              "enabled": true,
              "path": "instance.catalogedDate",
              "value": "",
              "subfields": []
            },
            {
              "name": "statusId",
              "enabled": true,
              "path": "instance.statusId",
              "value": "\"Uncataloged\"",
              "subfields": [],
              "acceptedValues": {
                "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged",
                "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41": "Not yet assigned",
                "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other",
                "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary",
                "26f5208e-110a-4394-be29-1569a8c84a65": "Uncataloged"
              }
            },
            {
              "name": "modeOfIssuanceId",
              "enabled": false,
              "path": "instance.modeOfIssuanceId",
              "value": "",
              "subfields": []
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
                      "value": "\"PTF: PTF5 - PTF5\"",
                      "acceptedValues": {
                          "750b65f5-8b09-4d0c-aded-2d4e2cbea1b7" : "Serial status: ESER - Electronic serial",
                          "2cbcc291-5ae1-4536-bc54-0753eb194475" : "University of Chicago: visual - Visual materials, DVDs, etc. (visual)",
                          "2d74ed6f-c53c-4814-9f5a-0fb721bc3051" : "University of Chicago: eintegrating - E-integrating resource",
                          "51ef6f2b-3ebe-4e9b-bafa-b9c8329fe278" : "University of Chicago: compfiles - Computer files, CDs, etc. (compfiles)",
                          "d92986e1-8b01-442b-8b3b-e2da97194262" : "PTF: PTF9 - PTF9",
                          "eae77f10-1479-4e56-b0ac-a12bab8ea5b8" : "Serial status: ASER - Active serial",
                          "077e7e6a-7ccf-409e-9f13-30dc53d7ed5f" : "University of Chicago: arch - Archives (arch)",
                          "4a5da458-f384-4b36-97f3-4391a9c41e77" : "PTF: PTF8 - PTF8",
                          "a1e80f65-c2dc-4b7a-b8be-3cf977b99cd9" : "PTF: PTF1 - PTF1",
                          "e73a45b4-95c3-46cd-80bc-9b3aff18a56c" : "University of Chicago: withdrawn - Withdrawn (withdrawn)",
                          "ee64441e-e2c9-4f85-83d3-a85b5eed3fbc" : "University of Chicago: vidstream - Streaming video (vidstream)",
                          "54c8bcc7-2d0c-4357-a853-519d87ed214c" : "PTF: PTF3 - PTF3",
                          "58ca58aa-a2f6-4329-a14d-fbaa57f90cc1" : "University of Chicago: ebooks - Books, electronic (ebooks)",
                          "f1ff94be-12a3-41f8-9b92-a46ce282ce73" : "University of Chicago: eserials - Serials, electronic (eserials)",
                          "b8c1b891-0358-4a38-a9d4-f40f9a547cdf" : "University of Chicago: serials - Serials, print (serials)",
                          "3475a71b-7ae3-41f6-b86a-2a424830549c" : "University of Chicago: rmusic - Music sound recordings (rmusic)",
                          "0868921a-4407-47c9-9b3e-db94644dbae7" : "SERM (Serial management): ENF - Entry not found",
                          "8d1f5e72-e0a4-42b1-9de9-2d9452ecc46d" : "PTF: PTF5 - PTF5",
                          "f4c4f756-c668-4d1c-a571-7dd8e5120918" : "University of Chicago: music - Music scores, print (music)",
                          "bbdc114a-54b3-471c-b38e-506dd124f529" : "University of Chicago: maps - Maps, print (maps)",
                          "9611e336-ab79-4d96-ad50-f3cf444df7df" : "University of Chicago: its - Information Technology Services (its)",
                          "173288b9-72cb-450d-9b96-dfde2a7c9022" : "University of Chicago: polsky - Polsky TECHB@R(polsky)",
                          "3212e362-e7a4-4610-80c9-2349a06a1050" : "University of Chicago: rnonmusic - Non-music sound recordings (rnonmusic)",
                          "da161967-cab7-4b0f-bbbe-bba79ce9dca2" : "PTF: PTF7 - PTF7",
                          "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf" : "RECM (Record management): UCPress - University of Chicago Press Imprint",
                          "3edb3980-b037-484c-ba0d-cb76432bac7d" : "University of Chicago: mfilm - Microfilm (mfilm)",
                          "b9e012f8-2055-49c3-98e1-5a5b7241de50" : "University of Chicago: mss - Manuscripts (mss)",
                          "37cdf9fe-e5af-4c06-a2a6-3089157e8efc" : "University of Chicago: mfiche - Microfiche (mfiche)",
                          "85258fc4-a5ac-430f-a071-bb33df32ed89" : "University of Chicago: emaps - Maps, electronic (emaps)",
                          "c6de6928-bb6e-4458-97f4-9145b27abb24" : "University of Chicago: books - Books, print (books)",
                          "870a11ee-3f16-4467-9ba1-0870078ecb41" : "University of Chicago: emusic - Music scores, electronic (emusic)",
                          "05dfeb83-c186-433e-aa98-a8372b73c5b8" : "Serial status: ISER - Inactive serial",
                          "0bad9883-c0c0-464c-81b1-0aec6279260e" : "PTF: PTF2 - PTF2",
                          "236d828c-78d9-4fd9-b6c1-e2cc3e270c8b" : "University of Chicago: audstream - Streaming audio (audstream)",
                          "24eeacc2-c2e7-4452-911b-0f373588f713" : "PTF: PTF6 - PTF6",
                          "79e15d8b-cdc7-451c-95c0-f0e12a80840b" : "University of Chicago: evisual - visual, static, electronic",
                          "264c4f94-1538-43a3-8b40-bed68384b31b" : "RECM (Record management): XOCLC - Do not share with OCLC",
                          "916a41c9-5513-42e8-b384-31ea512cfb35" : "PTF: PTF4 - PTF4",
                          "e31a8694-e188-44f0-ab6d-5ad612c9a800" : "University of Chicago: mmedia - Mixed media (mmedia)"
                        }
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "title",
              "enabled": false,
              "path": "instance.title",
              "value": "",
              "subfields": []
            },
            {
              "name": "alternativeTitles",
              "enabled": false,
              "path": "instance.alternativeTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "indexTitle",
              "enabled": false,
              "path": "instance.indexTitle",
              "value": "",
              "subfields": []
            },
            {
              "name": "series",
              "enabled": false,
              "path": "instance.series[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "precedingTitles",
              "enabled": false,
              "path": "instance.precedingTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "succeedingTitles",
              "enabled": false,
              "path": "instance.succeedingTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "identifiers",
              "enabled": false,
              "path": "instance.identifiers[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "contributors",
              "enabled": false,
              "path": "instance.contributors[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publication",
              "enabled": false,
              "path": "instance.publication[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "editions",
              "enabled": false,
              "path": "instance.editions[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "physicalDescriptions",
              "enabled": false,
              "path": "instance.physicalDescriptions[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "instanceTypeId",
              "enabled": false,
              "path": "instance.instanceTypeId",
              "value": "",
              "subfields": []
            },
            {
              "name": "natureOfContentTermIds",
              "enabled": true,
              "path": "instance.natureOfContentTermIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "instanceFormatIds",
              "enabled": false,
              "path": "instance.instanceFormatIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "languages",
              "enabled": false,
              "path": "instance.languages[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publicationFrequency",
              "enabled": false,
              "path": "instance.publicationFrequency[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publicationRange",
              "enabled": false,
              "path": "instance.publicationRange[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "notes",
              "enabled": false,
              "path": "instance.notes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "electronicAccess",
              "enabled": false,
              "path": "instance.electronicAccess[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "subjects",
              "enabled": false,
              "path": "instance.subjects[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "classifications",
              "enabled": false,
              "path": "instance.classifications[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "parentInstances",
              "enabled": true,
              "path": "instance.parentInstances[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "childInstances",
              "enabled": true,
              "path": "instance.childInstances[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Instance
    * def folioRecord = 'INSTANCE'
    * def folioRecordNameAndDescription = 'FAT-943_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileInstanceId = $.id

    # MARC-to-Holdings (Only mapped field is Holdings statement staff note, from 300$a. Deletes former holdings ID and replaces it with Holdings ID 5. Same for stat codes - delete and replace with PTF5. Adds a new temp location. Add 5 to Shelving title, Prefix, and Suffix. Adds a holding statement with a public and staff note. Adds another Holdings note)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943_New - MARC-to-Holdings",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "FAT-943_New - MARC-to-Holdings",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "holdings.discoverySuppress",
              "value": "",
              "subfields": [],
              "booleanFieldAction": "ALL_TRUE"
            },
            {
              "name": "hrid",
              "enabled": false,
              "path": "holdings.discoverySuppress",
              "value": "",
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
                      "value": "\"5\""
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "holdingsTypeId",
              "enabled": true,
              "path": "holdings.holdingsTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
              }
            },
            {
              "name": "statisticalCodeIds",
              "enabled": true,
              "path": "holdings.statisticalCodeIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "permanentLocationId",
              "enabled": true,
              "path": "holdings.permanentLocationId",
              "value": "\"Annex (KU/CC/DI/A)\"",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "temporaryLocationId",
              "enabled": true,
              "path": "holdings.temporaryLocationId",
              "value": "\"Online (E)\"",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "shelvingOrder",
              "enabled": true,
              "path": "holdings.shelvingOrder",
              "value": "",
              "subfields": []
            },
            {
              "name": "shelvingTitle",
              "enabled": true,
              "path": "holdings.shelvingTitle",
              "value": "\"5\"",
              "subfields": []
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "holdings.copyNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "callNumberTypeId",
              "enabled": true,
              "path": "holdings.callNumberTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "03dd64d0-5626-4ecd-8ece-4531e0069f35": "Dewey Decimal classification",
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification",
                "828ae637-dfa3-4265-a1af-5279c436edff": "MOYS",
                "054d460d-d6b9-4469-9e37-7a78a2266655": "National Library of Medicine classification",
                "6caca63e-5651-4db6-9247-3205156e9699": "Other scheme",
                "cd70562c-dd0b-42f6-aa80-ce803d24d4a1": "Shelved separately",
                "28927d76-e097-4f63-8510-e56f2b7a3ad0": "Shelving control number",
                "827a2b64-cbf5-4296-8545-130876e4dfc0": "Source specified in subfield $2",
                "fc388041-6cd0-4806-8a74-ebe3b9ab4c6e": "Superintendent of Documents classification",
                "5ba6b62e-6858-490a-8102-5b1369873835": "Title",
                "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f": "UDC"
              }
            },
            {
              "name": "callNumberPrefix",
              "enabled": true,
              "path": "holdings.callNumberPrefix",
              "value": "\"PRE5\"",
              "subfields": []
            },
            {
              "name": "callNumber",
              "enabled": true,
              "path": "holdings.callNumber",
              "value": "\"Number2\"",
              "subfields": []
            },
            {
              "name": "callNumberSuffix",
              "enabled": true,
              "path": "holdings.callNumberSuffix",
              "value": "\"SUF5\"",
              "subfields": []
            },
            {
              "name": "numberOfItems",
              "enabled": true,
              "path": "holdings.numberOfItems",
              "subfields": []
            },
            {
              "name": "holdingsStatements",
              "enabled": true,
              "path": "holdings.holdingsStatements[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "holdings.holdingsStatements[]",
                  "fields": [
                    {
                      "name": "statement",
                      "enabled": true,
                      "path": "holdings.holdingsStatements[].statement",
                      "value": "\"holding statement\""
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "holdings.holdingsStatements[].note",
                      "value": "\"public note\""
                    },
                    {
                      "name": "staffNote",
                      "enabled": true,
                      "path": "holdings.holdingsStatements[].staffNote",
                      "value": "\"staff note\""
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "holdingsStatementsForSupplements",
              "enabled": true,
              "path": "holdings.holdingsStatementsForSupplements[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatementsForIndexes",
              "enabled": true,
              "path": "holdings.holdingsStatementsForIndexes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "illPolicyId",
              "enabled": true,
              "path": "holdings.illPolicyId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy",
                "37fc2702-7ec9-482a-a4e3-5ed9a122ece1": "Unknown lending policy",
                "c51f7aa9-9997-45e6-94d6-b502445aae9d": "Unknown reproduction policy",
                "46970b40-918e-47a4-a45d-b1677a2d3d46": "Will lend",
                "2b870182-a23d-48e8-917d-9421e5c3ce13": "Will lend hard copy only",
                "b0f97013-87f5-4bab-87f2-ac4a5191b489": "Will not lend",
                "6bc6a71f-d6e2-4693-87f1-f495afddff00": "Will not reproduce",
                "2a572e7b-dfe5-4dee-8a62-b98d26a802e6": "Will reproduce"
              }
            },
            {
              "name": "digitizationPolicy",
              "enabled": true,
              "path": "holdings.digitizationPolicy",
              "value": "",
              "subfields": []
            },
            {
              "name": "retentionPolicy",
              "enabled": true,
              "path": "holdings.retentionPolicy",
              "value": "",
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
                        "d6510242-5ec3-42ed-b593-3585d2e48fd6": "Action note",
                        "e19eabab-a85c-4aef-a7b2-33bd9acef24e": "Binding",
                        "c4407cc7-d79f-4609-95bd-1cefb2e2b5c5": "Copy note",
                        "88914775-f677-4759-b57b-1a33b90b24e0": "Electronic bookplate",
                        "b160f13a-ddba-4053-b9c4-60ec5ea45d56": "Note",
                        "db9b4787-95f0-4e78-becf-26748ce6bdeb": "Provenance",
                        "6a41b714-8574-4084-8d64-a9373c3fbb59": "Reproduction"
                      },
                      "value": "\"Note\""
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "holdings.notes[].note",
                      "value": "\"Another Holding\""
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
            },
            {
              "name": "electronicAccess",
              "enabled": true,
              "path": "holdings.electronicAccess[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "receivingHistory.entries",
              "enabled": true,
              "path": "holdings.receivingHistory.entries[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Holdings
    * def folioRecord = 'HOLDINGS'
    * def folioRecordNameAndDescription = 'FAT-943_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileHoldingId = $.id

    # MARC-to-Item (Removes the Item HRID as the copy number and adds it as the item identifier (902$a); Adds volume number from 300$c and removes it from number of pieces. Adds an item note (5). Removes temp loan type. Changes status to missing)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943_New: MARC-to-Item",
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
              "value": "##REMOVE##"
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
              "value": "##REMOVE##",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Item
    * def folioRecord = 'ITEM'
    * def folioRecordNameAndDescription = 'FAT-943_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileItemsId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943 MARC-to-MARC 001 to 001",
        "description": "FAT-943 MARC-to-MARC 001 to 001",
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
              "dataValueType": "VALUE_FROM_RECORD",
              "qualifier": {
                "qualifierType": null,
                "qualifierValue": null
              }
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
    * def matchProfileIdMarcToMarc = $.id

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943 MARC-to-Holdings 901a to Holdings HRID",
        "description": "FAT-943 MARC-to-Holdings 901a to Holdings HRID",
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
                  "label": "indicator1"
                },
                {
                  "label": "indicator2"
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
    * def matchProfileIdMarcToHoldings = $.id

    # Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943 MARC-to-Item 902a to Item HRID",
        "description": "FAT-943 MARC-to-Item 902a to Item HRID",
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
    * def matchProfileIdMarcToItem = $.id

    # Create job profile - Implement 'Match MARC-to-MARC and update Instances, Holdings, and Items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-943_Implement Match MARC-to-MARC and update Instances, Holdings, and Items",
        "description": "FAT-943_Implement Match MARC-to-MARC and update Instances, Holdings, and Items 5 scenario_INTEGRATION",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToMarc)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToMarc)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileInstanceId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToHoldings)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToHoldings)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileHoldingId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToItem)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToItem)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileItemsId)",
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

     # Create file definition id for data-export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
    """
    {
      "size": 2,
      "fileName": "FAT-943.csv",
      "uploadFormat": "csv"
    }
    """
    When method POST
    Then status 201
    And match $.status == 'NEW'
    * def fileDefinitionId = $.id

    # Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-943.csv')
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    # Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    # should export instances and return 204
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

    # Return job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-943-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-943-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-937.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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
        "name": "FAT-943: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

  Scenario: FAT-944 Match MARC-to-MARC and update Instances, fail to update Holdings and Items
    * print 'Match MARC-to-MARC and update Instance, fail to update Holdings and Items'

    # Import Instance, Holding, Item
    * print 'Preparation: import Instance, Holding, Item'
    * def inventoryIdsMap = call read('classpath:folijet/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem') {testIdentifier: "FAT-944"}

    # Create mapping profile for Instance
    # MARC-to-Instance (Marks the Previously held checkbox, changes the statistical code (PTF1), changes status to temporary)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944_New: MARC-to-Instance",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "FAT-944_New: MARC-to-Instance",
        "mappingDetails": {
          "name": "instance",
          "recordType": "INSTANCE",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "instance.discoverySuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "staffSuppress",
              "enabled": true,
              "path": "instance.staffSuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "previouslyHeld",
              "enabled": true,
              "path": "instance.previouslyHeld",
              "value": "",
              "subfields": [],
              "booleanFieldAction": "ALL_TRUE"
            },
            {
              "name": "hrid",
              "enabled": false,
              "path": "instance.hrid",
              "value": "",
              "subfields": []
            },
            {
              "name": "source",
              "enabled": false,
              "path": "instance.source",
              "value": "",
              "subfields": []
            },
            {
              "name": "catalogedDate",
              "enabled": true,
              "path": "instance.catalogedDate",
              "value": "",
              "subfields": []
            },
            {
              "name": "statusId",
              "enabled": true,
              "path": "instance.statusId",
              "value": "\"Temporary\"",
              "subfields": [],
              "acceptedValues": {
                "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged",
                "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41": "Not yet assigned",
                "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other",
                "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary",
                "26f5208e-110a-4394-be29-1569a8c84a65": "Uncataloged"
              }
            },
            {
              "name": "modeOfIssuanceId",
              "enabled": false,
              "path": "instance.modeOfIssuanceId",
              "value": "",
              "subfields": []
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
                      "value": "\"RECM (Record management): XOCLC - Do not share with OCLC\"",
                      "acceptedValues": {
                        "750b65f5-8b09-4d0c-aded-2d4e2cbea1b7": "Serial status: ESER - Electronic serial",
                        "2cbcc291-5ae1-4536-bc54-0753eb194475": "University of Chicago: visual - Visual materials, DVDs, etc. (visual)",
                        "2d74ed6f-c53c-4814-9f5a-0fb721bc3051": "University of Chicago: eintegrating - E-integrating resource",
                        "51ef6f2b-3ebe-4e9b-bafa-b9c8329fe278": "University of Chicago: compfiles - Computer files, CDs, etc. (compfiles)",
                        "d92986e1-8b01-442b-8b3b-e2da97194262": "PTF: PTF9 - PTF9",
                        "eae77f10-1479-4e56-b0ac-a12bab8ea5b8": "Serial status: ASER - Active serial",
                        "077e7e6a-7ccf-409e-9f13-30dc53d7ed5f": "University of Chicago: arch - Archives (arch)",
                        "4a5da458-f384-4b36-97f3-4391a9c41e77": "PTF: PTF8 - PTF8",
                        "a1e80f65-c2dc-4b7a-b8be-3cf977b99cd9": "PTF: PTF1 - PTF1",
                        "e73a45b4-95c3-46cd-80bc-9b3aff18a56c": "University of Chicago: withdrawn - Withdrawn (withdrawn)",
                        "ee64441e-e2c9-4f85-83d3-a85b5eed3fbc": "University of Chicago: vidstream - Streaming video (vidstream)",
                        "54c8bcc7-2d0c-4357-a853-519d87ed214c": "PTF: PTF3 - PTF3",
                        "58ca58aa-a2f6-4329-a14d-fbaa57f90cc1": "University of Chicago: ebooks - Books, electronic (ebooks)",
                        "f1ff94be-12a3-41f8-9b92-a46ce282ce73": "University of Chicago: eserials - Serials, electronic (eserials)",
                        "b8c1b891-0358-4a38-a9d4-f40f9a547cdf": "University of Chicago: serials - Serials, print (serials)",
                        "3475a71b-7ae3-41f6-b86a-2a424830549c": "University of Chicago: rmusic - Music sound recordings (rmusic)",
                        "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                        "8d1f5e72-e0a4-42b1-9de9-2d9452ecc46d": "PTF: PTF5 - PTF5",
                        "f4c4f756-c668-4d1c-a571-7dd8e5120918": "University of Chicago: music - Music scores, print (music)",
                        "bbdc114a-54b3-471c-b38e-506dd124f529": "University of Chicago: maps - Maps, print (maps)",
                        "9611e336-ab79-4d96-ad50-f3cf444df7df": "University of Chicago: its - Information Technology Services (its)",
                        "173288b9-72cb-450d-9b96-dfde2a7c9022": "University of Chicago: polsky - Polsky TECHB@R(polsky)",
                        "3212e362-e7a4-4610-80c9-2349a06a1050": "University of Chicago: rnonmusic - Non-music sound recordings (rnonmusic)",
                        "da161967-cab7-4b0f-bbbe-bba79ce9dca2": "PTF: PTF7 - PTF7",
                        "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                        "3edb3980-b037-484c-ba0d-cb76432bac7d": "University of Chicago: mfilm - Microfilm (mfilm)",
                        "b9e012f8-2055-49c3-98e1-5a5b7241de50": "University of Chicago: mss - Manuscripts (mss)",
                        "37cdf9fe-e5af-4c06-a2a6-3089157e8efc": "University of Chicago: mfiche - Microfiche (mfiche)",
                        "85258fc4-a5ac-430f-a071-bb33df32ed89": "University of Chicago: emaps - Maps, electronic (emaps)",
                        "c6de6928-bb6e-4458-97f4-9145b27abb24": "University of Chicago: books - Books, print (books)",
                        "870a11ee-3f16-4467-9ba1-0870078ecb41": "University of Chicago: emusic - Music scores, electronic (emusic)",
                        "05dfeb83-c186-433e-aa98-a8372b73c5b8": "Serial status: ISER - Inactive serial",
                        "0bad9883-c0c0-464c-81b1-0aec6279260e": "PTF: PTF2 - PTF2",
                        "236d828c-78d9-4fd9-b6c1-e2cc3e270c8b": "University of Chicago: audstream - Streaming audio (audstream)",
                        "24eeacc2-c2e7-4452-911b-0f373588f713": "PTF: PTF6 - PTF6",
                        "79e15d8b-cdc7-451c-95c0-f0e12a80840b": "University of Chicago: evisual - visual, static, electronic",
                        "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                        "916a41c9-5513-42e8-b384-31ea512cfb35": "PTF: PTF4 - PTF4",
                        "e31a8694-e188-44f0-ab6d-5ad612c9a800": "University of Chicago: mmedia - Mixed media (mmedia)"
                      }
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "title",
              "enabled": false,
              "path": "instance.title",
              "value": "",
              "subfields": []
            },
            {
              "name": "alternativeTitles",
              "enabled": false,
              "path": "instance.alternativeTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "indexTitle",
              "enabled": false,
              "path": "instance.indexTitle",
              "value": "",
              "subfields": []
            },
            {
              "name": "series",
              "enabled": false,
              "path": "instance.series[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "precedingTitles",
              "enabled": false,
              "path": "instance.precedingTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "succeedingTitles",
              "enabled": false,
              "path": "instance.succeedingTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "identifiers",
              "enabled": false,
              "path": "instance.identifiers[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "contributors",
              "enabled": false,
              "path": "instance.contributors[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publication",
              "enabled": false,
              "path": "instance.publication[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "editions",
              "enabled": false,
              "path": "instance.editions[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "physicalDescriptions",
              "enabled": false,
              "path": "instance.physicalDescriptions[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "instanceTypeId",
              "enabled": false,
              "path": "instance.instanceTypeId",
              "value": "",
              "subfields": []
            },
            {
              "name": "natureOfContentTermIds",
              "enabled": true,
              "path": "instance.natureOfContentTermIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "instanceFormatIds",
              "enabled": false,
              "path": "instance.instanceFormatIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "languages",
              "enabled": false,
              "path": "instance.languages[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publicationFrequency",
              "enabled": false,
              "path": "instance.publicationFrequency[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publicationRange",
              "enabled": false,
              "path": "instance.publicationRange[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "notes",
              "enabled": false,
              "path": "instance.notes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "electronicAccess",
              "enabled": false,
              "path": "instance.electronicAccess[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "subjects",
              "enabled": false,
              "path": "instance.subjects[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "classifications",
              "enabled": false,
              "path": "instance.classifications[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "parentInstances",
              "enabled": true,
              "path": "instance.parentInstances[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "childInstances",
              "enabled": true,
              "path": "instance.childInstances[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Instance
    * def folioRecord = 'INSTANCE'
    * def folioRecordNameAndDescription = 'FAT-944_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileInstanceId = $.id

    # MARC-to-Holdings (Adds the Holdings HRID as the former Holdings ID from 901$a; digitization policy from 300$a; adds a default stat code, Temp location, call number prefix, call number suffix, ILL policy, note)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944_New - MARC-to-Holdings",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "FAT-944_New - MARC-to-Holdings",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "holdings.discoverySuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "hrid",
              "enabled": false,
              "path": "holdings.discoverySuppress",
              "value": "",
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
                      "value": "\"901$a\""
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "holdingsTypeId",
              "enabled": true,
              "path": "holdings.holdingsTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
              }
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
                        "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                        "bb76b1c1-c9df-445c-8deb-68bb3580edc2": "ARL (Collection stats): compfiles - Computer files, CDs, etc (compfiles)",
                        "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)",
                        "ecab577d-a050-4ea2-8a86-ea5a234283ea": "ARL (Collection stats): emusic - Music scores, electronic",
                        "97e91f57-fad7-41ea-a660-4031bf8d4ea8": "ARL (Collection stats): maps - Maps, print (maps)",
                        "16f2d65e-eb68-4ab1-93e3-03af50cb7370": "ARL (Collection stats): mfiche - Microfiche (mfiche)",
                        "1c622d0f-2e91-4c30-ba43-2750f9735f51": "ARL (Collection stats): mfilm - Microfilm (mfilm)",
                        "2850630b-cd12-4379-af57-5c51491a6873": "ARL (Collection stats): mmedia - Mixed media (mmedia)",
                        "30b5400d-0b9e-4757-a3d0-db0d30a49e72": "ARL (Collection stats): music - Music scores, print (music)",
                        "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings",
                        "91b8f0b4-0e13-4270-9fd6-e39203d0f449": "ARL (Collection stats): rnonmusic - Non-music sound recordings (rnonmusic)",
                        "775b6ad4-9c35-4d29-bf78-8775a9b42226": "ARL (Collection stats): serials - Serials, print (serials)",
                        "972f81d5-9f8f-4b56-a10e-5c05419718e6": "ARL (Collection stats): visual - Visual materials, DVDs, etc. (visual)",
                        "e10796e0-a594-47b7-b748-3a81b69b3d9b": "DISC (Discovery): audstream - Streaming audio (audstream)",
                        "b76a3088-8de6-46c8-a130-c8e74b8d2c5b": "DISC (Discovery): emaps - Maps, electronic (emaps)",
                        "a5ccf92e-7b1f-4990-ac03-780a6a767f37": "DISC (Discovery): eserials - Serials, electronic (eserials)",
                        "b2c0e100-0485-43f2-b161-3c60aac9f68a": "DISC (Discovery): evisual - Visual, static, electronic",
                        "6d584d0e-3dbc-46c4-a1bd-e9238dd9a6be": "DISC (Discovery): vidstream - Streaming video (vidstream)",
                        "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                        "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                        "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)",
                        "38249f9e-13f8-48bc-a010-8023cd194af5": "RECM (Record management): its - Information Technology Services (its)",
                        "d82c025e-436d-4006-a677-bd2b4cdb7692": "RECM (Record management): mss - Manuscripts (mss)",
                        "950d3370-9a3c-421e-b116-76e7511af9e9": "RECM (Record management): polsky - Polsky TECHB@R (polsky)",
                        "c4073462-6144-4b69-a543-dd131e241799": "RECM (Record management): withdrawn - Withdrawn (withdrawn)",
                        "c7a32c50-ea7c-43b7-87ab-d134c8371330": "SERM (Serial management): ASER - Active serial",
                        "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                        "0e516e54-bf36-4fc2-a0f7-3fe89a61c9c0": "SERM (Serial management): ISER - Inactive serial"
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
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "temporaryLocationId",
              "enabled": true,
              "path": "holdings.temporaryLocationId",
              "value": "\"Annex (KU/CC/DI/A)\"",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "shelvingOrder",
              "enabled": true,
              "path": "holdings.shelvingOrder",
              "value": "",
              "subfields": []
            },
            {
              "name": "shelvingTitle",
              "enabled": true,
              "path": "holdings.shelvingTitle",
              "value": "",
              "subfields": []
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "holdings.copyNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "callNumberTypeId",
              "enabled": true,
              "path": "holdings.callNumberTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "03dd64d0-5626-4ecd-8ece-4531e0069f35": "Dewey Decimal classification",
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification",
                "828ae637-dfa3-4265-a1af-5279c436edff": "MOYS",
                "054d460d-d6b9-4469-9e37-7a78a2266655": "National Library of Medicine classification",
                "6caca63e-5651-4db6-9247-3205156e9699": "Other scheme",
                "cd70562c-dd0b-42f6-aa80-ce803d24d4a1": "Shelved separately",
                "28927d76-e097-4f63-8510-e56f2b7a3ad0": "Shelving control number",
                "827a2b64-cbf5-4296-8545-130876e4dfc0": "Source specified in subfield $2",
                "fc388041-6cd0-4806-8a74-ebe3b9ab4c6e": "Superintendent of Documents classification",
                "5ba6b62e-6858-490a-8102-5b1369873835": "Title",
                "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f": "UDC"
              }
            },
            {
              "name": "callNumberPrefix",
              "enabled": true,
              "path": "holdings.callNumberPrefix",
              "value": "\"Pref1\"",
              "subfields": []
            },
            {
              "name": "callNumber",
              "enabled": true,
              "path": "holdings.callNumber",
              "value": "\"CallN1\"",
              "subfields": []
            },
            {
              "name": "callNumberSuffix",
              "enabled": true,
              "path": "holdings.callNumberSuffix",
              "value": "\"Suf1\"",
              "subfields": []
            },
            {
              "name": "numberOfItems",
              "enabled": true,
              "path": "holdings.numberOfItems",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatements",
              "enabled": true,
              "path": "holdings.holdingsStatements[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatementsForSupplements",
              "enabled": true,
              "path": "holdings.holdingsStatementsForSupplements[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatementsForIndexes",
              "enabled": true,
              "path": "holdings.holdingsStatementsForIndexes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "illPolicyId",
              "enabled": true,
              "path": "holdings.illPolicyId",
              "value": "\"Limited lending policy\"",
              "subfields": [],
              "acceptedValues": {
                "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy",
                "37fc2702-7ec9-482a-a4e3-5ed9a122ece1": "Unknown lending policy",
                "c51f7aa9-9997-45e6-94d6-b502445aae9d": "Unknown reproduction policy",
                "46970b40-918e-47a4-a45d-b1677a2d3d46": "Will lend",
                "2b870182-a23d-48e8-917d-9421e5c3ce13": "Will lend hard copy only",
                "b0f97013-87f5-4bab-87f2-ac4a5191b489": "Will not lend",
                "6bc6a71f-d6e2-4693-87f1-f495afddff00": "Will not reproduce",
                "2a572e7b-dfe5-4dee-8a62-b98d26a802e6": "Will reproduce"
              }
            },
            {
              "name": "digitizationPolicy",
              "enabled": true,
              "path": "holdings.digitizationPolicy",
              "subfields": [],
              "value": "\"300$a\""
            },
            {
              "name": "retentionPolicy",
              "enabled": true,
              "path": "holdings.retentionPolicy",
              "value": "",
              "subfields": []
            },
            {
              "name": "notes",
              "enabled": true,
              "path": "holdings.notes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "electronicAccess",
              "enabled": true,
              "path": "holdings.electronicAccess[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "receivingHistory.entries",
              "enabled": true,
              "path": "holdings.receivingHistory.entries[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Holdings
    * def folioRecord = 'HOLDINGS'
    * def folioRecordNameAndDescription = 'FAT-944_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileHoldingId = $.id

    # MARC-to-Item (Adds Item HRID as the barcode number (902$a); Adds copy number from 300$c. Adds an item note (1). Adds temporary loan type)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944_New: MARC-to-Item",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "ITEM",
        "description": "FAT-944_New: MARC-to-Item",
        "mappingDetails": {
          "name": "item",
          "recordType": "ITEM",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "item.discoverySuppress",
              "value": null,
              "subfields": []
            },
            {
              "name": "hrid",
              "enabled": true,
              "path": "item.hrid",
              "value": "",
              "subfields": []
            },
            {
              "name": "barcode",
              "enabled": true,
              "path": "item.barcode",
              "value": "\"902$a\"",
              "subfields": []
            },
            {
              "name": "accessionNumber",
              "enabled": true,
              "path": "item.accessionNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemIdentifier",
              "enabled": true,
              "path": "item.itemIdentifier",
              "value": "",
              "subfields": []
            },
            {
              "name": "formerIds",
              "enabled": true,
              "path": "item.formerIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "statisticalCodeIds",
              "enabled": true,
              "path": "item.statisticalCodeIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "materialType.id",
              "enabled": true,
              "path": "item.materialType.id",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "1a54b431-2e4f-452d-9cae-9cee66c9a892": "book",
                "5ee11d91-f7e8-481d-b079-65d708582ccc": "dvd",
                "615b8413-82d5-4203-aa6e-e37984cb5ac3": "electronic resource",
                "b9300fdb-a5c5-4dca-864e-3b8844438a0e": "kAoHIgTN",
                "fd6c6515-d470-4561-9c32-3e3290d4ca98": "microform",
                "dd0bf600-dbd9-44ab-9ff2-e2a61a6539f1": "sound recording",
                "d9acad2f-2aac-4b48-9097-e6ab85906b25": "text",
                "71fbd940-1027-40a6-8a48-49b44d795e46": "unspecified",
                "30b3e36a-d3b2-415e-98c2-47fbdf878862": "video recording",
                "c7859a0f-1cbc-4f5e-8484-51fb1647c754": "wtmtrBKi"
              }
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "item.copyNumber",
              "subfields": [],
              "value": "\"300$c\""
            },
            {
              "name": "itemLevelCallNumberTypeId",
              "enabled": true,
              "path": "item.itemLevelCallNumberTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "03dd64d0-5626-4ecd-8ece-4531e0069f35": "Dewey Decimal classification",
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification",
                "828ae637-dfa3-4265-a1af-5279c436edff": "MOYS",
                "054d460d-d6b9-4469-9e37-7a78a2266655": "National Library of Medicine classification",
                "6caca63e-5651-4db6-9247-3205156e9699": "Other scheme",
                "cd70562c-dd0b-42f6-aa80-ce803d24d4a1": "Shelved separately",
                "28927d76-e097-4f63-8510-e56f2b7a3ad0": "Shelving control number",
                "827a2b64-cbf5-4296-8545-130876e4dfc0": "Source specified in subfield $2",
                "fc388041-6cd0-4806-8a74-ebe3b9ab4c6e": "Superintendent of Documents classification",
                "5ba6b62e-6858-490a-8102-5b1369873835": "Title",
                "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f": "UDC"
              }
            },
            {
              "name": "itemLevelCallNumberPrefix",
              "enabled": true,
              "path": "item.itemLevelCallNumberPrefix",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemLevelCallNumber",
              "enabled": true,
              "path": "item.itemLevelCallNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemLevelCallNumberSuffix",
              "enabled": true,
              "path": "item.itemLevelCallNumberSuffix",
              "value": "",
              "subfields": []
            },
            {
              "name": "numberOfPieces",
              "enabled": true,
              "path": "item.numberOfPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "descriptionOfPieces",
              "enabled": true,
              "path": "item.descriptionOfPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "enumeration",
              "enabled": true,
              "path": "item.enumeration",
              "value": "",
              "subfields": []
            },
            {
              "name": "chronology",
              "enabled": true,
              "path": "item.chronology",
              "value": "",
              "subfields": []
            },
            {
              "name": "volume",
              "enabled": true,
              "path": "item.volume",
              "value": "",
              "subfields": []
            },
            {
              "name": "yearCaption",
              "enabled": true,
              "path": "item.yearCaption[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "numberOfMissingPieces",
              "enabled": true,
              "path": "item.numberOfMissingPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "missingPieces",
              "enabled": true,
              "path": "item.missingPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "missingPiecesDate",
              "enabled": true,
              "path": "item.missingPiecesDate",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemDamagedStatusId",
              "enabled": true,
              "path": "item.itemDamagedStatusId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "54d1dd76-ea33-4bcb-955b-6b29df4f7930": "Damaged",
                "516b82eb-1f19-4a63-8c48-8f1a3e9ff311": "Not Damaged"
              }
            },
            {
              "name": "itemDamagedStatusDate",
              "enabled": true,
              "path": "item.itemDamagedStatusDate",
              "value": "",
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
                        "0e40884c-3523-4c6d-8187-d578e3d2794e": "Action note",
                        "87c450be-2033-41fb-80ba-dd2409883681": "Binding",
                        "1dde7141-ec8a-4dae-9825-49ce14c728e7": "Copy note",
                        "f3ae3823-d096-4c65-8734-0c1efd2ffea8": "Electronic bookplate",
                        "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note",
                        "c3a539b9-9576-4e3a-b6de-d910200b2919": "Provenance",
                        "acb3a58f-1d72-461d-97c3-0e7119e8d544": "Reproduction"
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "item.notes[].note",
                      "value": "\"1\""
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
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
                "51b3d2bd-2097-4c6e-bd5d-782b9224b64a": "permanent loan type name AVwRUhvu",
                "eea094e7-d647-492d-b387-40226488d6f0": "permanent loan type name DUqkqXZG",
                "7809f955-718c-4714-9f1a-998570661c15": "permanent loan type name FvEHkEDZ",
                "eb3add38-1340-4e2c-9a20-0f8f8c0adc73": "permanent loan type name fzpvblUy",
                "be8a4c39-166b-4e6c-aefa-da0182cc2502": "permanent loan type name gCnvZDgL",
                "8863c827-19b8-437f-b71b-998f5f55afb8": "permanent loan type name iPAMWpwh",
                "8dd64315-0f37-43bd-8614-b1fc689c31f4": "permanent loan type name VfyTCCct",
                "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
              }
            },
            {
              "name": "temporaryLoanType.id",
              "enabled": true,
              "path": "item.temporaryLoanType.id",
              "value": "\"Can circulate\"",
              "subfields": [],
              "acceptedValues": {
                "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
                "51b3d2bd-2097-4c6e-bd5d-782b9224b64a": "permanent loan type name AVwRUhvu",
                "eea094e7-d647-492d-b387-40226488d6f0": "permanent loan type name DUqkqXZG",
                "7809f955-718c-4714-9f1a-998570661c15": "permanent loan type name FvEHkEDZ",
                "eb3add38-1340-4e2c-9a20-0f8f8c0adc73": "permanent loan type name fzpvblUy",
                "be8a4c39-166b-4e6c-aefa-da0182cc2502": "permanent loan type name gCnvZDgL",
                "8863c827-19b8-437f-b71b-998f5f55afb8": "permanent loan type name iPAMWpwh",
                "8dd64315-0f37-43bd-8614-b1fc689c31f4": "permanent loan type name VfyTCCct",
                "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
              }
            },
            {
              "name": "status.name",
              "enabled": true,
              "path": "item.status.name",
              "value": "",
              "subfields": []
            },
            {
              "name": "circulationNotes",
              "enabled": true,
              "path": "item.circulationNotes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "permanentLocation.id",
              "enabled": true,
              "path": "item.permanentLocation.id",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "temporaryLocation.id",
              "enabled": true,
              "path": "item.temporaryLocation.id",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "electronicAccess",
              "enabled": true,
              "path": "item.electronicAccess[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Item
    * def folioRecord = 'ITEM'
    * def folioRecordNameAndDescription = 'FAT-944_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileItemsId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944 MARC-to-MARC 001 to 001",
        "description": "FAT-944 MARC-to-MARC 001 to 001",
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
              "dataValueType": "VALUE_FROM_RECORD",
              "qualifier": {
                "qualifierType": null,
                "qualifierValue": null
              }
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
    * def matchProfileIdMarcToMarc = $.id

    # Create match profile for MARC-to-Holdings 902a to Holdings HRID (wrong match)
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944 MARC-to-Holdings 901a to Holdings HRID",
        "description": "FAT-944 MARC-to-Holdings 901a to Holdings HRID",
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
                  "label": "indicator1"
                },
                {
                  "label": "indicator2"
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
    * def matchProfileIdMarcToHoldings = $.id

    # Create match profile for MARC-to-Item 901a to Item HRID (wrong match)
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944 MARC-to-Item 902a to Item HRID",
        "description": "FAT-944 MARC-to-Item 902a to Item HRID",
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
    * def matchProfileIdMarcToItem = $.id

    # Create job profile - Implement 'Match MARC-to-MARC and update Instances, Holdings, and Items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-944_Implement Match MARC-to-MARC and update Instances, Holdings, and Items",
        "description": "FAT-944_Implement Match MARC-to-MARC and update Instances, Holdings, and Items 5 scenario_INTEGRATION",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToMarc)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToMarc)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileInstanceId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToHoldings)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToHoldings)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileHoldingId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToItem)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToItem)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileItemsId)",
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

    # Export MARC record by instance id
    * print 'Export MARC record by instance id'
    Given path 'data-export/quick-export'
    And headers headersUser
    And request
    """
    {
      "jobProfileId": "#(defaultJobProfileId)",
      "uuids": [#(inventoryIdsMap.instanceId)],
      "type": "uuid",
      "recordType": "INSTANCE",
      "fileName": "FAT-944-1.mrc",
    }
    """
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Return export job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-944-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, 'target/' + fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'file:target/' + fileName

    * print '944 Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey: '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#(filePath)'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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
        "name": "FAT-944: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities updated
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', importJobExecutionId
    And headers headersUser
    And retry until response.entries[0].instanceActionStatus != null && response.entries[0].holdingsActionStatus != null && response.entries[0].itemActionStatus != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'UPDATED'
    And assert response.entries[0].instanceActionStatus == 'UPDATED'
    And assert response.entries[0].holdingsActionStatus == 'DISCARDED'
    And assert response.entries[0].itemActionStatus == 'DISCARDED'
    And match response.entries[0].error == '#notpresent'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify updated instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And match response.instances[0].statusId == 'daf2681c-25af-4202-a3fa-e58fdf806183'
    And match response.instances[0].statisticalCodeIds[*] contains '264c4f94-1538-43a3-8b40-bed68384b31b'
    And match response.instances[0].previouslyHeld == true

  Scenario: FAT-945 Match MARC-to-MARC and update Instances, Holdings, fail to update Items
    * print 'Match MARC-to-MARC and update Instance, Holdings, fail to update Items'

    # Import Instance, Holding, Item
    * print 'Preparation: import Instance, Holding, Item'
    * def inventoryIdsMap = call read('classpath:folijet/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem') {testIdentifier: "FAT-945"}

    # Create mapping profile for Instance
    # MARC-to-Instance (Marks the Previously held checkbox, changes the statistical code (PTF1), changes status to temporary)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945_New: MARC-to-Instance",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "FAT-945_New: MARC-to-Instance",
        "mappingDetails": {
          "name": "instance",
          "recordType": "INSTANCE",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "instance.discoverySuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "staffSuppress",
              "enabled": true,
              "path": "instance.staffSuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "previouslyHeld",
              "enabled": true,
              "path": "instance.previouslyHeld",
              "value": "",
              "subfields": [],
              "booleanFieldAction": "ALL_TRUE"
            },
            {
              "name": "hrid",
              "enabled": false,
              "path": "instance.hrid",
              "value": "",
              "subfields": []
            },
            {
              "name": "source",
              "enabled": false,
              "path": "instance.source",
              "value": "",
              "subfields": []
            },
            {
              "name": "catalogedDate",
              "enabled": true,
              "path": "instance.catalogedDate",
              "value": "",
              "subfields": []
            },
            {
              "name": "statusId",
              "enabled": true,
              "path": "instance.statusId",
              "value": "\"Temporary\"",
              "subfields": [],
              "acceptedValues": {
                "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged",
                "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41": "Not yet assigned",
                "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other",
                "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary",
                "26f5208e-110a-4394-be29-1569a8c84a65": "Uncataloged"
              }
            },
            {
              "name": "modeOfIssuanceId",
              "enabled": false,
              "path": "instance.modeOfIssuanceId",
              "value": "",
              "subfields": []
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
                      "value": "\"RECM (Record management): XOCLC - Do not share with OCLC\"",
                      "acceptedValues": {
                        "750b65f5-8b09-4d0c-aded-2d4e2cbea1b7": "Serial status: ESER - Electronic serial",
                        "2cbcc291-5ae1-4536-bc54-0753eb194475": "University of Chicago: visual - Visual materials, DVDs, etc. (visual)",
                        "2d74ed6f-c53c-4814-9f5a-0fb721bc3051": "University of Chicago: eintegrating - E-integrating resource",
                        "51ef6f2b-3ebe-4e9b-bafa-b9c8329fe278": "University of Chicago: compfiles - Computer files, CDs, etc. (compfiles)",
                        "d92986e1-8b01-442b-8b3b-e2da97194262": "PTF: PTF9 - PTF9",
                        "eae77f10-1479-4e56-b0ac-a12bab8ea5b8": "Serial status: ASER - Active serial",
                        "077e7e6a-7ccf-409e-9f13-30dc53d7ed5f": "University of Chicago: arch - Archives (arch)",
                        "4a5da458-f384-4b36-97f3-4391a9c41e77": "PTF: PTF8 - PTF8",
                        "a1e80f65-c2dc-4b7a-b8be-3cf977b99cd9": "PTF: PTF1 - PTF1",
                        "e73a45b4-95c3-46cd-80bc-9b3aff18a56c": "University of Chicago: withdrawn - Withdrawn (withdrawn)",
                        "ee64441e-e2c9-4f85-83d3-a85b5eed3fbc": "University of Chicago: vidstream - Streaming video (vidstream)",
                        "54c8bcc7-2d0c-4357-a853-519d87ed214c": "PTF: PTF3 - PTF3",
                        "58ca58aa-a2f6-4329-a14d-fbaa57f90cc1": "University of Chicago: ebooks - Books, electronic (ebooks)",
                        "f1ff94be-12a3-41f8-9b92-a46ce282ce73": "University of Chicago: eserials - Serials, electronic (eserials)",
                        "b8c1b891-0358-4a38-a9d4-f40f9a547cdf": "University of Chicago: serials - Serials, print (serials)",
                        "3475a71b-7ae3-41f6-b86a-2a424830549c": "University of Chicago: rmusic - Music sound recordings (rmusic)",
                        "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                        "8d1f5e72-e0a4-42b1-9de9-2d9452ecc46d": "PTF: PTF5 - PTF5",
                        "f4c4f756-c668-4d1c-a571-7dd8e5120918": "University of Chicago: music - Music scores, print (music)",
                        "bbdc114a-54b3-471c-b38e-506dd124f529": "University of Chicago: maps - Maps, print (maps)",
                        "9611e336-ab79-4d96-ad50-f3cf444df7df": "University of Chicago: its - Information Technology Services (its)",
                        "173288b9-72cb-450d-9b96-dfde2a7c9022": "University of Chicago: polsky - Polsky TECHB@R(polsky)",
                        "3212e362-e7a4-4610-80c9-2349a06a1050": "University of Chicago: rnonmusic - Non-music sound recordings (rnonmusic)",
                        "da161967-cab7-4b0f-bbbe-bba79ce9dca2": "PTF: PTF7 - PTF7",
                        "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                        "3edb3980-b037-484c-ba0d-cb76432bac7d": "University of Chicago: mfilm - Microfilm (mfilm)",
                        "b9e012f8-2055-49c3-98e1-5a5b7241de50": "University of Chicago: mss - Manuscripts (mss)",
                        "37cdf9fe-e5af-4c06-a2a6-3089157e8efc": "University of Chicago: mfiche - Microfiche (mfiche)",
                        "85258fc4-a5ac-430f-a071-bb33df32ed89": "University of Chicago: emaps - Maps, electronic (emaps)",
                        "c6de6928-bb6e-4458-97f4-9145b27abb24": "University of Chicago: books - Books, print (books)",
                        "870a11ee-3f16-4467-9ba1-0870078ecb41": "University of Chicago: emusic - Music scores, electronic (emusic)",
                        "05dfeb83-c186-433e-aa98-a8372b73c5b8": "Serial status: ISER - Inactive serial",
                        "0bad9883-c0c0-464c-81b1-0aec6279260e": "PTF: PTF2 - PTF2",
                        "236d828c-78d9-4fd9-b6c1-e2cc3e270c8b": "University of Chicago: audstream - Streaming audio (audstream)",
                        "24eeacc2-c2e7-4452-911b-0f373588f713": "PTF: PTF6 - PTF6",
                        "79e15d8b-cdc7-451c-95c0-f0e12a80840b": "University of Chicago: evisual - visual, static, electronic",
                        "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                        "916a41c9-5513-42e8-b384-31ea512cfb35": "PTF: PTF4 - PTF4",
                        "e31a8694-e188-44f0-ab6d-5ad612c9a800": "University of Chicago: mmedia - Mixed media (mmedia)"
                      }
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "title",
              "enabled": false,
              "path": "instance.title",
              "value": "",
              "subfields": []
            },
            {
              "name": "alternativeTitles",
              "enabled": false,
              "path": "instance.alternativeTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "indexTitle",
              "enabled": false,
              "path": "instance.indexTitle",
              "value": "",
              "subfields": []
            },
            {
              "name": "series",
              "enabled": false,
              "path": "instance.series[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "precedingTitles",
              "enabled": false,
              "path": "instance.precedingTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "succeedingTitles",
              "enabled": false,
              "path": "instance.succeedingTitles[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "identifiers",
              "enabled": false,
              "path": "instance.identifiers[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "contributors",
              "enabled": false,
              "path": "instance.contributors[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publication",
              "enabled": false,
              "path": "instance.publication[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "editions",
              "enabled": false,
              "path": "instance.editions[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "physicalDescriptions",
              "enabled": false,
              "path": "instance.physicalDescriptions[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "instanceTypeId",
              "enabled": false,
              "path": "instance.instanceTypeId",
              "value": "",
              "subfields": []
            },
            {
              "name": "natureOfContentTermIds",
              "enabled": true,
              "path": "instance.natureOfContentTermIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "instanceFormatIds",
              "enabled": false,
              "path": "instance.instanceFormatIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "languages",
              "enabled": false,
              "path": "instance.languages[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publicationFrequency",
              "enabled": false,
              "path": "instance.publicationFrequency[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "publicationRange",
              "enabled": false,
              "path": "instance.publicationRange[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "notes",
              "enabled": false,
              "path": "instance.notes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "electronicAccess",
              "enabled": false,
              "path": "instance.electronicAccess[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "subjects",
              "enabled": false,
              "path": "instance.subjects[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "classifications",
              "enabled": false,
              "path": "instance.classifications[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "parentInstances",
              "enabled": true,
              "path": "instance.parentInstances[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "childInstances",
              "enabled": true,
              "path": "instance.childInstances[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Instance
    * def folioRecord = 'INSTANCE'
    * def folioRecordNameAndDescription = 'FAT-945_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileInstanceId = $.id

    # MARC-to-Holdings (Adds the Holdings HRID as the former Holdings ID from 901$a; digitization policy from 300$a; adds a default stat code, Temp location, call number prefix, call number suffix, ILL policy, note)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945_New - MARC-to-Holdings",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "FAT-945_New - MARC-to-Holdings",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "holdings.discoverySuppress",
              "value": "",
              "subfields": []
            },
            {
              "name": "hrid",
              "enabled": false,
              "path": "holdings.discoverySuppress",
              "value": "",
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
                      "value": "\"901$a\""
                    }
                  ]
                }
              ],
              "repeatableFieldAction": "EXTEND_EXISTING"
            },
            {
              "name": "holdingsTypeId",
              "enabled": true,
              "path": "holdings.holdingsTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
              }
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
                        "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                        "bb76b1c1-c9df-445c-8deb-68bb3580edc2": "ARL (Collection stats): compfiles - Computer files, CDs, etc (compfiles)",
                        "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)",
                        "ecab577d-a050-4ea2-8a86-ea5a234283ea": "ARL (Collection stats): emusic - Music scores, electronic",
                        "97e91f57-fad7-41ea-a660-4031bf8d4ea8": "ARL (Collection stats): maps - Maps, print (maps)",
                        "16f2d65e-eb68-4ab1-93e3-03af50cb7370": "ARL (Collection stats): mfiche - Microfiche (mfiche)",
                        "1c622d0f-2e91-4c30-ba43-2750f9735f51": "ARL (Collection stats): mfilm - Microfilm (mfilm)",
                        "2850630b-cd12-4379-af57-5c51491a6873": "ARL (Collection stats): mmedia - Mixed media (mmedia)",
                        "30b5400d-0b9e-4757-a3d0-db0d30a49e72": "ARL (Collection stats): music - Music scores, print (music)",
                        "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings",
                        "91b8f0b4-0e13-4270-9fd6-e39203d0f449": "ARL (Collection stats): rnonmusic - Non-music sound recordings (rnonmusic)",
                        "775b6ad4-9c35-4d29-bf78-8775a9b42226": "ARL (Collection stats): serials - Serials, print (serials)",
                        "972f81d5-9f8f-4b56-a10e-5c05419718e6": "ARL (Collection stats): visual - Visual materials, DVDs, etc. (visual)",
                        "e10796e0-a594-47b7-b748-3a81b69b3d9b": "DISC (Discovery): audstream - Streaming audio (audstream)",
                        "b76a3088-8de6-46c8-a130-c8e74b8d2c5b": "DISC (Discovery): emaps - Maps, electronic (emaps)",
                        "a5ccf92e-7b1f-4990-ac03-780a6a767f37": "DISC (Discovery): eserials - Serials, electronic (eserials)",
                        "b2c0e100-0485-43f2-b161-3c60aac9f68a": "DISC (Discovery): evisual - Visual, static, electronic",
                        "6d584d0e-3dbc-46c4-a1bd-e9238dd9a6be": "DISC (Discovery): vidstream - Streaming video (vidstream)",
                        "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                        "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                        "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)",
                        "38249f9e-13f8-48bc-a010-8023cd194af5": "RECM (Record management): its - Information Technology Services (its)",
                        "d82c025e-436d-4006-a677-bd2b4cdb7692": "RECM (Record management): mss - Manuscripts (mss)",
                        "950d3370-9a3c-421e-b116-76e7511af9e9": "RECM (Record management): polsky - Polsky TECHB@R (polsky)",
                        "c4073462-6144-4b69-a543-dd131e241799": "RECM (Record management): withdrawn - Withdrawn (withdrawn)",
                        "c7a32c50-ea7c-43b7-87ab-d134c8371330": "SERM (Serial management): ASER - Active serial",
                        "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                        "0e516e54-bf36-4fc2-a0f7-3fe89a61c9c0": "SERM (Serial management): ISER - Inactive serial"
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
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "temporaryLocationId",
              "enabled": true,
              "path": "holdings.temporaryLocationId",
              "value": "\"Annex (KU/CC/DI/A)\"",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "shelvingOrder",
              "enabled": true,
              "path": "holdings.shelvingOrder",
              "value": "",
              "subfields": []
            },
            {
              "name": "shelvingTitle",
              "enabled": true,
              "path": "holdings.shelvingTitle",
              "value": "",
              "subfields": []
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "holdings.copyNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "callNumberTypeId",
              "enabled": true,
              "path": "holdings.callNumberTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "03dd64d0-5626-4ecd-8ece-4531e0069f35": "Dewey Decimal classification",
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification",
                "828ae637-dfa3-4265-a1af-5279c436edff": "MOYS",
                "054d460d-d6b9-4469-9e37-7a78a2266655": "National Library of Medicine classification",
                "6caca63e-5651-4db6-9247-3205156e9699": "Other scheme",
                "cd70562c-dd0b-42f6-aa80-ce803d24d4a1": "Shelved separately",
                "28927d76-e097-4f63-8510-e56f2b7a3ad0": "Shelving control number",
                "827a2b64-cbf5-4296-8545-130876e4dfc0": "Source specified in subfield $2",
                "fc388041-6cd0-4806-8a74-ebe3b9ab4c6e": "Superintendent of Documents classification",
                "5ba6b62e-6858-490a-8102-5b1369873835": "Title",
                "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f": "UDC"
              }
            },
            {
              "name": "callNumberPrefix",
              "enabled": true,
              "path": "holdings.callNumberPrefix",
              "value": "\"Pref1\"",
              "subfields": []
            },
            {
              "name": "callNumber",
              "enabled": true,
              "path": "holdings.callNumber",
              "value": "\"CallN1\"",
              "subfields": []
            },
            {
              "name": "callNumberSuffix",
              "enabled": true,
              "path": "holdings.callNumberSuffix",
              "value": "\"Suf1\"",
              "subfields": []
            },
            {
              "name": "numberOfItems",
              "enabled": true,
              "path": "holdings.numberOfItems",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatements",
              "enabled": true,
              "path": "holdings.holdingsStatements[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatementsForSupplements",
              "enabled": true,
              "path": "holdings.holdingsStatementsForSupplements[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "holdingsStatementsForIndexes",
              "enabled": true,
              "path": "holdings.holdingsStatementsForIndexes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "illPolicyId",
              "enabled": true,
              "path": "holdings.illPolicyId",
              "value": "\"Limited lending policy\"",
              "subfields": [],
              "acceptedValues": {
                "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy",
                "37fc2702-7ec9-482a-a4e3-5ed9a122ece1": "Unknown lending policy",
                "c51f7aa9-9997-45e6-94d6-b502445aae9d": "Unknown reproduction policy",
                "46970b40-918e-47a4-a45d-b1677a2d3d46": "Will lend",
                "2b870182-a23d-48e8-917d-9421e5c3ce13": "Will lend hard copy only",
                "b0f97013-87f5-4bab-87f2-ac4a5191b489": "Will not lend",
                "6bc6a71f-d6e2-4693-87f1-f495afddff00": "Will not reproduce",
                "2a572e7b-dfe5-4dee-8a62-b98d26a802e6": "Will reproduce"
              }
            },
            {
              "name": "digitizationPolicy",
              "enabled": true,
              "path": "holdings.digitizationPolicy",
              "subfields": [],
              "value": "\"300$a\""
            },
            {
              "name": "retentionPolicy",
              "enabled": true,
              "path": "holdings.retentionPolicy",
              "value": "",
              "subfields": []
            },
            {
              "name": "notes",
              "enabled": true,
              "path": "holdings.notes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "electronicAccess",
              "enabled": true,
              "path": "holdings.electronicAccess[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "receivingHistory.entries",
              "enabled": true,
              "path": "holdings.receivingHistory.entries[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Holdings
    * def folioRecord = 'HOLDINGS'
    * def folioRecordNameAndDescription = 'FAT-945_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileHoldingId = $.id

    #MARC-to-Item (Adds Item HRID as the barcode number (902$a); Adds copy number from 300$c. Adds an item note (1). Adds temporary loan type)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945_New: MARC-to-Item",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "ITEM",
        "description": "FAT-945_New: MARC-to-Item",
        "mappingDetails": {
          "name": "item",
          "recordType": "ITEM",
          "mappingFields": [
            {
              "name": "discoverySuppress",
              "enabled": true,
              "path": "item.discoverySuppress",
              "value": null,
              "subfields": []
            },
            {
              "name": "hrid",
              "enabled": true,
              "path": "item.hrid",
              "value": "",
              "subfields": []
            },
            {
              "name": "barcode",
              "enabled": true,
              "path": "item.barcode",
              "value": "\"902$a\"",
              "subfields": []
            },
            {
              "name": "accessionNumber",
              "enabled": true,
              "path": "item.accessionNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemIdentifier",
              "enabled": true,
              "path": "item.itemIdentifier",
              "value": "",
              "subfields": []
            },
            {
              "name": "formerIds",
              "enabled": true,
              "path": "item.formerIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "statisticalCodeIds",
              "enabled": true,
              "path": "item.statisticalCodeIds[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "materialType.id",
              "enabled": true,
              "path": "item.materialType.id",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "1a54b431-2e4f-452d-9cae-9cee66c9a892": "book",
                "5ee11d91-f7e8-481d-b079-65d708582ccc": "dvd",
                "615b8413-82d5-4203-aa6e-e37984cb5ac3": "electronic resource",
                "b9300fdb-a5c5-4dca-864e-3b8844438a0e": "kAoHIgTN",
                "fd6c6515-d470-4561-9c32-3e3290d4ca98": "microform",
                "dd0bf600-dbd9-44ab-9ff2-e2a61a6539f1": "sound recording",
                "d9acad2f-2aac-4b48-9097-e6ab85906b25": "text",
                "71fbd940-1027-40a6-8a48-49b44d795e46": "unspecified",
                "30b3e36a-d3b2-415e-98c2-47fbdf878862": "video recording",
                "c7859a0f-1cbc-4f5e-8484-51fb1647c754": "wtmtrBKi"
              }
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "item.copyNumber",
              "subfields": [],
              "value": "\"300$c\""
            },
            {
              "name": "itemLevelCallNumberTypeId",
              "enabled": true,
              "path": "item.itemLevelCallNumberTypeId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "03dd64d0-5626-4ecd-8ece-4531e0069f35": "Dewey Decimal classification",
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification",
                "828ae637-dfa3-4265-a1af-5279c436edff": "MOYS",
                "054d460d-d6b9-4469-9e37-7a78a2266655": "National Library of Medicine classification",
                "6caca63e-5651-4db6-9247-3205156e9699": "Other scheme",
                "cd70562c-dd0b-42f6-aa80-ce803d24d4a1": "Shelved separately",
                "28927d76-e097-4f63-8510-e56f2b7a3ad0": "Shelving control number",
                "827a2b64-cbf5-4296-8545-130876e4dfc0": "Source specified in subfield $2",
                "fc388041-6cd0-4806-8a74-ebe3b9ab4c6e": "Superintendent of Documents classification",
                "5ba6b62e-6858-490a-8102-5b1369873835": "Title",
                "d644be8f-deb5-4c4d-8c9e-2291b7c0f46f": "UDC"
              }
            },
            {
              "name": "itemLevelCallNumberPrefix",
              "enabled": true,
              "path": "item.itemLevelCallNumberPrefix",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemLevelCallNumber",
              "enabled": true,
              "path": "item.itemLevelCallNumber",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemLevelCallNumberSuffix",
              "enabled": true,
              "path": "item.itemLevelCallNumberSuffix",
              "value": "",
              "subfields": []
            },
            {
              "name": "numberOfPieces",
              "enabled": true,
              "path": "item.numberOfPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "descriptionOfPieces",
              "enabled": true,
              "path": "item.descriptionOfPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "enumeration",
              "enabled": true,
              "path": "item.enumeration",
              "value": "",
              "subfields": []
            },
            {
              "name": "chronology",
              "enabled": true,
              "path": "item.chronology",
              "value": "",
              "subfields": []
            },
            {
              "name": "volume",
              "enabled": true,
              "path": "item.volume",
              "value": "",
              "subfields": []
            },
            {
              "name": "yearCaption",
              "enabled": true,
              "path": "item.yearCaption[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "numberOfMissingPieces",
              "enabled": true,
              "path": "item.numberOfMissingPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "missingPieces",
              "enabled": true,
              "path": "item.missingPieces",
              "value": "",
              "subfields": []
            },
            {
              "name": "missingPiecesDate",
              "enabled": true,
              "path": "item.missingPiecesDate",
              "value": "",
              "subfields": []
            },
            {
              "name": "itemDamagedStatusId",
              "enabled": true,
              "path": "item.itemDamagedStatusId",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "54d1dd76-ea33-4bcb-955b-6b29df4f7930": "Damaged",
                "516b82eb-1f19-4a63-8c48-8f1a3e9ff311": "Not Damaged"
              }
            },
            {
              "name": "itemDamagedStatusDate",
              "enabled": true,
              "path": "item.itemDamagedStatusDate",
              "value": "",
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
                        "0e40884c-3523-4c6d-8187-d578e3d2794e": "Action note",
                        "87c450be-2033-41fb-80ba-dd2409883681": "Binding",
                        "1dde7141-ec8a-4dae-9825-49ce14c728e7": "Copy note",
                        "f3ae3823-d096-4c65-8734-0c1efd2ffea8": "Electronic bookplate",
                        "8d0a5eca-25de-4391-81a9-236eeefdd20b": "Note",
                        "c3a539b9-9576-4e3a-b6de-d910200b2919": "Provenance",
                        "acb3a58f-1d72-461d-97c3-0e7119e8d544": "Reproduction"
                      }
                    },
                    {
                      "name": "note",
                      "enabled": true,
                      "path": "item.notes[].note",
                      "value": "\"1\""
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
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
                "51b3d2bd-2097-4c6e-bd5d-782b9224b64a": "permanent loan type name AVwRUhvu",
                "eea094e7-d647-492d-b387-40226488d6f0": "permanent loan type name DUqkqXZG",
                "7809f955-718c-4714-9f1a-998570661c15": "permanent loan type name FvEHkEDZ",
                "eb3add38-1340-4e2c-9a20-0f8f8c0adc73": "permanent loan type name fzpvblUy",
                "be8a4c39-166b-4e6c-aefa-da0182cc2502": "permanent loan type name gCnvZDgL",
                "8863c827-19b8-437f-b71b-998f5f55afb8": "permanent loan type name iPAMWpwh",
                "8dd64315-0f37-43bd-8614-b1fc689c31f4": "permanent loan type name VfyTCCct",
                "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
              }
            },
            {
              "name": "temporaryLoanType.id",
              "enabled": true,
              "path": "item.temporaryLoanType.id",
              "value": "\"Can circulate\"",
              "subfields": [],
              "acceptedValues": {
                "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
                "51b3d2bd-2097-4c6e-bd5d-782b9224b64a": "permanent loan type name AVwRUhvu",
                "eea094e7-d647-492d-b387-40226488d6f0": "permanent loan type name DUqkqXZG",
                "7809f955-718c-4714-9f1a-998570661c15": "permanent loan type name FvEHkEDZ",
                "eb3add38-1340-4e2c-9a20-0f8f8c0adc73": "permanent loan type name fzpvblUy",
                "be8a4c39-166b-4e6c-aefa-da0182cc2502": "permanent loan type name gCnvZDgL",
                "8863c827-19b8-437f-b71b-998f5f55afb8": "permanent loan type name iPAMWpwh",
                "8dd64315-0f37-43bd-8614-b1fc689c31f4": "permanent loan type name VfyTCCct",
                "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
              }
            },
            {
              "name": "status.name",
              "enabled": true,
              "path": "item.status.name",
              "value": "",
              "subfields": []
            },
            {
              "name": "circulationNotes",
              "enabled": true,
              "path": "item.circulationNotes[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "permanentLocation.id",
              "enabled": true,
              "path": "item.permanentLocation.id",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "temporaryLocation.id",
              "enabled": true,
              "path": "item.temporaryLocation.id",
              "value": "",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "654ba0e3-2438-4e45-834c-70b7c604b6b4": "location name bSScpihS (location code aYYknzGY)",
                "461f9afc-7220-46b6-b42f-9a6edcb43436": "location name ltIOPdmj (location code HXcdeYGp)",
                "f7a5258e-f2a8-499d-bd54-75b1aeb3c6f1": "location name pQUxWbba (location code QEzhecrB)",
                "31cd0358-c296-4d44-b3df-384b9d503160": "location name qVULslqG (location code ONjPRLLU)",
                "b8c9989c-f08f-4ed7-bb65-67e43f01c96a": "location name rPNGptcW (location code kEtbDiBj)",
                "28514099-4785-4c83-9109-cd8890e1afef": "location name SgAxECDS (location code swlovyac)",
                "4deecb47-1cec-42ec-9106-cd0307b21afd": "location name yZPlKNmh (location code nDBIFLJM)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
              }
            },
            {
              "name": "electronicAccess",
              "enabled": true,
              "path": "item.electronicAccess[]",
              "value": "",
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
    * def mappingProfileInstanceId = $.id

    # Create action profile for UPDATE Item
    * def folioRecord = 'ITEM'
    * def folioRecordNameAndDescription = 'FAT-945_New - Update ' + folioRecord
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = mappingProfileInstanceId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileItemsId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945 MARC-to-MARC 001 to 001",
        "description": "FAT-945 MARC-to-MARC 001 to 001",
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
              "dataValueType": "VALUE_FROM_RECORD",
              "qualifier": {
                "qualifierType": null,
                "qualifierValue": null
              }
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
    * def matchProfileIdMarcToMarc = $.id

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945 MARC-to-Holdings 901a to Holdings HRID",
        "description": "FAT-945 MARC-to-Holdings 901a to Holdings HRID",
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
    * def matchProfileIdMarcToHoldings = $.id

    # Create match profile for MARC-to-Item 901a to Item HRID (wrong match)
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945 MARC-to-Item 902a to Item HRID",
        "description": "FAT-945 MARC-to-Item 902a to Item HRID",
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
    * def matchProfileIdMarcToItem = $.id

    # Create job profile - Implement 'Match MARC-to-MARC and update Instances, Holdings, and Items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-945_Implement Match MARC-to-MARC and update Instances, Holdings, and Items",
        "description": "FAT-945_Implement Match MARC-to-MARC and update Instances, Holdings, and Items 5 scenario_INTEGRATION",
        "dataType": "MARC"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToMarc)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 0
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToMarc)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileInstanceId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToHoldings)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToHoldings)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileHoldingId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(matchProfileIdMarcToItem)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
        },
        {
          "masterProfileId": "#(matchProfileIdMarcToItem)",
          "masterProfileType": "MATCH_PROFILE",
          "detailProfileId": "#(actionProfileItemsId)",
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

    # Create mapping profile for data-export
    Given path 'data-export/mapping-profiles'
    And headers headersUser
    * def exportMappingProfileName = 'FAT-945 Mapping instance, holding, item for export'
    And request read('classpath:folijet/data-import/samples/profiles/data-export-mapping-profile.json')
    When method POST
    Then status 201
    * def dataExportMappingProfileId = $.id

    # Create job profile for data-export
    Given path 'data-export/job-profiles'
    And headers headersUser
    And request
    """
    {
      "name": "FAT-945 Data-export job profile",
      "destination": "fileSystem",
      "description": "Job profile description",
      "mappingProfileId": "#(dataExportMappingProfileId)"
    }
    """
    When method POST
    Then status 201
    * def dataExportJobProfileId = $.id

    # Export MARC record by instance id
    * print 'Export MARC record by instance id'
    Given path 'data-export/quick-export'
    And headers headersUser
    And request
    """
    {
      "jobProfileId": "#(dataExportJobProfileId)",
      "uuids": [#(inventoryIdsMap.instanceId)],
      "type": "uuid",
      "recordType": "INSTANCE",
      "fileName": "FAT-944-1.mrc",
    }
    """
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Return job execution by id
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

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-945-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response, 'target/' + fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'file:target/' + fileName

    # Create file definition for FAT-945-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey: '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#(filePath)'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def importJobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

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
        "name": "FAT-945: Job profile",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities updated
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', importJobExecutionId
    And headers headersUser
    And retry until response.entries[0].instanceActionStatus != null && response.entries[0].holdingsActionStatus != null && response.entries[0].itemActionStatus != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'UPDATED'
    And assert response.entries[0].instanceActionStatus == 'UPDATED'
    And assert response.entries[0].holdingsActionStatus == 'UPDATED'
    And assert response.entries[0].itemActionStatus == 'DISCARDED'
    And match response.entries[0].error == '#notpresent'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify updated instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And match response.instances[0].statusId == 'daf2681c-25af-4202-a3fa-e58fdf806183'
    And match response.instances[0].statisticalCodeIds[*] contains '264c4f94-1538-43a3-8b40-bed68384b31b'
    And match response.instances[0].previouslyHeld == true

  Scenario: FAT-1204 Import MARC file, match on location, update Holdings and Item locations
    # Create mapping profile for create holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Create Holdings mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "permanentLocationId",
                "enabled": true,
                "path": "holdings.permanentLocationId",
                "value": "\"Annex (KU/CC/DI/A)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)"
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
    * def createHoldingsMappingProfileId = $.id

    # Create mapping profile for create item
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Create Item mapping profile",
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
                "value": "\"book\"",
                "subfields": [],
                "acceptedValues": {
                  "1a54b431-2e4f-452d-9cae-9cee66c9a892": "book",
                  "5ee11d91-f7e8-481d-b079-65d708582ccc": "dvd",
                  "615b8413-82d5-4203-aa6e-e37984cb5ac3": "electronic resource",
                  "fd6c6515-d470-4561-9c32-3e3290d4ca98": "microform",
                  "dd0bf600-dbd9-44ab-9ff2-e2a61a6539f1": "sound recording",
                  "d9acad2f-2aac-4b48-9097-e6ab85906b25": "text",
                  "71fbd940-1027-40a6-8a48-49b44d795e46": "unspecified",
                  "30b3e36a-d3b2-415e-98c2-47fbdf878862": "video recording"
                }
              },
              {
                "name": "permanentLoanType.id",
                "enabled": true,
                "path": "item.permanentLoanType.id",
                "value": "\"Can circulate\"",
                "subfields": [],
                "acceptedValues": {
                  "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                  "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
                  "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                  "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
                }
              },
              {
                "name": "status.name",
                "enabled": true,
                "path": "item.status.name",
                "value": "\"In process\"",
                "subfields": []
              },
              {
                "name": "permanentLocation.id",
                "enabled": true,
                "path": "item.permanentLocation.id",
                "value": "\"Annex (KU/CC/DI/A)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)"
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
    * def createItemMappingProfileId = $.id

    # Create action profile for create holdings
    * def folioRecordNameAndDescription = 'FAT-1204: create Holdings'
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createHoldingsActionProfileId = $.id

    # Create action profile for create item
    * def folioRecordNameAndDescription = 'FAT-1204: create Item'
    * def folioRecord = 'ITEM'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createItemActionProfileId = $.id

    # Create job profile - Create Instance, Holdings and Item
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Job profile create instance, holdings and items",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "fa45f3ec-9b83-11eb-a8b3-0242ac130003",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createHoldingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createItemActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 2
          }
        ],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createJobProfileId = $.id

    # Create mapping profile for update holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Update holdings mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "administrativeNotes",
                "enabled": true,
                "path": "holdings.administrativeNotes[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "holdings.administrativeNotes[]",
                    "fields": [
                      {
                        "name": "administrativeNote",
                        "enabled": true,
                        "path": "holdings.administrativeNotes[]",
                        "value": "\"Updated holding\""
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
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)"
                },
                "value": "910$a"
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
    * def updateHoldingsMappingProfileId = $.id

    # Create mapping profile for update item
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Update item mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "ITEM",
          "description": "",
          "mappingDetails": {
            "name": "item",
            "recordType": "ITEM",
            "mappingFields": [
              {
                "name": "administrativeNotes",
                "enabled": true,
                "path": "item.administrativeNotes[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "item.administrativeNotes[]",
                    "fields": [
                      {
                        "name": "administrativeNote",
                        "enabled": true,
                        "path": "item.administrativeNotes[]",
                        "value": "\"Updated item\""
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
                "value": "920$a",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)"
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
    * def updateItemMappingProfileId = $.id

    # Create action profile for update holdings
    * def folioRecordNameAndDescription = 'FAT-1204: Update Holdings'
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateHoldingsActionProfileId = $.id

    # Create action profile for update item
    * def folioRecordNameAndDescription = 'FAT-1204: Update Item'
    * def folioRecord = 'ITEM'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateItemActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 035$a field to OCLC
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Match 035$a on OCLC",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "035"
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
              "existingRecordType": "INSTANCE",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "instance.identifiers[].value"
                  },
                  {
                    "label": "identifierTypeId",
                    "value": "439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef"
                  }
                ],
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "INSTANCE"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def instanceMatchProfileId = $.id

    # Create match profile for MARC-to-HOLDINGS 901$a to permanentLocation
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Match profile update holdings",
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
                    "value": "holdingsrecord.permanentLocationId"
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
    * def holdingsMatchProfileId = $.id

    # Create match profile for MARC-to-ITEM 901$a to permanentLocation
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Match profile update item",
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
              "existingRecordType": "ITEM",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "item.permanentLocationId"
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
    * def itemMatchProfileId = $.id

    #  Create job profile - update holdings and items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1204: Job profile update holdings and items",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(holdingsMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(holdingsMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(updateHoldingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(itemMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 1,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(itemMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(updateItemActionProfileId)",
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
    * def updateJobProfileId = $.id

    # Import file and create instance, holdings, item
    * def jobProfileId = createJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-1204', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for create instance, holdings and items
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 6
    And assert jobExecution.progress.total == 6
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[*].sourceRecordActionStatus == ["CREATED","CREATED","CREATED","CREATED","CREATED","CREATED"]
    And match response.entries[*].instanceActionStatus == ["CREATED","CREATED","CREATED","CREATED","CREATED","CREATED"]
    And match response.entries[*].holdingsActionStatus == ["CREATED","CREATED","CREATED","CREATED","CREATED","CREATED"]

    # Import file and update instance, holdings, item
    * def jobProfileId = updateJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-1204-UPDATED', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for update holdings and items
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 6
    And assert jobExecution.progress.total == 6
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

     # Verify that needed entities updated
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[*].holdingsActionStatus == ["UPDATED","UPDATED","UPDATED","UPDATED","UPDATED","UPDATED"]
    And match response.entries[*].itemActionStatus == ["UPDATED","UPDATED","UPDATED","UPDATED","UPDATED","UPDATED"]

    # Verify updated holdings record
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'administrativeNotes==["Updated holding"]'
    When method GET
    Then status 200
    And assert response.totalRecords == 6
    And match response.holdingsRecords[*].permanentLocationId == ["fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371"]

    # Verify updated item record
    * call pause 10000
    Given path '/item-storage/items'
    And headers headersUser
    And param query = 'administrativeNotes==["Updated item"]'
    When method GET
    Then status 200
    And assert response.totalRecords == 6
    And match response.items[*].permanentLocationId == ["758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd"]

  Scenario: FAT-1472 Test import with static match on Holdings permanent location
     # Create mapping profile for create instances
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1472: Create Instances mapping profile",
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
                "subfields": [],
                "value": "\"2022-09-15\""
              },
              {
                "name": "statusId",
                "enabled": true,
                "path": "instance.statusId",
                "subfields": [],
                "acceptedValues": {
                  "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                  "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged",
                  "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41": "Not yet assigned",
                  "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other",
                  "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary",
                  "26f5208e-110a-4394-be29-1569a8c84a65": "Uncataloged"
                },
                "value": "\"Other\""
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
                          "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)"
                        }
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "natureOfContentTermIds",
                "enabled": true,
                "path": "instance.natureOfContentTermIds[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "instance.natureOfContentTermIds[]",
                    "fields": [
                      {
                        "name": "natureOfContentTermId",
                        "enabled": true,
                        "path": "instance.natureOfContentTermIds[]",
                        "value": "\"journal\"",
                        "acceptedValues": {
                          "96879b60-098b-453b-bf9a-c47866f1ab2a": "audiobook",
                          "04a6a8d2-f902-4774-b15f-d8bd885dc804": "autobiography",
                          "f5908d05-b16a-49cf-b192-96d55a94a0d1": "bibliography",
                          "b6e214bd-82f5-467f-af5b-4592456dc4ab": "biography",
                          "acceb2d6-4f05-408f-9a88-a92de26441ce": "comic (book)",
                          "b82b3a0d-00fa-4811-96da-04f531da8ea8": "exhibition catalogue",
                          "c0d52f31-aabb-4c55-bf81-fea7fdda94a4": "experience report",
                          "b29d4dc1-f78b-48fe-b3e5-df6c37cdc58d": "festschrift",
                          "631893b6-5d8a-4e1a-9e6b-5344e2945c74": "illustrated book / picture book",
                          "0abeee3d-8ad2-4b04-92ff-221b4fce1075": "journal",
                          "31572023-f4c9-4cf3-80a2-0543c9eda884": "literature report",
                          "536da7c1-9c35-45df-8ea1-c3545448df92": "monographic series",
                          "ebbbdef1-00e1-428b-bc11-314dc0705074": "newspaper",
                          "073f7f2f-9212-4395-b039-6f9825b11d54": "proceedings",
                          "71b43e3a-8cdd-4d22-9751-020f34fb6ef8": "report",
                          "4570a93e-ddb6-4200-8e8b-283c8f5c9bfa": "research report",
                          "85657646-6b6f-4e71-b54c-d47f3b95a5ed": "school program",
                          "44cd89f3-2e76-469f-a955-cc57cb9e0395": "textbook",
                          "94f6d06a-61e0-47c1-bbcb-6186989e6040": "thesis",
                          "9419a20e-6c8f-4ae1-85a7-8c184a1f4762": "travel report",
                          "2fbc8a7b-b432-45df-ba37-46031b1f6545": "website"
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
    * def createInstancesMappingProfileId = $.id

   # Create mapping profile for create holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1472: Create Holdings mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "holdingsTypeId",
                "enabled": true,
                "path": "holdings.holdingsTypeId",
                "value": "\"Monograph\"",
                "subfields": [],
                "acceptedValues": {
                  "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                  "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                  "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                  "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                  "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
                }
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
                          "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                          "bb76b1c1-c9df-445c-8deb-68bb3580edc2": "ARL (Collection stats): compfiles - Computer files, CDs, etc (compfiles)",
                          "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)",
                          "ecab577d-a050-4ea2-8a86-ea5a234283ea": "ARL (Collection stats): emusic - Music scores, electronic",
                          "97e91f57-fad7-41ea-a660-4031bf8d4ea8": "ARL (Collection stats): maps - Maps, print (maps)",
                          "16f2d65e-eb68-4ab1-93e3-03af50cb7370": "ARL (Collection stats): mfiche - Microfiche (mfiche)",
                          "1c622d0f-2e91-4c30-ba43-2750f9735f51": "ARL (Collection stats): mfilm - Microfilm (mfilm)",
                          "2850630b-cd12-4379-af57-5c51491a6873": "ARL (Collection stats): mmedia - Mixed media (mmedia)",
                          "30b5400d-0b9e-4757-a3d0-db0d30a49e72": "ARL (Collection stats): music - Music scores, print (music)",
                          "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings",
                          "91b8f0b4-0e13-4270-9fd6-e39203d0f449": "ARL (Collection stats): rnonmusic - Non-music sound recordings (rnonmusic)",
                          "775b6ad4-9c35-4d29-bf78-8775a9b42226": "ARL (Collection stats): serials - Serials, print (serials)",
                          "972f81d5-9f8f-4b56-a10e-5c05419718e6": "ARL (Collection stats): visual - Visual materials, DVDs, etc. (visual)",
                          "e10796e0-a594-47b7-b748-3a81b69b3d9b": "DISC (Discovery): audstream - Streaming audio (audstream)",
                          "b76a3088-8de6-46c8-a130-c8e74b8d2c5b": "DISC (Discovery): emaps - Maps, electronic (emaps)",
                          "a5ccf92e-7b1f-4990-ac03-780a6a767f37": "DISC (Discovery): eserials - Serials, electronic (eserials)",
                          "b2c0e100-0485-43f2-b161-3c60aac9f68a": "DISC (Discovery): evisual - Visual, static, electronic",
                          "6d584d0e-3dbc-46c4-a1bd-e9238dd9a6be": "DISC (Discovery): vidstream - Streaming video (vidstream)",
                          "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                          "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                          "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)",
                          "38249f9e-13f8-48bc-a010-8023cd194af5": "RECM (Record management): its - Information Technology Services (its)",
                          "d82c025e-436d-4006-a677-bd2b4cdb7692": "RECM (Record management): mss - Manuscripts (mss)",
                          "950d3370-9a3c-421e-b116-76e7511af9e9": "RECM (Record management): polsky - Polsky TECHB@R (polsky)",
                          "c4073462-6144-4b69-a543-dd131e241799": "RECM (Record management): withdrawn - Withdrawn (withdrawn)",
                          "c7a32c50-ea7c-43b7-87ab-d134c8371330": "SERM (Serial management): ASER - Active serial",
                          "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                          "0e516e54-bf36-4fc2-a0f7-3fe89a61c9c0": "SERM (Serial management): ISER - Inactive serial"
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
                "value": "\"Annex (KU/CC/DI/A)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
                }
              },
              {
                "name": "temporaryLocationId",
                "enabled": true,
                "path": "holdings.temporaryLocationId",
                "value": "\"Main Library (KU/CC/DI/M)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
                }
              },
              {
                "name": "illPolicyId",
                "enabled": true,
                "path": "holdings.illPolicyId",
                "value": "\"Limited lending policy\"",
                "subfields": [],
                "acceptedValues": {
                  "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy",
                  "37fc2702-7ec9-482a-a4e3-5ed9a122ece1": "Unknown lending policy",
                  "c51f7aa9-9997-45e6-94d6-b502445aae9d": "Unknown reproduction policy",
                  "46970b40-918e-47a4-a45d-b1677a2d3d46": "Will lend",
                  "2b870182-a23d-48e8-917d-9421e5c3ce13": "Will lend hard copy only",
                  "b0f97013-87f5-4bab-87f2-ac4a5191b489": "Will not lend",
                  "6bc6a71f-d6e2-4693-87f1-f495afddff00": "Will not reproduce",
                  "2a572e7b-dfe5-4dee-8a62-b98d26a802e6": "Will reproduce"
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
    * def createHoldingsMappingProfileId = $.id

     # Create action profile for create instances
    * def folioRecordNameAndDescription = 'FAT-1472: create Instances'
    * def folioRecord = 'INSTANCE'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createInstancesMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createInstancesActionProfileId = $.id

    # Create action profile for create holdings
    * def folioRecordNameAndDescription = 'FAT-1472: create Holdings'
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createHoldingsActionProfileId = $.id

     # Create job profile - Create Instances and Holdings
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1472: Job profile create instances and holdings",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createInstancesActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createHoldingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          }
        ],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createJobProfileId = $.id

    # Import file and create instances, holdings
    * def jobProfileId = createJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-1472', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for create instances, holdings
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].holdingsActionStatus == "CREATED"
    And match response.entries[0].instanceActionStatus == "CREATED"
    And def sourceRecordId = response.entries[0].sourceRecordId
    And def jobExecutionId = response.entries[0].sourceRecordId.jobExecutionId
    And def holdingHrid = response.entries[0].holdingsRecordHridList[0]

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify create holdings record correct mapping
    * call pause 10000
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + holdingHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '03c9c400-b9e3-4a07-ac0e-05ab470233ed'
    And assert response.holdingsRecords[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    And assert response.holdingsRecords[0].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[0].temporaryLocationId == 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    And assert response.holdingsRecords[0].illPolicyId == '9e49924b-f649-4b36-ab57-e66e639a9b0e'

    # Create mapping profile for update holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1472: Update Holdings mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "holdingsTypeId",
                "enabled": true,
                "path": "holdings.holdingsTypeId",
                "value": "\"Electronic\"",
                "subfields": [],
                "acceptedValues": {
                  "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                  "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                  "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                  "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                  "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
                }
              },
              {
                "name": "temporaryLocationId",
                "enabled": true,
                "path": "holdings.temporaryLocationId",
                "value": "\"Online (E)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
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
    * def updateHoldingsMappingProfileId = $.id

   # Create action profile for update holdings
    * def folioRecordNameAndDescription = 'FAT-1472: update Holdings'
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateHoldingsActionProfileId = $.id

     # Create match profile for MARC-to-INSTANCE 001 field to hrId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "Match on 001 ",
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
              "existingRecordType": "INSTANCE",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "instance.hrid"
                  }
                ],
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "INSTANCE"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def instanceMatchProfileId = $.id

    # Create match profile for MARC-to-HOLDINGS 901$a to permanentLocation
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "Match on Permanent Location",
          "description": "",
          "incomingRecordType": "STATIC_VALUE",
          "matchDetails": [
            {
              "incomingRecordType": "STATIC_VALUE",
              "incomingMatchExpression": {
                "staticValueDetails": {
                  "staticValueType": "TEXT",
                  "text": "Annex (KU/CC/DI/A)",
                  "number": "",
                  "exactDate": "",
                  "fromDate": "",
                  "toDate": ""
                },
                "dataValueType": "STATIC_VALUE"
              },
              "existingRecordType": "HOLDINGS",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "holdingsrecord.permanentLocationId"
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
    * def holdingsMatchProfileId = $.id

    #  Create job profile - update holdings and items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1472: Job profile update holdings on static field",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(holdingsMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(holdingsMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(updateHoldingsActionProfileId)",
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
    * def updateJobProfileId = $.id

    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/FAT-1472.mrc')
    * def updatedMarcRecord = javaDemo.replaceHrIdFieldInMarcFile(marcRecord, '1060180377', instanceHrid)

    * def jobProfileId = updateJobProfileId

    ## Upload marc file
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "size": 1,
          "name": "FAT-1472-UPDATED.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def HfileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request updatedMarcRecord
    When method post
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = false
    And headers headersUser
    And request read(samplePath + 'jobs/customJob.json')
    When method post
    Then status 204

    Given path 'change-manager/jobExecutions', jobExecutionId
    And headers headersUser
    And print response.status
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method get
    Then status 200
    And def status = response.status

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error

    # Verify job execution for update holdings
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].holdingsActionStatus == "UPDATED"
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Verify create holdings record correct mapping
    * call pause 10000
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + holdingHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '996f93e2-5b5e-4cf2-9168-33ced1f95eed'
    And assert response.holdingsRecords[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    And assert response.holdingsRecords[0].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[0].temporaryLocationId == '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
    And assert response.holdingsRecords[0].illPolicyId == '9e49924b-f649-4b36-ab57-e66e639a9b0e'

  Scenario: FAT-1471 Test import of MARC with subfields that are not mapped to Instance fields - INTEGRATION
    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-1471', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for create instance
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify instance created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "CREATED"
    And match response.entries[0].instanceActionStatus == "CREATED"

    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Retrieve instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def updatedInstance = response.instances[0]
    * eval updatedInstance['natureOfContentTermIds'] = ["96879b60-098b-453b-bf9a-c47866f1ab2a"]

    # Update nature of content
    Given path 'inventory/instances', updatedInstance.id
    And headers headersUser
    And request updatedInstance
    When method PUT
    Then status 204

    # Verify nature of content updated and 590$3 don't mapped to Instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And match response.instances[0].natureOfContentTermIds[0] == "96879b60-098b-453b-bf9a-c47866f1ab2a"
    And match each response.instances[0].notes..note != 'test'

  Scenario: FAT-1124 Test import with static match on Holdings permanent location with different format
    # Create mapping profile for create instances
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1124: Create Instances mapping profile",
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
                "subfields": [],
                "value": "\"2022-09-15\""
              },
              {
                "name": "statusId",
                "enabled": true,
                "path": "instance.statusId",
                "subfields": [],
                "acceptedValues": {
                  "52a2ff34-2a12-420d-8539-21aa8d3cf5d8": "Batch Loaded",
                  "9634a5ab-9228-4703-baf2-4d12ebc77d56": "Cataloged",
                  "f5cc2ab6-bb92-4cab-b83f-5a3d09261a41": "Not yet assigned",
                  "2a340d34-6b70-443a-bb1b-1b8d1c65d862": "Other",
                  "daf2681c-25af-4202-a3fa-e58fdf806183": "Temporary",
                  "26f5208e-110a-4394-be29-1569a8c84a65": "Uncataloged"
                },
                "value": "\"Other\""
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
                          "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)"
                        }
                      }
                    ]
                  }
                ],
                "repeatableFieldAction": "EXTEND_EXISTING"
              },
              {
                "name": "natureOfContentTermIds",
                "enabled": true,
                "path": "instance.natureOfContentTermIds[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "instance.natureOfContentTermIds[]",
                    "fields": [
                      {
                        "name": "natureOfContentTermId",
                        "enabled": true,
                        "path": "instance.natureOfContentTermIds[]",
                        "value": "\"journal\"",
                        "acceptedValues": {
                          "96879b60-098b-453b-bf9a-c47866f1ab2a": "audiobook",
                          "04a6a8d2-f902-4774-b15f-d8bd885dc804": "autobiography",
                          "f5908d05-b16a-49cf-b192-96d55a94a0d1": "bibliography",
                          "b6e214bd-82f5-467f-af5b-4592456dc4ab": "biography",
                          "acceb2d6-4f05-408f-9a88-a92de26441ce": "comic (book)",
                          "b82b3a0d-00fa-4811-96da-04f531da8ea8": "exhibition catalogue",
                          "c0d52f31-aabb-4c55-bf81-fea7fdda94a4": "experience report",
                          "b29d4dc1-f78b-48fe-b3e5-df6c37cdc58d": "festschrift",
                          "631893b6-5d8a-4e1a-9e6b-5344e2945c74": "illustrated book / picture book",
                          "0abeee3d-8ad2-4b04-92ff-221b4fce1075": "journal",
                          "31572023-f4c9-4cf3-80a2-0543c9eda884": "literature report",
                          "536da7c1-9c35-45df-8ea1-c3545448df92": "monographic series",
                          "ebbbdef1-00e1-428b-bc11-314dc0705074": "newspaper",
                          "073f7f2f-9212-4395-b039-6f9825b11d54": "proceedings",
                          "71b43e3a-8cdd-4d22-9751-020f34fb6ef8": "report",
                          "4570a93e-ddb6-4200-8e8b-283c8f5c9bfa": "research report",
                          "85657646-6b6f-4e71-b54c-d47f3b95a5ed": "school program",
                          "44cd89f3-2e76-469f-a955-cc57cb9e0395": "textbook",
                          "94f6d06a-61e0-47c1-bbcb-6186989e6040": "thesis",
                          "9419a20e-6c8f-4ae1-85a7-8c184a1f4762": "travel report",
                          "2fbc8a7b-b432-45df-ba37-46031b1f6545": "website"
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
    * def createInstancesMappingProfileId = $.id

   # Create mapping profile for create holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1124: Create Holdings mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "holdingsTypeId",
                "enabled": true,
                "path": "holdings.holdingsTypeId",
                "value": "\"Monograph\"",
                "subfields": [],
                "acceptedValues": {
                  "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                  "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                  "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                  "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                  "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
                }
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
                          "b5968c9e-cddc-4576-99e3-8e60aed8b0dd": "ARL (Collection stats): books - Book, print (books)",
                          "bb76b1c1-c9df-445c-8deb-68bb3580edc2": "ARL (Collection stats): compfiles - Computer files, CDs, etc (compfiles)",
                          "9d8abbe2-1a94-4866-8731-4d12ac09f7a8": "ARL (Collection stats): ebooks - Books, electronic (ebooks)",
                          "ecab577d-a050-4ea2-8a86-ea5a234283ea": "ARL (Collection stats): emusic - Music scores, electronic",
                          "97e91f57-fad7-41ea-a660-4031bf8d4ea8": "ARL (Collection stats): maps - Maps, print (maps)",
                          "16f2d65e-eb68-4ab1-93e3-03af50cb7370": "ARL (Collection stats): mfiche - Microfiche (mfiche)",
                          "1c622d0f-2e91-4c30-ba43-2750f9735f51": "ARL (Collection stats): mfilm - Microfilm (mfilm)",
                          "2850630b-cd12-4379-af57-5c51491a6873": "ARL (Collection stats): mmedia - Mixed media (mmedia)",
                          "30b5400d-0b9e-4757-a3d0-db0d30a49e72": "ARL (Collection stats): music - Music scores, print (music)",
                          "6899291a-1fb9-4130-98ce-b40368556818": "ARL (Collection stats): rmusic - Music sound recordings",
                          "91b8f0b4-0e13-4270-9fd6-e39203d0f449": "ARL (Collection stats): rnonmusic - Non-music sound recordings (rnonmusic)",
                          "775b6ad4-9c35-4d29-bf78-8775a9b42226": "ARL (Collection stats): serials - Serials, print (serials)",
                          "972f81d5-9f8f-4b56-a10e-5c05419718e6": "ARL (Collection stats): visual - Visual materials, DVDs, etc. (visual)",
                          "e10796e0-a594-47b7-b748-3a81b69b3d9b": "DISC (Discovery): audstream - Streaming audio (audstream)",
                          "b76a3088-8de6-46c8-a130-c8e74b8d2c5b": "DISC (Discovery): emaps - Maps, electronic (emaps)",
                          "a5ccf92e-7b1f-4990-ac03-780a6a767f37": "DISC (Discovery): eserials - Serials, electronic (eserials)",
                          "b2c0e100-0485-43f2-b161-3c60aac9f68a": "DISC (Discovery): evisual - Visual, static, electronic",
                          "6d584d0e-3dbc-46c4-a1bd-e9238dd9a6be": "DISC (Discovery): vidstream - Streaming video (vidstream)",
                          "f47b773a-bd5f-4246-ac1e-fa4adcd0dcdf": "RECM (Record management): UCPress - University of Chicago Press Imprint",
                          "264c4f94-1538-43a3-8b40-bed68384b31b": "RECM (Record management): XOCLC - Do not share with OCLC",
                          "b6b46869-f3c1-4370-b603-29774a1e42b1": "RECM (Record management): arch - Archives (arch)",
                          "38249f9e-13f8-48bc-a010-8023cd194af5": "RECM (Record management): its - Information Technology Services (its)",
                          "d82c025e-436d-4006-a677-bd2b4cdb7692": "RECM (Record management): mss - Manuscripts (mss)",
                          "950d3370-9a3c-421e-b116-76e7511af9e9": "RECM (Record management): polsky - Polsky TECHB@R (polsky)",
                          "c4073462-6144-4b69-a543-dd131e241799": "RECM (Record management): withdrawn - Withdrawn (withdrawn)",
                          "c7a32c50-ea7c-43b7-87ab-d134c8371330": "SERM (Serial management): ASER - Active serial",
                          "0868921a-4407-47c9-9b3e-db94644dbae7": "SERM (Serial management): ENF - Entry not found",
                          "0e516e54-bf36-4fc2-a0f7-3fe89a61c9c0": "SERM (Serial management): ISER - Inactive serial"
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
                "value": "\"Annex (KU/CC/DI/A)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
                }
              },
              {
                "name": "temporaryLocationId",
                "enabled": true,
                "path": "holdings.temporaryLocationId",
                "value": "\"Main Library (KU/CC/DI/M)\"",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
                }
              },
              {
                "name": "illPolicyId",
                "enabled": true,
                "path": "holdings.illPolicyId",
                "value": "\"Limited lending policy\"",
                "subfields": [],
                "acceptedValues": {
                  "9e49924b-f649-4b36-ab57-e66e639a9b0e": "Limited lending policy",
                  "37fc2702-7ec9-482a-a4e3-5ed9a122ece1": "Unknown lending policy",
                  "c51f7aa9-9997-45e6-94d6-b502445aae9d": "Unknown reproduction policy",
                  "46970b40-918e-47a4-a45d-b1677a2d3d46": "Will lend",
                  "2b870182-a23d-48e8-917d-9421e5c3ce13": "Will lend hard copy only",
                  "b0f97013-87f5-4bab-87f2-ac4a5191b489": "Will not lend",
                  "6bc6a71f-d6e2-4693-87f1-f495afddff00": "Will not reproduce",
                  "2a572e7b-dfe5-4dee-8a62-b98d26a802e6": "Will reproduce"
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
    * def createHoldingsMappingProfileId = $.id

     # Create action profile for create instances
    * def folioRecordNameAndDescription = 'FAT-1124: create Instances'
    * def folioRecord = 'INSTANCE'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createInstancesMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createInstancesActionProfileId = $.id

    # Create action profile for create holdings
    * def folioRecordNameAndDescription = 'FAT-1124: create Holdings'
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createHoldingsActionProfileId = $.id

     # Create job profile - Create Instances and Holdings
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "FAT-1124: Job profile create instances and holdings",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createInstancesActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(createHoldingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          }
        ],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def createJobProfileId = $.id

    # Import file and create instances, holdings
    * def jobProfileId = createJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-1124', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify job execution for create instances, holdings
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].holdingsActionStatus == "CREATED"
    And match response.entries[0].instanceActionStatus == "CREATED"
    And def sourceRecordId = response.entries[0].sourceRecordId
    And def jobExecutionId = response.entries[0].sourceRecordId.jobExecutionId
    And def holdingHrid = response.entries[0].holdingsRecordHridList[0]

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify create holdings record correct mapping
    * call pause 10000
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + holdingHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '03c9c400-b9e3-4a07-ac0e-05ab470233ed'
    And assert response.holdingsRecords[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    And assert response.holdingsRecords[0].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[0].temporaryLocationId == 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    And assert response.holdingsRecords[0].illPolicyId == '9e49924b-f649-4b36-ab57-e66e639a9b0e'

    * call read(updateHoldings) {instanceHrId: '#(instanceHrId)', uniqueProfileName: 'Location name (code)', staticMatchValue: 'Annex (KU/CC/DI/A)', holdingType: '\"Electronic\"', temporaryLocation: '\"Online (E)\"'}

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error

    # Verify job execution for update holdings
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].holdingsActionStatus == "UPDATED"
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Verify update holdings record correct mapping
    * call pause 10000
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + holdingHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '996f93e2-5b5e-4cf2-9168-33ced1f95eed'
    And assert response.holdingsRecords[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    And assert response.holdingsRecords[0].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[0].temporaryLocationId == '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
    And assert response.holdingsRecords[0].illPolicyId == '9e49924b-f649-4b36-ab57-e66e639a9b0e'

    * call read(updateHoldings) {instanceHrId: '#(instanceHrId)', uniqueProfileName: 'Location name', staticMatchValue: 'Annex', holdingType: '\"Physical\"', temporaryLocation: '\"SECOND FLOOR (KU/CC/DI/2)\"'}

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error

    # Verify job execution for update holdings
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].holdingsActionStatus == "UPDATED"
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Verify update holdings record correct mapping
    * call pause 10000
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + holdingHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '0c422f92-0f4d-4d32-8cbe-390ebc33a3e5'
    And assert response.holdingsRecords[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    And assert response.holdingsRecords[0].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[0].temporaryLocationId == 'f34d27c6-a8eb-461b-acd6-5dea81771e70'
    And assert response.holdingsRecords[0].illPolicyId == '9e49924b-f649-4b36-ab57-e66e639a9b0e'

    * call read(updateHoldings) {instanceHrId: '#(instanceHrId)', uniqueProfileName: 'Code', staticMatchValue: 'KU/CC/DI/A', holdingType: '\"Monograph\"', temporaryLocation: '\"ORWIG ETHNO CD (KU/CC/DI/O)\"'}

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error

    # Verify job execution for update holdings
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].holdingsActionStatus == "UPDATED"
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Verify update holdings record correct mapping
    * call pause 10000
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + holdingHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And assert response.holdingsRecords[0].holdingsTypeId == '03c9c400-b9e3-4a07-ac0e-05ab470233ed'
    And assert response.holdingsRecords[0].statisticalCodeIds[0] == 'b5968c9e-cddc-4576-99e3-8e60aed8b0dd'
    And assert response.holdingsRecords[0].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[0].temporaryLocationId == '758258bc-ecc1-41b8-abca-f7b610822ffd'
    And assert response.holdingsRecords[0].illPolicyId == '9e49924b-f649-4b36-ab57-e66e639a9b0e'

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
        "authentication": "100473910/PAOLF",
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
    And retry until response.jobExecutions[0].status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    And param sortBy = "completed_date,desc"
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id

    # Check imported file name
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
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
    And retry until response.jobExecutions[0].status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    And param sortBy = "completed_date,desc"
    When method GET
    Then status 200
    And def jobExecutionId = response.jobExecutions[0].id

    # Check imported file name
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.entries[0].sourceRecordTitle == 'Space architecture : the work of John Frassanito & Associates for NASA / John Zukowsky ; with a preface by Buzz Aldrin.'
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Compare instance source data
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And def overlayParsedRecord = response.parsedRecord
    And match overlayParsedRecord.content.fields[0] == parsedRecord.content.fields[0]
    And match $overlayParsedRecord.content.fields[?(@.005)] != $parsedRecord.content.fields[?(@.005)]
    And match containsDuplicatesOfFields(overlayParsedRecord.content.fields, ['006', '007', '008']) == false

  @Ignore
  @UpdateHoldings
  Scenario: update holdings with custom static location match
    * def mappingProfileName = 'FAT-1124: Update Holdings mapping profile ' + uniqueProfileName
    * def matchProfileInstanceName = 'FAT-1124: Match on 001 ' + uniqueProfileName
    * def matchProfileHoldingsName = 'FAT-1124: Match on Permanent Location ' + uniqueProfileName
    * def jobProfileUpdateName = 'FAT-1124: Job profile update holdings on static field ' + uniqueProfileName

    # Create mapping profile for update holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(mappingProfileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "HOLDINGS",
          "description": "",
          "mappingDetails": {
            "name": "holdings",
            "recordType": "HOLDINGS",
            "mappingFields": [
              {
                "name": "holdingsTypeId",
                "enabled": true,
                "path": "holdings.holdingsTypeId",
                "value": "#(holdingType)",
                "subfields": [],
                "acceptedValues": {
                  "996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic",
                  "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph",
                  "dc35d0ae-e877-488b-8e97-6e41444e6d0a": "Multi-part monograph",
                  "0c422f92-0f4d-4d32-8cbe-390ebc33a3e5": "Physical",
                  "e6da6c98-6dd0-41bc-8b4b-cfd4bbd9c3ae": "Serial"
                }
              },
              {
                "name": "temporaryLocationId",
                "enabled": true,
                "path": "holdings.temporaryLocationId",
                "value": "#(temporaryLocation)",
                "subfields": [],
                "acceptedValues": {
                  "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                  "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                  "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                  "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                  "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                  "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)"
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
    * def updateHoldingsMappingProfileId = $.id

   # Create action profile for update holdings
    * def folioRecordNameAndDescription = 'FAT-1124: update Holdings ' + uniqueProfileName
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateHoldingsActionProfileId = $.id

     # Create match profile for MARC-to-INSTANCE 001 field to hrId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(matchProfileInstanceName)",
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
              "existingRecordType": "INSTANCE",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "instance.hrid"
                  }
                ],
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "matchCriterion": "EXACTLY_MATCHES"
            }
          ],
          "existingRecordType": "INSTANCE"
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def instanceMatchProfileId = $.id

    # Create match profile for MARC-to-HOLDINGS 901$a to location(code)
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(matchProfileHoldingsName)",
          "description": "",
          "incomingRecordType": "STATIC_VALUE",
          "matchDetails": [
            {
              "incomingRecordType": "STATIC_VALUE",
              "incomingMatchExpression": {
                "staticValueDetails": {
                  "staticValueType": "TEXT",
                  "text": "#(staticMatchValue)",
                  "number": "",
                  "exactDate": "",
                  "fromDate": "",
                  "toDate": ""
                },
                "dataValueType": "STATIC_VALUE"
              },
              "existingRecordType": "HOLDINGS",
              "existingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "holdingsrecord.permanentLocationId"
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
    * def holdingsMatchProfileId = $.id

    #  Create job profile - update holdings and items
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(jobProfileUpdateName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(holdingsMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(holdingsMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(updateHoldingsActionProfileId)",
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
    * def updateJobProfileId = $.id

    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/FAT-1124.mrc')
    * def updatedMarcRecord = javaDemo.replaceHrIdFieldInMarcFile(marcRecord, '1060180377', instanceHrid)

    * def jobProfileId = updateJobProfileId

    ## Upload marc file
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "size": 1,
          "name": "FAT-1124-UPDATED.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id
    * def HfileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request updatedMarcRecord
    When method post
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = false
    And headers headersUser
    And request read(samplePath + 'jobs/customJob.json')
    When method post
    Then status 204

    Given path 'change-manager/jobExecutions', jobExecutionId
    And headers headersUser
    And print response.status
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR' || response.status == 'DISCARDED'
    When method get
    Then status 200
    And def status = response.status
