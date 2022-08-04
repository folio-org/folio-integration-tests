Feature: Test matching by POL number and vendor reference number

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure retry = { interval: 15000, count: 5 }

  Scenario: FAT-2184 Match on POL and update related Instance, Holdings, Item
    # Create organization
    Given path 'organizations-storage/organizations'
    And headers headersUser
    And request
    """
    {
      id: 'c6dace5d-4574-411e-8ba1-036102fcdc9b',
      name: 'GOBI Library Solutions"',
      code: 'GOBI',
      isVendor: true,
      status: 'Active'
    }
    """
    When method POST
    Then status 201

    # Create pending order
    Given path 'orders/composite-orders'
    And headers headersUser
    And request
    """
    {
      "vendor": "c6dace5d-4574-411e-8ba1-036102fcdc9b",
      "orderType": "One-Time",
      "poNumber": "FAT2184pref10000",
      "workflowStatus": "Pending",
      "reEncumber": true
    }
    """
    When method POST
    Then status 201
    * def createdOrder = response

    # Create PO line with title from 245$a field of 1-st record at the FAT-2184.mrc
    Given path 'orders/order-lines'
    And headers headersUser
    And request
    """
    {
      "titleOrPackage": "Agrarianism and capitalism in early Georgia, 1732-1743 / Jay Jordan Butler",
      "orderFormat": "Physical Resource",
      "purchaseOrderId": "#(createdOrder.id)",
      "source": "User",
      "cost": {
        "currency": "USD",
        "discountType": "percentage",
        "quantityPhysical": 1,
        "listUnitPrice": "20"
      },
      "details": {
        "productIds": [
          {
            "productIdType": "8261054f-be78-422d-bd51-4ed9f33c3422",
            "productId": "9780764354113",
            "qualifier": "(paperback)"
          }
        ]
      },
      "physical": {
        "createInventory": "Instance, Holding, Item",
        "materialType": "1a54b431-2e4f-452d-9cae-9cee66c9a892"
      },
      "locations": [
        {
          "locationId": "53cf956f-c1df-410b-8bea-27f712cca7c0",
          "quantityPhysical": 1
        }
      ],
      "acquisitionMethod": "306489dd-0053-49ee-a068-c316444a8f55",
      "isPackage": false,
      "checkinItems": false,
      "automaticExport": false
    }
    """
    When method POST
    Then status 201

    # Open pending order
    Given path 'orders/composite-orders', createdOrder.id
    And headers headersUser
    And set createdOrder.workflowStatus = 'Open'
    And request createdOrder
    When method PUT
    Then status 204

    # Create mapping profile for instance update
    # MARC-to-Instance (Changes cataloged date, changes instance status term)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: Update Instance by POL match",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "INSTANCE",
        "description": "FAT-2184: Update Instance by POL match",
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
              "value": "\"Cataloged\"",
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
    * def updateInstanceMappingProfileId = $.id

    # Create mapping profile for holdings update
    # MARC-to-Holdings (Changes holdings type, changes permanent location, changes call number and call number prefix)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: Update Holdings by POL match",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "FAT-2184: Update Holdings by POL match",
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
                "03c9c400-b9e3-4a07-ac0e-05ab470233ed": "Monograph"
              }
            },
            {
              "name": "permanentLocationId",
              "enabled": true,
              "path": "holdings.permanentLocationId",
              "value": "980$a",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)"
              }
            },
            {
              "name": "callNumberTypeId",
              "enabled": true,
              "path": "holdings.callNumberTypeId",
              "value": "\"Library of Congress classification\"",
              "subfields": [],
              "acceptedValues": {
                "512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
                "95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification"
              }
            },
            {
              "name": "callNumberPrefix",
              "enabled": true,
              "path": "holdings.callNumberPrefix",
              "value": "",
              "subfields": []
            },
            {
              "name": "callNumber",
              "enabled": true,
              "path": "holdings.callNumber",
              "value": "980$b \" \" 980$c",
              "subfields": []
            },
            {
              "name": "callNumberSuffix",
              "enabled": true,
              "path": "holdings.callNumberSuffix",
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
    * def updateHoldingsMappingProfileId = $.id

    # Create mapping profile for item update
    # MARC-to-Item (Changes barcode, changes copy number, changes status)
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: Update Item by POL match",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "ITEM",
        "description": "FAT-2184: Update Item by POL match",
        "mappingDetails": {
          "name": "item",
          "recordType": "ITEM",
          "mappingFields": [
            {
              "name": "barcode",
              "enabled": true,
              "path": "item.barcode",
              "value": "981$b",
              "subfields": []
            },
            {
              "name": "copyNumber",
              "enabled": true,
              "path": "item.copyNumber",
              "value": "981$a; else \"1\"",
              "subfields": []
            },
            {
              "name": "status.name",
              "enabled": true,
              "path": "item.status.name",
              "subfields": [],
              "value": "\"Available\""
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

    # Create action profile for instance update
    * def folioRecordNameAndDescription = 'FAT-2184: Update Instance by POL match'
    * def folioRecord = 'INSTANCE'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateInstanceActionProfileId = $.id

    # Create action profile for holdings update
    * def folioRecordNameAndDescription = 'FAT-2184: Update Holdings by POL match'
    * def folioRecord = 'HOLDINGS'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateHoldingsActionProfileId = $.id

    # Create action profile for item update
    * def folioRecordNameAndDescription = 'FAT-2184: Update Item by POL match'
    * def folioRecord = 'ITEM'
    * def profileAction = 'UPDATE'
    * def mappingProfileEntityId = updateItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateItemActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 935$a to purchaseOrderLineNumber
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: 935 $a POL to Instance POL",
        "description": "FAT-2184: 935 $a POL to Instance POL",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "935"
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
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "INSTANCE",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "instance.purchaseOrderLineNumber"
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

    # Create match profile for MARC-to-HOLDINGS 935$a to purchaseOrderLineNumber
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: 935 $a POL to Holdings POL",
        "description": "FAT-2184: 935 $a POL to Holdings POL",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "935"
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
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "HOLDINGS",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "holdingsrecord.purchaseOrderLineNumber"
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

    # Create match profile for MARC-to-ITEM 935$a to purchaseOrderLineNumber
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: 935 $a POL to Item POL",
        "description": "FAT-2184: 935 $a POL to Item POL",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "matchDetails": [
          {
            "incomingRecordType": "MARC_BIBLIOGRAPHIC",
            "incomingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "935"
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
              "staticValueDetails": null,
              "dataValueType": "VALUE_FROM_RECORD"
            },
            "existingRecordType": "ITEM",
            "existingMatchExpression": {
              "fields": [
                {
                  "label": "field",
                  "value": "item.purchaseOrderLineNumber"
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

    # Create job profile - Update Instance, Holdings, Item based on POL match
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
    """
    {
      "profile": {
        "name": "FAT-2184: Update Instance, Holdings, Item based on POL match",
        "description": "FAT-2184: Update Instance, Holdings, Item based on POL match",
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
          "detailProfileId": "#(updateInstanceActionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0,
          "reactTo": "MATCH"
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(holdingsMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 1
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
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(itemMatchProfileId)",
          "detailProfileType": "MATCH_PROFILE",
          "order": 2
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
    * def jobProfileId = $.id
    * def jobProfileName = $.profile.name

    # Create file definition for FAT-2184.mrc and upload the file
    * def randomNumber = callonce random
    * def fileName = 'FAT-2184.mrc'
    * def filePath = 'classpath:folijet/data-import/samples/mrc-files/' + fileName
    * def uiKey = fileName + randomNumber
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey: '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#(filePath)'}

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
            "name": "FAT-2184.mrc",
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
        "name": "#(jobProfileName)",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') {jobExecutionId: '#(jobExecutionId)'}
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
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].instanceActionStatus == 'UPDATED'
    And assert response.entries[0].holdingsActionStatus == 'UPDATED'
    And assert response.entries[0].itemActionStatus == 'UPDATED'
    And match response.entries[0].error == '#notpresent'
    And def updatedHoldingsHrid = response.entries[0].holdingsRecordHridList[0]

    # Verify updated holdings record
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'hrid==' + updatedHoldingsHrid
    And param limit = '1'
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.holdingsRecords[0].permanentLocationId == 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    And match response.holdingsRecords[0].holdingsTypeId == '03c9c400-b9e3-4a07-ac0e-05ab470233ed'
    And match response.holdingsRecords[0].callNumberTypeId == '95467209-6d7b-468b-94df-0f5d7ad2747d'
    And match response.holdingsRecords[0].callNumber == 'F289 .B87 2011'
    * def updatedHoldingsId = response.holdingsRecords[0].id
    * def updatedInstanceId = response.holdingsRecords[0].instanceId

    # Verify updated instance
    Given path 'inventory/instances', updatedInstanceId
    And headers headersUser
    When method GET
    Then status 200
    And match response.catalogedDate == '#present'
    And match response.statusId == '9634a5ab-9228-4703-baf2-4d12ebc77d56'

    # Verify updated item
    Given path '/inventory/items'
    And param query = 'holdingsRecordId==' + updatedHoldingsId
    And param limit = '1'
    And headers headersUser
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.items[0].barcode == '3782137819'
    And match response.items[0].status.name == 'Available'
    And match response.items[0].copyNumber == '1'
