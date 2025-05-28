Feature: FAT-1204

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

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
    Given def result = call read(utilFeature+'@ImportRecord') { fileName:'FAT-1204', jobName:'customJob' }
    Then match result.status != 'ERROR'
    * def jobExecutionId = result.jobExecutionId

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
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null && karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[*].sourceRecordActionStatus == ["CREATED","CREATED","CREATED","CREATED","CREATED","CREATED"]
    And match response.entries[*].relatedInstanceInfo.actionStatus == ["CREATED","CREATED","CREATED","CREATED","CREATED","CREATED"]
    And match response.entries[*].relatedHoldingsInfo[0].actionStatus == ["CREATED","CREATED","CREATED","CREATED","CREATED","CREATED"]

    # Import file and update instance, holdings, item
    * def jobProfileId = updateJobProfileId
    Given def result = call read(utilFeature+'@ImportRecord') { fileName:'FAT-1204-UPDATED', jobName:'customJob' }
    Then match result.status != 'ERROR'
    * def jobExecutionId = result.jobExecutionId

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
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedItemInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[*].relatedHoldingsInfo[0].actionStatus == ["UPDATED","UPDATED","UPDATED","UPDATED","UPDATED","UPDATED"]
    And match response.entries[*].relatedItemInfo[0].actionStatus == ["UPDATED","UPDATED","UPDATED","UPDATED","UPDATED","UPDATED"]

    # Verify updated holdings record
    Given path '/holdings-storage/holdings'
    And headers headersUser
    And param query = 'administrativeNotes==["Updated holding"]'
    When method GET
    Then status 200
    And assert response.totalRecords == 6
    And match response.holdingsRecords[*].permanentLocationId == ["fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371","fcd64ce1-6995-48f0-840e-89ffa2288371"]

    # Verify updated item record
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path '/item-storage/items'
    And headers headersUser
    And param query = 'administrativeNotes==["Updated item"]'
    When method GET
    Then status 200
    And assert response.totalRecords == 6
    And match response.items[*].permanentLocationId == ["758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd","758258bc-ecc1-41b8-abca-f7b610822ffd"]
