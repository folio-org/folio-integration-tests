Feature: Import EDIFACT invoice

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

  Scenario: EDI invoice import

    # Create mapping profile for Invoice
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-968 - GOBI monograph invoice",
        "description": "",
        "incomingRecordType": "EDIFACT_INVOICE",
        "existingRecordType": "INVOICE",
        "deleted": false,
        "marcFieldProtectionSettings": [],
        "mappingDetails": {
          "name": "invoice",
          "recordType": "INVOICE",
          "mappingFields": [
            {
              "name": "invoiceDate",
              "enabled": "true",
              "path": "invoice.invoiceDate",
              "value": "DTM+137[2]",
              "subfields": []
            },
            {
              "name": "status",
              "enabled": "true",
              "path": "invoice.status",
              "value": "\"Open\"",
              "subfields": []
            },
            {
              "name": "paymentDue",
              "enabled": "true",
              "path": "invoice.paymentDue",
              "value": "",
              "subfields": []
            },
            {
              "name": "paymentTerms",
              "enabled": "true",
              "path": "invoice.paymentTerms",
              "value": "",
              "subfields": []
            },
            {
              "name": "approvalDate",
              "enabled": "false",
              "path": "invoice.approvalDate",
              "value": "",
              "subfields": []
            },
            {
              "name": "approvedBy",
              "enabled": "false",
              "path": "invoice.approvedBy",
              "value": "",
              "subfields": []
            },
            {
              "name": "acqUnitIds",
              "enabled": "true",
              "path": "invoice.acqUnitIds[]",
              "value": "",
              "subfields": [
                {
                  "order": 0,
                  "path": "invoice.acqUnitIds[]",
                  "fields": [
                    {
                      "name": "acqUnitIds",
                      "enabled": "true",
                      "path": "invoice.acqUnitIds[]",
                      "value": "",
                      "subfields": []
                    }
                  ]
                }
              ],
              "acceptedValues": {
                "0ebb1f7d-983f-3026-8a4c-5318e0ebc041": "main",
                "c267c23f-7407-407a-9c8a-542af3fef49a": "test",
                "192930c6-daa6-431b-9a36-c7b854b37166": "a",
                "73c766d1-ccc3-44e3-a10a-1a2a9a2544b6": "z",
                "e6075774-5108-4503-86ff-ed8259ab4fa5": "bb"
              }
            },
            {
              "name": "billTo",
              "enabled": "true",
              "path": "invoice.billTo",
              "value": "",
              "subfields": [],
              "acceptedValues": {}
            },
            {
              "name": "billToAddress",
              "enabled": "false",
              "path": "invoice.billToAddress",
              "value": "",
              "subfields": []
            },
            {
              "name": "batchGroupId",
              "enabled": "true",
              "path": "invoice.batchGroupId",
              "value": "\"FOLIO\"",
              "subfields": [],
              "acceptedValues": {
                "2a2cb998-1437-41d1-88ad-01930aaeadd5": "FOLIO",
                "cd592659-77aa-4eb3-ac34-c9a4657bb20f": "Amherst (AC)"
              }
            },
            {
              "name": "subTotal",
              "enabled": "false",
              "path": "invoice.subTotal",
              "value": "",
              "subfields": []
            },
            {
              "name": "adjustmentsTotal",
              "enabled": "false",
              "path": "invoice.adjustmentsTotal",
              "value": "",
              "subfields": []
            },
            {
              "name": "total",
              "enabled": "false",
              "path": "invoice.total",
              "value": "",
              "subfields": []
            },
            {
              "name": "lockTotal",
              "enabled": "true",
              "path": "invoice.lockTotal",
              "value": "MOA+86[2]",
              "subfields": []
            },
            {
              "name": "note",
              "enabled": "true",
              "path": "invoice.note",
              "value": "",
              "subfields": []
            },
            {
              "name": "adjustments",
              "enabled": "true",
              "path": "invoice.adjustments[]",
              "value": "",
              "subfields": []
            },
            {
              "name": "vendorInvoiceNo",
              "enabled": "true",
              "path": "invoice.vendorInvoiceNo",
              "value": "BGM+380+[1]",
              "subfields": []
            },
            {
              "name": "vendorId",
              "enabled": "true",
              "path": "invoice.vendorId",
              "value": "\"d0fb5aa0-cdf1-11e8-a8d5-f2801f1b9fd1\"",
              "subfields": []
            },
            {
              "name": "accountingCode",
              "enabled": true,
              "path": "invoice.accountingCode",
              "value": "\"G64758-74836\"",
              "subfields": []
            },
            {
              "name": "folioInvoiceNo",
              "enabled": "false",
              "path": "invoice.folioInvoiceNo",
              "value": "",
              "subfields": []
            },
            {
              "name": "paymentMethod",
              "enabled": "true",
              "path": "invoice.paymentMethod",
              "value": "\"Credit Card\"",
              "subfields": []
            },
            {
              "name": "chkSubscriptionOverlap",
              "enabled": "true",
              "path": "invoice.chkSubscriptionOverlap",
              "booleanFieldAction": "ALL_FALSE",
              "subfields": []
            },
            {
              "name": "exportToAccounting",
              "enabled": "true",
              "path": "invoice.exportToAccounting",
              "booleanFieldAction": "ALL_TRUE",
              "subfields": []
            },
            {
              "name": "currency",
              "enabled": "true",
              "path": "invoice.currency",
              "value": "CUX+2[2]",
              "subfields": []
            },
            {
              "name": "currentExchangeRate",
              "enabled": "false",
              "path": "invoice.currentExchangeRate",
              "value": "",
              "subfields": []
            },
            {
              "name": "exchangeRate",
              "enabled": "true",
              "path": "invoice.exchangeRate",
              "value": "",
              "subfields": []
            },
            {
              "name": "invoiceLines",
              "enabled": "true",
              "path": "invoice.invoiceLines[]",
              "value": "",
              "repeatableFieldAction": "EXTEND_EXISTING",
              "subfields": [
                {
                  "order": 0,
                  "path": "invoice.invoiceLines[]",
                  "fields": [
                    {
                      "name": "description",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].description",
                      "value": "{POL_title}; else IMD+L+050+[4-5]",
                      "subfields": []
                    },
                    {
                      "name": "poLineId",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].poLineId",
                      "value": "RFF+LI[2]",
                      "subfields": []
                    },
                    {
                      "name": "invoiceLineNumber",
                      "enabled": "false",
                      "path": "invoice.invoiceLines[].invoiceLineNumber",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "invoiceLineStatus",
                      "enabled": "false",
                      "path": "invoice.invoiceLines[].invoiceLineStatus",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "referenceNumbers",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].referenceNumbers[]",
                      "value": "",
                      "repeatableFieldAction": "EXTEND_EXISTING",
                      "subfields": [
                        {
                          "order": 0,
                          "path": "invoice.invoiceLines[].referenceNumbers[]",
                          "fields": [
                            {
                              "name": "refNumber",
                              "enabled": "true",
                              "path": "invoice.invoiceLines[].referenceNumbers[].refNumber",
                              "value": "RFF+SLI[2]",
                              "subfields": []
                            },
                            {
                              "name": "refNumberType",
                              "enabled": "true",
                              "path": "invoice.invoiceLines[].referenceNumbers[].refNumberType",
                              "value": "\"Vendor order reference number\"",
                              "subfields": []
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "name": "subscriptionInfo",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].subscriptionInfo",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "subscriptionStart",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].subscriptionStart",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "subscriptionEnd",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].subscriptionEnd",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "comment",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].comment",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "lineAccountingCode",
                      "enabled": "false",
                      "path": "invoice.invoiceLines[].accountingCode",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "accountNumber",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].accountNumber",
                      "value": "",
                      "subfields": []
                    },
                    {
                      "name": "quantity",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].quantity",
                      "value": "QTY+47[2]",
                      "subfields": []
                    },
                    {
                      "name": "lineSubTotal",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].subTotal",
                      "value": "MOA+203[2]",
                      "subfields": []
                    },
                    {
                      "name": "releaseEncumbrance",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].releaseEncumbrance",
                      "booleanFieldAction": "ALL_TRUE",
                      "subfields": []
                    },
                    {
                      "name": "fundDistributions",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].fundDistributions[]",
                      "value": "{POL_FUND_DISTRIBUTIONS}",
                      "subfields": []
                    },
                    {
                      "name": "lineAdjustments",
                      "enabled": "true",
                      "path": "invoice.invoiceLines[].adjustments[]",
                      "value": "",
                      "subfields": []
                    }
                  ]
                }
              ]
            }
          ],
          "marcMappingDetails": []
        }
      },
      "addedRelations": [],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    # Create action profile for Invoice
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-968 - GOBI monograph invoice",
        "description": "",
        "action": "CREATE",
        "folioRecord": "INVOICE"
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

    * def actionProfileId = $.id

    # Create job profile for Invoice
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-968 - GOBI monograph invoice",
        "description": "",
        "dataType": "EDIFACT"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def uiKey = 'FAT-968.edi' + randomNumber

    # Create file definition for FAT-968.edi-file
    Given path 'data-import/uploadDefinitions'
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 14,
          "name": "FAT-968.edi"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = $.fileDefinitions[0].uploadDefinitionId
    * def fileId = $.fileDefinitions[0].id
    * def jobExecutionId = $.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = $.metaJobExecutionId
    * def createDate = $.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    # Upload edi-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And configure headers = headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/edi-files/FAT-968.edi')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    # Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And configure headers = headersUser
    When method GET
    Then status 200
    * def sourcePath = $.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And param defaultMapping = 'false'
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
            "name": "FAT-968.edi",
            "status": "UPLOADED",
            "jobExecutionId": "#(jobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 5,
            "uiKey": "#(uiKey)"
          }
        ],
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "FAT-968 - GOBI monograph invoice",
        "dataType": "EDIFACT"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = $
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 15000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].invoiceActionStatus == 'CREATED'
    And match response.entries[0].sourceRecordOrder == '#present'

  Scenario: FAT-1140 Import EDIFACT file with multiple fields mapping into 1 invoice field with space

    # Create mapping profile for Invoice
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
    {
        "profile": {
            "name": "FAT-1140 - Harrassowitz invoice with space",
            "incomingRecordType": "EDIFACT_INVOICE",
            "existingRecordType": "INVOICE",
            "deleted": false,
            "mappingDetails": {
                "name": "invoice",
                "recordType": "INVOICE",
                "mappingFields": [
                    {
                        "name": "invoiceDate",
                        "enabled": "true",
                        "path": "invoice.invoiceDate",
                        "value": "DTM+137[2]",
                        "subfields": []
                    },
                    {
                        "name": "status",
                        "enabled": "true",
                        "path": "invoice.status",
                        "value": "\"Open\"",
                        "subfields": []
                    },
                    {
                        "name": "batchGroupId",
                        "enabled": "true",
                        "path": "invoice.batchGroupId",
                        "value": "\"FOLIO\"",
                        "subfields": [],
                        "acceptedValues": {
                            "2a2cb998-1437-41d1-88ad-01930aaeadd5": "FOLIO"
                        }
                    },
                    {
                        "name": "lockTotal",
                        "enabled": "true",
                        "path": "invoice.lockTotal",
                        "value": "MOA+9[2]",
                        "subfields": []
                    },
                    {
                        "name": "note",
                        "enabled": "true",
                        "path": "invoice.note",
                        "value": "RFF+API[2] \" \" NAD+SU+++[1]",
                        "subfields": []
                    },
                    {
                        "name": "vendorInvoiceNo",
                        "enabled": "true",
                        "path": "invoice.vendorInvoiceNo",
                        "value": "BGM+380+[1]",
                        "subfields": []
                    },
                    {
                        "name": "vendorId",
                        "enabled": "true",
                        "path": "invoice.vendorId",
                        "value": "\"c0fb5956-cdf1-11e8-a8d5-f2801f1b9fd1\"",
                        "subfields": []
                    },
                    {
                        "name": "accountingCode",
                        "enabled": "true",
                        "path": "invoice.accountingCode",
                        "value": "\"G64758-74835\"",
                        "subfields": []
                    },
                    {
                        "name": "paymentMethod",
                        "enabled": "true",
                        "path": "invoice.paymentMethod",
                        "value": "\"Credit Card\"",
                        "subfields": []
                    },
                    {
                        "name": "chkSubscriptionOverlap",
                        "enabled": "true",
                        "path": "invoice.chkSubscriptionOverlap",
                        "booleanFieldAction": "ALL_FALSE",
                        "subfields": []
                    },
                    {
                        "name": "exportToAccounting",
                        "enabled": "true",
                        "path": "invoice.exportToAccounting",
                        "booleanFieldAction": "ALL_TRUE",
                        "subfields": []
                    },
                    {
                        "name": "currency",
                        "enabled": "true",
                        "path": "invoice.currency",
                        "value": "\"USD\"",
                        "subfields": []
                    },
                    {
                        "name": "invoiceLines",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[]",
                        "value": "",
                        "repeatableFieldAction": "EXTEND_EXISTING",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "invoice.invoiceLines[]",
                                "fields": [
                                    {
                                        "name": "description",
                                       "enabled": "true",
                                        "path": "invoice.invoiceLines[].description",
                                        "value": "{POL_title}; else IMD+L+050+[4-5]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "poLineId",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].poLineId",
                                        "value": "RFF+LI[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "referenceNumbers",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].referenceNumbers[]",
                                        "value": "",
                                        "repeatableFieldAction": "EXTEND_EXISTING",
                                        "subfields": [
                                            {
                                                "order": 0,
                                                "path": "invoice.invoiceLines[].referenceNumbers[]",
                                                "fields": [
                                                    {
                                                        "name": "refNumber",
                                                        "enabled": "true",
                                                        "path": "invoice.invoiceLines[].referenceNumbers[].refNumber",
                                                        "value": "RFF+SNA[2]",
                                                        "subfields": []
                                                    },
                                                    {
                                                        "name": "refNumberType",
                                                        "enabled": "true",
                                                        "path": "invoice.invoiceLines[].referenceNumbers[].refNumberType",
                                                        "value": "\"Vendor order reference number\"",
                                                        "subfields": []
                                                    }
                                                ]
                                            }
                                        ]
                                    },
                                    {
                                        "name": "subscriptionInfo",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].subscriptionInfo",
                                        "value": "IMD+L+085+[4-5] \" \" IMD+L+086+[4-5]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "subscriptionStart",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].subscriptionStart",
                                        "value": "DTM+194[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "subscriptionEnd",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].subscriptionEnd",
                                        "value": "DTM+206[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "comment",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].comment",
                                        "value": "IMD+L+085+[4-5] \" \" IMD+L+086+[4-5]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "quantity",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].quantity",
                                        "value": "QTY+47[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "lineSubTotal",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].subTotal",
                                        "value": "MOA+203[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "releaseEncumbrance",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].releaseEncumbrance",
                                        "booleanFieldAction": "ALL_TRUE",
                                        "subfields": []
                                    },
                                    {
                                        "name": "fundDistributions",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].fundDistributions[]",
                                        "value": "{POL_FUND_DISTRIBUTIONS}",
                                        "subfields": []
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        }
    }
    """
    When method POST
    Then status 201

    * def mappingProfileId = $.id

    # Create action profile for Invoice
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-1140 - Harrassowitz invoice with space",
        "description": "",
        "action": "CREATE",
        "folioRecord": "INVOICE"
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

    * def actionProfileId = $.id

    # Create job profile for Invoice
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-1140 - Harrassowitz invoice with space",
        "description": "",
        "dataType": "EDIFACT"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def uiKey = 'FAT-1140.edi' + randomNumber

    # Create file definition for FAT-968.edi-file
    Given path 'data-import/uploadDefinitions'
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 3,
          "name": "FAT-1140.edi"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = $.fileDefinitions[0].uploadDefinitionId
    * def fileId = $.fileDefinitions[0].id
    * def jobExecutionId = $.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = $.metaJobExecutionId
    * def createDate = $.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    # Upload edi-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And configure headers = headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/edi-files/FAT-1140.edi')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    # Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And configure headers = headersUser
    When method GET
    Then status 200
    * def sourcePath = $.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And param defaultMapping = 'false'
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
            "name": "FAT-1140.edi",
            "status": "UPLOADED",
            "jobExecutionId": "#(jobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 3,
            "uiKey": "#(uiKey)"
          }
        ],
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "FAT-1140 - Harrassowitz invoice with space",
        "dataType": "EDIFACT"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = $
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 15000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].invoiceActionStatus == 'CREATED'
    And match response.entries[0].sourceRecordOrder == '#present'
    * def invoiceLineJournalRecordId = $.entries[0].invoiceLineJournalRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', invoiceLineJournalRecordId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.sourceRecordOrder == 0
    And assert response.sourceRecordActionStatus == 'CREATED'
    And assert response.relatedInvoiceInfo.actionStatus == 'CREATED'
    And assert response.relatedInvoiceLineInfo.actionStatus == 'CREATED'
    * def invoiceId = $.relatedInvoiceInfo.idList[0]

    Given path 'invoice-storage/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.note == 'HARRAS0001118 OTTO HARRASSOWITZ'

    # find the specific invoice line to assert its subscriptionInfo and comment
    Given path 'invoice-storage/invoice-lines'
    And headers headersUser
    And param query = 'invoiceId==' + invoiceId + ' and description == "Allgemeine Forst Zeitschrift AFZ. Der Wald"'
    When method GET
    Then status 200
    And assert response.invoiceLines[0].subscriptionInfo == '01.Jan.2021 iss.1 31.Dec.2021 iss.24'
    And assert response.invoiceLines[0].comment == '01.Jan.2021 iss.1 31.Dec.2021 iss.24'

  Scenario: FAT-1141 Import EDIFACT file with multiple fields mapping into 1 invoice field with hyphen

    # Create mapping profile for Invoice
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
    {
        "profile": {
            "name": "FAT-1141 - Harrassowitz invoice with hyphen",
            "incomingRecordType": "EDIFACT_INVOICE",
            "existingRecordType": "INVOICE",
            "deleted": false,
            "mappingDetails": {
                "name": "invoice",
                "recordType": "INVOICE",
                "mappingFields": [
                    {
                        "name": "invoiceDate",
                        "enabled": "true",
                        "path": "invoice.invoiceDate",
                        "value": "DTM+137[2]",
                        "subfields": []
                    },
                    {
                        "name": "status",
                        "enabled": "true",
                        "path": "invoice.status",
                        "value": "\"Open\"",
                        "subfields": []
                    },
                    {
                        "name": "batchGroupId",
                        "enabled": "true",
                        "path": "invoice.batchGroupId",
                        "value": "\"FOLIO\"",
                        "subfields": [],
                        "acceptedValues": {
                            "2a2cb998-1437-41d1-88ad-01930aaeadd5": "FOLIO"
                        }
                    },
                    {
                        "name": "note",
                        "enabled": "true",
                        "path": "invoice.note",
                        "value": "RFF+API[2] \"-\" NAD+SU+++[1]",
                        "subfields": []
                    },
                    {
                        "name": "vendorInvoiceNo",
                        "enabled": "true",
                        "path": "invoice.vendorInvoiceNo",
                        "value": "BGM+380+[1]",
                        "subfields": []
                    },
                    {
                        "name": "vendorId",
                        "enabled": "true",
                        "path": "invoice.vendorId",
                        "value": "\"c0fb5956-cdf1-11e8-a8d5-f2801f1b9fd1\"",
                        "subfields": []
                    },
                    {
                        "name": "accountingCode",
                        "enabled": "true",
                        "path": "invoice.accountingCode",
                        "value": "\"G64758-74835\"",
                        "subfields": []
                    },
                    {
                        "name": "paymentMethod",
                        "enabled": "true",
                        "path": "invoice.paymentMethod",
                        "value": "\"Credit Card\"",
                        "subfields": []
                    },
                    {
                        "name": "chkSubscriptionOverlap",
                        "enabled": "true",
                        "path": "invoice.chkSubscriptionOverlap",
                        "booleanFieldAction": "ALL_FALSE",
                        "subfields": []
                    },
                    {
                        "name": "exportToAccounting",
                        "enabled": "true",
                        "path": "invoice.exportToAccounting",
                        "booleanFieldAction": "ALL_FALSE",
                        "subfields": []
                    },
                    {
                        "name": "currency",
                        "enabled": "true",
                        "path": "invoice.currency",
                        "value": "\"USD\"",
                        "subfields": []
                    },
                    {
                        "name": "invoiceLines",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[]",
                        "value": "",
                        "repeatableFieldAction": "EXTEND_EXISTING",
                        "subfields": [
                            {
                                "order": 0,
                                "path": "invoice.invoiceLines[]",
                                "fields": [
                                    {
                                        "name": "description",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].description",
                                        "value": "{POL_title}; else IMD+L+050+[4-5]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "subscriptionInfo",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].subscriptionInfo",
                                        "value": "IMD+L+085+[4-5] \"-\" IMD+L+086+[4-5]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "comment",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].comment",
                                        "value": "IMD+L+085+[4-5] \"-\" IMD+L+086+[4-5]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "quantity",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].quantity",
                                        "value": "QTY+47[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "lineSubTotal",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].subTotal",
                                        "value": "MOA+203[2]",
                                        "subfields": []
                                    },
                                    {
                                        "name": "releaseEncumbrance",
                                        "enabled": "true",
                                        "path": "invoice.invoiceLines[].releaseEncumbrance",
                                        "booleanFieldAction": "ALL_FALSE",
                                        "subfields": []
                                    }
                                ]
                            }
                        ]
                    }
                ]
            },
            "hidden": false
        }
    }
    """
    When method POST
    Then status 201
    * def mappingProfileId = $.id

    # Create action profile for Invoice
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-1141 - Harrassowitz invoice with hyphen",
        "description": "",
        "action": "CREATE",
        "folioRecord": "INVOICE"
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
    * def actionProfileId = $.id

    # Create job profile for Invoice
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-1141 - Harrassowitz invoice with hyphen",
        "description": "",
        "dataType": "EDIFACT"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def uiKey = 'FAT-1141.edi' + randomNumber

    # Create file definition for FAT-1141.edi-file
    Given path 'data-import/uploadDefinitions'
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 3,
          "name": "FAT-1141.edi"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = $.fileDefinitions[0].uploadDefinitionId
    * def fileId = $.fileDefinitions[0].id
    * def jobExecutionId = $.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = $.metaJobExecutionId
    * def createDate = $.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    # Upload edi-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And configure headers = headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/edi-files/FAT-1141.edi')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    # Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And configure headers = headersUser
    When method GET
    Then status 200

    * def sourcePath = $.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And param defaultMapping = 'false'
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
            "name": "FAT-1141.edi",
            "status": "UPLOADED",
            "jobExecutionId": "#(jobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 3,
            "uiKey": "#(uiKey)"
          }
        ],
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "FAT-1141 - Harrassowitz invoice with hyphen",
        "dataType": "EDIFACT"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = $
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 15000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].invoiceActionStatus == 'CREATED'
    And match response.entries[0].sourceRecordOrder == '#present'
    * def invoiceLineJournalRecordId = $.entries[0].invoiceLineJournalRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', invoiceLineJournalRecordId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.sourceRecordOrder == 0
    And assert response.sourceRecordActionStatus == 'CREATED'
    And assert response.relatedInvoiceInfo.actionStatus == 'CREATED'
    And assert response.relatedInvoiceLineInfo.actionStatus == 'CREATED'
    * def invoiceId = $.relatedInvoiceInfo.idList[0]

    Given path 'invoice-storage/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.note == 'HARRAS0001118-OTTO HARRASSOWITZ'

    # find the specific invoice line to assert its subscriptionInfo and comment
    Given path 'invoice-storage/invoice-lines'
    And headers headersUser
    And param query = 'invoiceId==' + invoiceId + ' and description == "Allgemeine Forst Zeitschrift AFZ. Der Wald"'
    When method GET
    Then status 200
    And assert response.invoiceLines[0].subscriptionInfo == '01.Jan.2021 iss.1-31.Dec.2021 iss.24'
    And assert response.invoiceLines[0].comment == '01.Jan.2021 iss.1-31.Dec.2021 iss.24'

  Scenario: FAT-1470 Import of invoices with acquisitions unit
    * def acqUnitId = '39c0a363-55a9-41e7-9dd4-bb550d41f0f7'

    Given path '/acquisitions-units-storage/units'
    And request
    """
        {
          id: '#(acqUnitId)',
          name: 'main',
          isDeleted: false,
          protectCreate: true,
          protectRead: true,
          protectUpdate: true,
          protectDelete: true
        }
    """
    When method POST
    Then status 201

    Given path 'acquisitions-units-storage/memberships'
    And headers headersAdmin
    And request
    """
    {
      "userId": "00000000-1111-5555-9999-999999999992",
      "acquisitionsUnitId": "#(acqUnitId)"
    }
    """
    When method POST
    Then status 201

    # Create mapping profile for Invoice
    Given path 'data-import-profiles/mappingProfiles'
    And request
    """
      {
        "profile": {
          "name": "FAT-1470 - GOBI invoice - Acq Units",
          "description": "",
          "incomingRecordType": "EDIFACT_INVOICE",
          "existingRecordType": "INVOICE",
          "deleted": false,
          "marcFieldProtectionSettings": [],
          "mappingDetails": {
            "name": "invoice",
            "recordType": "INVOICE",
            "marcMappingDetails": [],
            "mappingFields": [
              {
                "name": "invoiceDate",
                "enabled": true,
                "path": "invoice.invoiceDate",
                "value": "DTM+137[2]",
                "subfields": []
              },
              {
                "name": "status",
                "enabled": true,
                "path": "invoice.status",
                "value": "\"Open\"",
                "subfields": []
              },
              {
                "name": "acqUnitIds",
                "enabled": true,
                "path": "invoice.acqUnitIds[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "invoice.acqUnitIds[]",
                    "fields": [
                      {
                        "name": "acqUnitIds",
                        "enabled": "true",
                        "path": "invoice.acqUnitIds[]",
                        "value": "\"main\"",
                        "subfields": []
                      }
                    ]
                  }
                ],
                "acceptedValues": {
                 "39c0a363-55a9-41e7-9dd4-bb550d41f0f7": "main"
                }
              },
              {
                "name": "batchGroupId",
                "enabled": true,
                "path": "invoice.batchGroupId",
                "value": "\"FOLIO\"",
                "subfields": [],
                "acceptedValues": {
                  "cd592659-77aa-4eb3-ac34-c9a4657bb20f": "Amherst (AC)",
                  "2a2cb998-1437-41d1-88ad-01930aaeadd5": "FOLIO",
                  "ccf9470b-a41a-4db7-bd54-3515316d57c6": "tst-batch-group-1663666397"
                }
              },
              {
                "name": "lockTotal",
                "enabled": true,
                "path": "invoice.lockTotal",
                "value": "MOA+86[2]",
                "subfields": []
              },
              {
                "name": "vendorInvoiceNo",
                "enabled": true,
                "path": "invoice.vendorInvoiceNo",
                "value": "BGM+380+[1]",
                "subfields": []
              },
              {
                "name": "vendorId",
                "enabled": true,
                "path": "invoice.vendorId",
                "value": "\"d0fb5aa0-cdf1-11e8-a8d5-f2801f1b9fd1\"",
                "subfields": []
              },
              {
                "name": "accountingCode",
                "enabled": true,
                "path": "invoice.accountingCode",
                "value": "\"G64758-74836\"",
                "subfields": []
              },
              {
                "name": "paymentMethod",
                "enabled": true,
                "path": "invoice.paymentMethod",
                "value": "\"Cash\"",
                "subfields": []
              },
              {
                "name": "chkSubscriptionOverlap",
                "enabled": true,
                "path": "invoice.chkSubscriptionOverlap",
                "booleanFieldAction": "ALL_FALSE",
                "subfields": []
              },
              {
                "name": "exportToAccounting",
                "enabled": true,
                "path": "invoice.exportToAccounting",
                "booleanFieldAction": "ALL_TRUE",
                "subfields": []
              },
              {
                "name": "currency",
                "enabled": true,
                "path": "invoice.currency",
                "value": "CUX+2[2]",
                "subfields": []
              },
              {
                "name": "invoiceLines",
                "enabled": true,
                "path": "invoice.invoiceLines[]",
                "value": "",
                "repeatableFieldAction": "EXTEND_EXISTING",
                "subfields": [
                  {
                    "order": 0,
                    "path": "invoice.invoiceLines[]",
                    "fields": [
                      {
                        "name": "description",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].description",
                        "value": "{POL_title}; else IMD+L+050+[4-5]",
                        "subfields": []
                      },
                      {
                        "name": "poLineId",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].poLineId",
                        "value": "RFF+LI[2]",
                        "subfields": []
                      },
                      {
                        "name": "invoiceLineNumber",
                        "enabled": "false",
                        "path": "invoice.invoiceLines[].invoiceLineNumber",
                        "value": "",
                        "subfields": []
                      },
                      {
                        "name": "invoiceLineStatus",
                        "enabled": "false",
                        "path": "invoice.invoiceLines[].invoiceLineStatus",
                        "value": "",
                        "subfields": []
                      },
                      {
                        "name": "referenceNumbers",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].referenceNumbers[]",
                        "value": "",
                        "repeatableFieldAction": "EXTEND_EXISTING",
                        "subfields": [
                          {
                            "order": 0,
                            "path": "invoice.invoiceLines[].referenceNumbers[]",
                            "fields": [
                              {
                                "name": "refNumber",
                                "enabled": "true",
                                "path": "invoice.invoiceLines[].referenceNumbers[].refNumber",
                                "value": "RFF+SLI[2]",
                                "subfields": []
                              },
                              {
                                "name": "refNumberType",
                                "enabled": "true",
                                "path": "invoice.invoiceLines[].referenceNumbers[].refNumberType",
                                "value": "\"Vendor order reference number\"",
                                "subfields": []
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "name": "quantity",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].quantity",
                        "value": "QTY+47[2]",
                        "subfields": []
                      },
                      {
                        "name": "lineSubTotal",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].subTotal",
                        "value": "MOA+203[2]",
                        "subfields": []
                      },
                      {
                        "name": "releaseEncumbrance",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].releaseEncumbrance",
                        "booleanFieldAction": "ALL_TRUE",
                        "subfields": []
                      },
                      {
                        "name": "fundDistributions",
                        "enabled": "true",
                        "path": "invoice.invoiceLines[].fundDistributions[]",
                        "value": "{POL_FUND_DISTRIBUTIONS}",
                        "subfields": []
                      }
                    ]
                  }
                ]
              }
            ]
          },
          "hidden": false
        },
        "addedRelations": [],
        "deletedRelations": []
      }
    """
    When method POST
    Then status 201
    * def mappingProfileId = $.id

    # Create action profile for Invoice
    Given path 'data-import-profiles/actionProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-1470 - GOBI invoice - Acq Units",
        "description": "",
        "action": "CREATE",
        "folioRecord": "INVOICE"
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
    * def actionProfileId = $.id

    # Create job profile for Invoice
    Given path 'data-import-profiles/jobProfiles'
    And request
    """
    {
      "profile": {
        "name": "FAT-1470 - Acq Units",
        "description": "",
        "dataType": "EDIFACT"
      },
      "addedRelations": [
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 0
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def uiKey = 'FAT-1470.edi' + randomNumber

    # Create file definition for FAT-1470.edi-file
    Given path 'data-import/uploadDefinitions'
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 3,
          "name": "FAT-1470.edi"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = $.fileDefinitions[0].uploadDefinitionId
    * def fileId = $.fileDefinitions[0].id
    * def jobExecutionId = $.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = $.metaJobExecutionId
    * def createDate = $.fileDefinitions[0].createDate
    * def uploadedDate = createDate

    # Upload edi-file
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And configure headers = headersUserOctetStream
    And request read('classpath:folijet/data-import/samples/edi-files/FAT-1470.edi')
    When method POST
    Then status 200
    And assert response.status == 'LOADED'

    # Verify upload definition
    * call pause 5000
    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And configure headers = headersUser
    When method GET
    Then status 200

    * def sourcePath = $.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And param defaultMapping = 'false'
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
            "name": "FAT-1470.edi",
            "status": "UPLOADED",
            "jobExecutionId": "#(jobExecutionId)",
            "uploadDefinitionId": "#(uploadDefinitionId)",
            "createDate": "#(createDate)",
            "uploadedDate": "#(uploadedDate)",
            "size": 3,
            "uiKey": "#(uiKey)"
          }
        ],
      },
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "FAT-1470 - GOBI invoice - Acq Units",
        "dataType": "EDIFACT"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = $
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 15000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 18
    And match each response.entries..invoiceActionStatus == 'CREATED'
    And match response.entries[0].sourceRecordOrder == '#present'
    * def invoiceLineJournalRecordId = $.entries[0].invoiceLineJournalRecordId

    Given path 'metadata-provider/jobLogEntries', jobExecutionId, 'records', invoiceLineJournalRecordId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.sourceRecordActionStatus == 'CREATED'
    And assert response.relatedInvoiceInfo.actionStatus == 'CREATED'
    And assert response.relatedInvoiceLineInfo.actionStatus == 'CREATED'
    * def invoiceId = $.relatedInvoiceInfo.idList[0]

    # Verify that Acquisitions Unit assigned
    Given path 'invoice-storage/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.acqUnitIds[0] == acqUnitId
