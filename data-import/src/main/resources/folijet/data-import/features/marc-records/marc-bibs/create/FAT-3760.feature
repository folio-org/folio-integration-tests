Feature: FAT-3760

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-3760 Verify the mapping for item record notes and check in/out notes from MARC field
    # Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-3760 Create item for mapping notes",
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
                        "required": true,
                        "path": "item.notes[].itemNoteTypeId",
                        "value": "876$t",
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
                        "required": true,
                        "path": "item.notes[].note",
                        "value": "876$n"
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
                  "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves",
                  "4dec5417-0765-4767-bed6-b363a2d7d4e2": "DCB Can circulate",
                  "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                  "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected"
                }
              },
              {
                "name": "status.name",
                "enabled": true,
                "path": "item.status.name",
                "value": "\"Available\"",
                "subfields": []
              },
              {
                "name": "circulationNotes",
                "enabled": true,
                "path": "item.circulationNotes[]",
                "value": "",
                "subfields": [
                  {
                    "order": 0,
                    "path": "item.circulationNotes[]",
                    "fields": [
                      {
                        "name": "noteType",
                        "enabled": true,
                        "path": "item.circulationNotes[].noteType",
                        "value": "878$t"
                      },
                      {
                        "name": "note",
                        "enabled": true,
                        "path": "item.circulationNotes[].note",
                        "value": "878$a"
                      },
                      {
                        "name": "staffOnly",
                        "enabled": true,
                        "path": "item.circulationNotes[].staffOnly",
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
    * def itemMappingProfileId = $.id

    # Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-3760 Create holdings for mapping notes",
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
                  "9d1b77e8-f02e-4b7f-b296-3f2042ddac54": "DCB (000)",
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
    * def holdingsMappingProfileId = $.id

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-3760 Create instance for mapping notes",
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
    * def instanceMappingProfileId = $.id

    # Create action profile for Create Item
    * def mappingProfileEntityId = itemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-3760'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def itemActionProfileId = $.id

    # Create action profile for Create Item
    * def mappingProfileEntityId = holdingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-3760'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create action profile for Create Item
    * def mappingProfileEntityId = instanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-3760'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    #  Create job profile - Create Instance, Holdings and Item
    * def jobProfileCreateName = "FAT-3760 Create Instance, Holdings and Item"
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(jobProfileCreateName)",
          "description": "",
          "dataType": "MARC"
        },
        "addedRelations": [
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(holdingsActionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1
          },
          {
            "masterProfileId": null,
            "masterProfileType": "JOB_PROFILE",
            "detailProfileId": "#(itemActionProfileId)",
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

    # Import file and create instance, holdings and item
    * def jobProfileId = createJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:"FAT-3760", jobName: 'customJob'}
    Then match status != 'ERROR'

    # Verify job execution for create instances
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 2
    And assert jobExecution.progress.total == 2
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null && karate.get('response.entries[0].relatedHoldingsInfo[0].actionStatus') != null && karate.get('response.entries[0].relatedItemInfo[0].actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And match response.entries[0].relatedHoldingsInfo[0].actionStatus == "CREATED"
    And match response.entries[0].relatedItemInfo[0].actionStatus == "CREATED"
    And match response.entries[1].relatedInstanceInfo.actionStatus == "CREATED"
    And match response.entries[1].relatedHoldingsInfo[0].actionStatus == "CREATED"
    And match response.entries[1].relatedItemInfo[0].actionStatus == "CREATED"
    And def itemId1 = response.entries[0].relatedItemInfo[0].id
    And def itemId2 = response.entries[1].relatedItemInfo[0].id


    Given path 'inventory/items', itemId1
    And headers headersUser
    When method GET
    Then status 200
    * print response.notes
    * print response.notes[0]

    And def notes = response.notes
    And assert notes.length == 1
    And match notes[0] == '#present'
    And match notes[0].itemNoteTypeId == '8d0a5eca-25de-4391-81a9-236eeefdd20b'
    And match notes[0].note == 'This is a plain note'
    And match notes[0].staffOnly == true

    And def circulationNotes = response.circulationNotes
    And assert circulationNotes.length == 1
    And match circulationNotes[0] == '#present'
    And match circulationNotes[0].noteType == 'Check in'
    And match circulationNotes[0].note == 'This is a check in note'
    And match circulationNotes[0].staffOnly == true

    Given path 'inventory/items', itemId2
    And headers headersUser
    When method GET
    Then status 200
    And def notes = response.notes
    And assert notes.length == 2
    And def bindingNote = karate.jsonPath(notes, "$[?(@.itemNoteTypeId=='87c450be-2033-41fb-80ba-dd2409883681')]")
    And match bindingNote == '#present'
    And match bindingNote[0].note == 'This is a binding note'
    And match bindingNote[0].staffOnly == true
    And def electronicBookplayeNote = karate.jsonPath(notes, "$[?(@.itemNoteTypeId=='f3ae3823-d096-4c65-8734-0c1efd2ffea8')]")
    And match electronicBookplayeNote == '#present'
    And match electronicBookplayeNote[0].note == 'This is an electronic bookplate note'
    And match electronicBookplayeNote[0].staffOnly == true

    And def circulationNotes = response.circulationNotes
    And assert circulationNotes.length == 2
    And def checkOutNote = karate.jsonPath(circulationNotes, "$[?(@.noteType=='Check out')]")
    And match checkOutNote == '#present'
    And match checkOutNote[0].note == 'This is a check out note'
    And match checkOutNote[0].staffOnly == true
    And def checkInNote = karate.jsonPath(circulationNotes, "$[?(@.noteType=='Check in')]")
    And match checkInNote == '#present'
    And match checkInNote[0].note == 'This is a check in note'
    And match checkInNote[0].staffOnly == true
