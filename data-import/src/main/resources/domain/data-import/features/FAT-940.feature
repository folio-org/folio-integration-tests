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
    And request karate.readAsString('classpath:domain/data-import/samples/csv-files/FAT-940.csv')
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

    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaDemo.writeByteArrayToFile(response)

    * def randomNumber = callonce random

    * def uiKey = 'FAT-940-1.mrc' + randomNumber

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
"name": "FAT-940-1.mrc"
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
"name": "FAT-940: Job profile",
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