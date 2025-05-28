Feature: FAT-1472

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

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
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedHoldingsInfo[0].actionStatus == "CREATED"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And def sourceRecordId = response.entries[0].sourceRecordId
    And def jobExecutionId = response.entries[0].jobExecutionId
    And def holdingHrid = response.entries[0].relatedHoldingsInfo[0].hrid

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify create holdings record correct mapping
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
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
    * def updatedMarcRecord = javaWriteData.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

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
    * def sourcePath = response.fileDefinitions[0].sourcePath
    * def jobExecutionId = response.fileDefinitions[0].jobExecutionId


    Given path 'data-import/uploadUrl'
    And headers headersUser
    And param filename = 'FAT-1472-UPDATED.mrc'
    When method get
    Then status 200
    And def s3UploadKey = response.key
    And def s3UploadId = response.uploadId
    And def uploadUrl = response.url

    Given url uploadUrl
    And headers headersUserOctetStream
    And request updatedMarcRecord
    When method put
    Then status 200
    And def s3Etag = responseHeaders['ETag'][0]

    # reset
    * url baseUrl

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId, 'assembleStorageFile'
    And headers headersUser
    And request { key: '#(s3UploadKey)', tags: ['#(s3Etag)'], uploadId: '#(s3UploadId)' }
    When method post
    Then status 204

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And request read(samplePath + 'jobs/customJob.json')
    When method post
    Then status 204

    * call read(completeExecutionFeature) { key: '#(s3UploadKey)'}

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error

    # Verify job execution for update holdings
    * call read(completeExecutionFeature) { key: '#(s3UploadKey)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedHoldingsInfo[0].actionStatus == "UPDATED"
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Verify create holdings record correct mapping
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
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
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify instance created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "CREATED"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"

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
