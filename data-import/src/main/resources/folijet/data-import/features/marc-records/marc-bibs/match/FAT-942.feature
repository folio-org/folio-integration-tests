Feature: FAT-942

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')
    * configure retry = { interval: 5000, count: 30 }
    * def javaDemo = Java.type('test.java.WriteData')

  Scenario: FAT-942 Match MARC-to-MARC and update Instances, Holdings, and Items 4
    * print 'FAT-942 Match MARC-to-MARC and update Instance, Holdings, and Items'

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

    # Preparation: import instance, holding and item basing on FAT-937 scenario which is a precondition for FAT-942 scenario
    * print 'Preparation: import Instance, Holding, Item'
    * def result = call read(importHoldingFeature) { testIdentifier: "FAT-942" }
    * def instanceId = result.instanceId

    # Create job and mapping profiles for data export
    * def exportMappingProfileName = 'FAT-942 Mapping instance, holding, item for export'
    * def dataExportMappingProfile = read('classpath:folijet/data-import/samples/profiles/data-export-mapping-profile.json')
    * def result = call createExportMappingProfile { mappingProfile: "#(dataExportMappingProfile)" }
    * def exportJobProfileName = 'FAT-942 Data export job profile'
    * def result = call createExportJobProfile { jobProfileName: "#(exportJobProfileName)", dataExportMappingProfileId: "#(result.dataExportMappingProfileId)" }
    * def dataExportJobProfileId = result.dataExportJobProfileId

    # Export MARC record by instance id
    * def fileName = 'FAT-942-1.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(dataExportJobProfileId)", fileName: "#(fileName)" }
    * javaDemo.writeByteArrayToFile(result.exportedBinaryMarcRecord, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-942-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read(commonImportFeature) {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'file:FAT-942-1.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath
    * url baseUrl

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And request
      """
      {
        "uploadDefinition": "#(result.uploadDefinition)",
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
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
    * def importJobExecutionId = jobExecution.id

    # Verify that needed entities updated
    Given path 'metadata-provider/jobLogEntries', importJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null && karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedItemInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'UPDATED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'UPDATED'
    And assert response.entries[0].relatedHoldingsInfo[0].actionStatus == 'UPDATED'
    And assert response.entries[0].relatedItemInfo[0].actionStatus == 'UPDATED'
    And match response.entries[0].error == ''
