Feature: FAT-13522

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  Scenario: FAT-13522 Test update of file with 035 OCLC field with prefix and leading zeros with duplicates and additional subfields via DI
    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13522 Create Instance",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "",
          "mappingDetails": {
            "name": "instance",
            "recordType": "INSTANCE",
            "mappingFields": [
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

    # Create action profile for Update MARC bib
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-13522'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def updateInstanceActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 001 field to hrId
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13522 Match on 001",
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
    * def matchInstanceProfileId = $.id

    #  Create job profile - update holdings and items
    * def jobProfileUpdateName = "updateInstanceBy001JobProfileId"
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
            "detailProfileId": "#(matchInstanceProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(matchInstanceProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(updateInstanceActionProfileId)",
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

    # Import file and create instance
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13522', jobName:'createInstance' }
    Then match status != 'ERROR'

    # Verify job execution for create instances
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
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And def instanceId = response.entries[0].relatedInstanceInfo.idList[0]

    # Export MARC record by instance id
    * def fileName = 'FAT-13522-1.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(defaultJobProfileId)", fileName: "#(fileName)" }
    * javaWriteData.writeByteArrayToFile(result.exportedBinaryMarcRecord, 'target/' + fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'file:target/' + fileName

    # Create file definition for FAT-13522-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read(commonImportFeature) {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey: '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot': '#(filePath)'}

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
    And headers headersUser
    And request
      """
      {
        "uploadDefinition": "#(result.uploadDefinition)",
        "jobProfileInfo": {
          "id": "#(updateJobProfileId)",
          "name": "#(jobProfileUpdateName)",
          "dataType": "MARC"
        }
      }
      """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    * def importJobExecutionId = response.id
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities updated
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', importJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'UPDATED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'UPDATED'
    And match response.entries[0].error == ''
    And def instanceId = response.entries[0].relatedInstanceInfo.idList[0]
    And def instanceHrid = response.entries[0].relatedInstanceInfo.hridList[0]
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Get OCLC identifier id
    Given path 'identifier-types'
    And headers headersUser
    And param query = 'name==OCLC'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def OCLCidentifierTypeId = response.identifierTypes[0].id

    # Get Cancelled System Control Number identifier id
    Given path 'identifier-types'
    And headers headersUser
    And param query = 'name==Cancelled system control number'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def cancelledSystemNumberIdentifyreTypeId = response.identifierTypes[0].id

    * def expectedIdentifiers =
      """
      [
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)123456"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)64758"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)976939443"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)1001261435"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)120194933"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)tfe501056183"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "(OCoLC)12345678"
        }
      ]
      """

    # Verify ISRI
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def identifiers = response.instances[0].identifiers
    * def actualIdentifiers = karate.jsonPath(identifiers, "$[?(@.identifierTypeId=='" + cancelledSystemNumberIdentifyreTypeId + "' || @.identifierTypeId=='" + OCLCidentifierTypeId + "')]")
    And match actualIdentifiers == '#present'
    And match actualIdentifiers contains only expectedIdentifiers

    * def expected035s =
      """
      [
        {
          "ind1": " ",
          "ind2": " ",
          "subfields": [
            {
              "a": "(Sirsi) i9781845902919"
            }
          ]
        },
        {
          "ind1": " ",
          "ind2": " ",
          "subfields": [
            {
              "a": "(LTSCA)303845"
            }
          ]
        },
        {
          "ind1": " ",
          "ind2": " ",
          "subfields": [
            {
              "a": "(OCoLC)123456"
            },
            {
              "a": "(OCoLC)64758"
            },
            {
              "a": "(OCoLC)976939443"
            },
            {
              "a": "(OCoLC)1001261435"
            },
            {
              "a": "(OCoLC)120194933"
            },
            {
              "a": "(OCoLC)tfe501056183"
            },
            {
              "z": "(OCoLC)12345678"
            }
          ]
        }
      ]
      """

    # Retrieve instance source
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    * def parsedRecord = response.parsedRecord
    And match parsedRecord.content.fields[*].035 contains only expected035s

    * def expectedQuickMarc035s =
      """
      [
        {
          "tag": "035",
          "content": "$a (Sirsi) i9781845902919",
          "indicators": [
            "\\",
            "\\"
          ],
          "isProtected": false
        },
        {
          "tag": "035",
          "content": "$a (OCoLC)123456 $a (OCoLC)64758 $a (OCoLC)976939443 $a (OCoLC)1001261435 $a (OCoLC)120194933 $a (OCoLC)tfe501056183 $z (OCoLC)12345678",
          "indicators": [
            "\\",
            "\\"
          ],
          "isProtected": false
        },
        {
          "tag": "035",
          "content": "$a (LTSCA)303845",
          "indicators": [
            "\\",
            "\\"
          ],
          "isProtected": false
        }
      ]
      """

    Given path 'records-editor/records'
    And param externalId = instanceId
    And headers headersUser
    When method GET
    Then status 200
    And match karate.jsonPath(response, "$.fields[?(@.tag=='035')]") == expectedQuickMarc035s
