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

    * def randomNumber = callonce random

    * configure retry = { interval: 15000, count: 5 }

    * def javaDemo = Java.type('test.java.WriteData')

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
    And request karate.readAsString('classpath:domain/data-import/samples/FAT-939.csv')
    When method POST
    Then status 200
    And match $.status == 'COMPLETED'

    * def exportJobExecutionId = $.jobExecutionId
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

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

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response)

    * def uiKey = 'FAT-939-1.mrc' + randomNumber

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
          "name": "FAT-939-1.mrc"
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
#    And request read('target/FAT-939-1.mrc')
#    And request read('FAT-939-1.mrc')
#    And request read('classpath:domain/data-import/target/FAT-939-1.mrc')
#    And request read('classpath:domain/data-import/samples/mrc-files/FAT-937.mrc')
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
    * call read('classpath:domain/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(importJobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

