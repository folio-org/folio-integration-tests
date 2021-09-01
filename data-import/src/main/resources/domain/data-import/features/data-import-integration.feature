Feature: Data Import integration tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }


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
          "mappingFields": [{
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
					"subfields": [{
							"order": 0,
							"path": "instance.statisticalCodeIds[]",
							"fields": [{
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
				}]
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
			"mappingFields": [{
					"name": "holdingsTypeId",
					"enabled": "true",
					"path": "holdings.holdingsTypeId",
					"value": "\"Electronic\"",
					"subfields": [],
					"acceptedValues": {
						"996f93e2-5b5e-4cf2-9168-33ced1f95eed": "Electronic"
					}
				}, {
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
				}, {
					"name": "callNumberTypeId",
					"enabled": "true",
					"path": "holdings.callNumberTypeId",
					"value": "\"Library of Congress classification\"",
					"subfields": [],
					"acceptedValues": {
						"512173a7-bd09-490e-b773-17d83f2b63fe": "LC Modified",
						"95467209-6d7b-468b-94df-0f5d7ad2747d": "Library of Congress classification"
					}
				}, {
					"name": "callNumber",
					"enabled": "true",
					"path": "holdings.callNumber",
					"value": "050$a \" \" 050$b",
					"subfields": []
				}, {
					"name": "electronicAccess",
					"enabled": "true",
					"path": "holdings.electronicAccess[]",
					"value": "",
					"repeatableFieldAction": "EXTEND_EXISTING",
					"subfields": [{
							"order": 0,
							"path": "holdings.electronicAccess[]",
							"fields": [{
									"name": "relationshipId",
									"enabled": "true",
									"path": "holdings.electronicAccess[].relationshipId",
									"value": "\"Resource\"",
									"subfields": [],
									"acceptedValues": {
										"3b430592-2e09-4b48-9a0c-0636d66b9fb3": "Version of resource",
										"f5d0068e-6272-458e-8a81-b85e7b9a14aa": "Resource"
									}
								}, {
									"name": "uri",
									"enabled": "true",
									"path": "holdings.electronicAccess[].uri",
									"value": "856$u",
									"subfields": []
								}, {
									"name": "linkText",
									"enabled": "true",
									"path": "holdings.electronicAccess[].linkText",
									"value": "",
									"subfields": []
								}, {
									"name": "materialsSpecification",
									"enabled": "true",
									"path": "holdings.electronicAccess[].materialsSpecification",
									"value": "",
									"subfields": []
								}, {
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
              "mappingFields": [{
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
					"subfields": [{
							"order": 0,
							"path": "item.notes[]",
							"fields": [{
									"name": "itemNoteTypeId",
									"enabled": true,
									"path": "item.notes[].itemNoteTypeId",
									"value": "\"Electronic bookplate\"",
									"acceptedValues": {
										"0e40884c-3523-4c6d-8187-d578e3d2794e": "Action note",
										"f3ae3823-d096-4c65-8734-0c1efd2ffea8": "Electronic bookplate"
									}
								}, {
									"name": "note",
									"enabled": true,
									"path": "item.notes[].note",
									"value": "\"Smith Family Foundation\""
								}, {
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
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201

    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def uiKey = '1_record.mrc' + randomNumber

    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "uiKey": "#(uiKey)",
          "size": 2,
          "name": "1_record.mrc"
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

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read('classpath:domain/data-import/samples/1_record.mrc')
    When method post
    Then status 200
    And assert response.status == 'LOADED'


    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
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
        "name": "1_record.mrc",
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


       ## verify job execution for quick export
    * call pause 120000
    * call read('classpath:domain/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
     ##And assert jobExecution.progress.exported == 1
     ##And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
     ##* def hrId = '' + jobExecution.hrId
     ##And match jobExecution.exportedFiles[0].fileName contains hrId

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

  @Undefined
  Scenario: FAT-939 Modify MARC_Bib, update Instances, Holdings, and Items 1
    * print 'Match MARC-to-MARC, modify MARC_Bib and update Instance, Holdings, and Items'

  @Undefined
  Scenario: FAT-940 Match MARC-to-MARC and update Instances, Holdings, and Items 2
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

  @Undefined
  Scenario: FAT-941 Match MARC-to-MARC and update Instances, Holdings, and Items 3
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

  @Undefined
  Scenario: FAT-942 Match MARC-to-MARC and update Instances, Holdings, and Items 4
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

  @Undefined
  Scenario: FAT-943 Match MARC-to-MARC and update Instances, Holdings, and Items 5
    * print 'Match MARC-to-MARC and update Instance, Holdings, and Items'

  @Undefined
  Scenario: FAT-944 Match MARC-to-MARC and update Instances, fail to update Holdings and Items
    * print 'Match MARC-to-MARC and update Instance, fail to update Holdings and Items'

  @Undefined
  Scenario: FAT-945 Match MARC-to-MARC and update Instances, Holdings, fail to update Items
    * print 'Match MARC-to-MARC and update Instance, Holdings, fail to update Items'

