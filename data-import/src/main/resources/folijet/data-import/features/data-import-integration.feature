Feature: Data Import integration tests

  Background:
    * url baseUrl
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }

    * configure retry = { interval: 5000, count: 30 }

    * def javaDemo = Java.type('test.java.WriteData')

    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def importHoldingFeature = 'classpath:folijet/data-import/global/default-import-instance-holding-item.feature@importInstanceHoldingItem'
    * def commonImportFeature = 'classpath:folijet/data-import/global/common-data-import.feature'
    * def completeExecutionFeature = 'classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def exportRecordFeature = 'classpath:folijet/data-import/global/export-record.feature'
    * def createExportMappingProfile = read('classpath:folijet/data-import/global/data-export-profiles.feature@createMappingProfile')
    * def createExportJobProfile = read('classpath:folijet/data-import/global/data-export-profiles.feature@createJobProfile')

    * def samplePath = 'classpath:folijet/data-import/samples/'
    * def updateHoldings = 'classpath:folijet/data-import/features/data-import-integration.feature@UpdateHoldings'


  Scenario: FAT-13523 Test import of file with 035 OCLC field with prefix and leading zeros with duplicates and additional subfields using update in ISRI
    * def profileId = 'f26df83c-aa25-40b6-876e-96852c3d4fd4'
    * def externalIdentifierType = "439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef"

    # Assign authentication
    Given path 'copycat/profiles', profileId
    And headers headersUser
    And request
    """
      {
        "id": "#(profileId)",
        "name": "OCLC WorldCat",
        "url": "zcat.oclc.org/OLUCWorldCat",
        "authentication": "100481406/PAOLF",
        "externalIdQueryMap": "@attr 1=1211 $identifier",
        "internalIdEmbedPath": "999ff$i",
        "createJobProfileId": "d0ebb7b0-2f0f-11eb-adc1-0242ac120002",
        "updateJobProfileId": "91f9b8d6-d80e-4727-9783-73fb53e3c786",
        "allowedCreateJobProfileIds": ["d0ebb7b0-2f0f-11eb-adc1-0242ac120002"],
        "allowedUpdateJobProfileIds": ["91f9b8d6-d80e-4727-9783-73fb53e3c786"],
        "targetOptions": {
          "charset": "utf-8"
        },
        "externalIdentifierType": "#(externalIdentifierType)",
        "enabled": true
      }
    """
    When method PUT
    Then status 204

    # Import file and create instance
    Given call read(utilFeature+'@ImportRecord') { fileName:'marcBib', jobName:'createInstance' }
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
    And def instanceHrid = response.entries[0].relatedInstanceInfo.hridList[0]
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Overlay source bibliographic record
    Given path 'copycat/imports'
    And headers headersUser
    And request
    """
    {
      "externalIdentifier": "64758",
      "internalIdentifier": "#(instanceId)",
      "profileId": "#(profileId)"
    }
    """
    When method POST
    Then status 200

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
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "(OCoLC)1001261435"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "(OCoLC)1201949335"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "(OCoLC)976939443"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "1001261435"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "1201949335"
        },
        {
          "identifierTypeId": "#(cancelledSystemNumberIdentifyreTypeId)",
          "value": "976939443"
        },
        {
          "identifierTypeId": "#(OCLCidentifierTypeId)",
          "value": "(OCoLC)64758"
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

  Scenario: FAT-13522 Test import of file with 035 OCLC field with prefix and leading zeros with duplicates and additional subfields
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
    * javaDemo.writeByteArrayToFile(result.exportedBinaryMarcRecord, 'target/' + fileName)

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
    And retry until karate.get('response.entries.length') > 0
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

  # Used in other tests
  @Ignore
  @UpdateHoldings
  Scenario: update holdings with custom static location match
    * def mappingProfileName = 'FAT-1124: Update Holdings mapping profile ' + uniqueProfileName
    * def matchProfileInstanceName = 'FAT-1124: Match on 001 ' + uniqueProfileName
    * def matchProfileHoldingsName = 'FAT-1124: Match on Permanent Location ' + uniqueProfileName
    * def jobProfileUpdateName = 'FAT-1124: Job profile update holdings on static field ' + uniqueProfileName

    # Create mapping profile for update holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(mappingProfileName)",
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
                "value": "#(holdingType)",
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
                "value": "#(temporaryLocation)",
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
    * def folioRecordNameAndDescription = 'FAT-1124: update Holdings ' + uniqueProfileName
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
          "name": "#(matchProfileInstanceName)",
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

    # Create match profile for MARC-to-HOLDINGS 901$a to location(code)
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
    """
      {
        "profile": {
          "name": "#(matchProfileHoldingsName)",
          "description": "",
          "incomingRecordType": "STATIC_VALUE",
          "matchDetails": [
            {
              "incomingRecordType": "STATIC_VALUE",
              "incomingMatchExpression": {
                "staticValueDetails": {
                  "staticValueType": "TEXT",
                  "text": "#(staticMatchValue)",
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
          "name": "#(jobProfileUpdateName)",
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

    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/FAT-1124.mrc')
    * def updatedMarcRecord = javaDemo.replaceHrIdFieldInMarcFile(marcRecord, '1060180377', instanceHrid)

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
          "name": "FAT-1124-UPDATED.mrc"
        }
     ]
    }
    """
    When method POST
    Then status 201
    * def response = $

    * def uploadDefinitionId = response.fileDefinitions[0].uploadDefinitionId
    * def fileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadUrl'
    And headers headersUser
    And param filename = "FAT-1124-UPDATED.mrc"
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

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers headersUser
    And request read(samplePath + 'jobs/customJob.json')
    When method post
    Then status 204

    Given call read(completeExecutionFeature) { key: '#(s3UploadKey)'}
    Then def status = jobExecution.status

  Scenario: FAT-13520 Match MARC-to-Instance by Cancelled LCCN and update Instance
    * print 'FAT-13520 Match MARC-to-Instance by Cancelled LCCN and update Instance'

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13520: MARC-to-Instance",
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-13520'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 010 field to cancelled LCCN
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13520: Match Profile",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
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
                    "value": "z"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "INSTANCE",
              "existingMatchExpression": {
                "fields" : [ {
                  "label" : "field",
                  "value" : "instance.identifiers[].value"
                }, {
                  "label" : "identifierTypeId",
                  "value" : "c858e4f2-2b6b-4385-842b-60532ee34abb"
                } ],
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

    # Create job profile
    * def jobProfileUpdateName = "FAT-13520: Job profile"
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
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
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

    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13520', jobName:'customJob' }
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
    And retry until karate.get('response.entries.length') > 0
    And headers headersUser
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
    * def instanceId = response.instances[0].id

    # Export MARC record by instance id
    * def fileName = 'FAT-13520-1.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(defaultJobProfileId)", fileName: "#(fileName)" }
    * javaDemo.writeByteArrayToFile(result.exportedBinaryMarcRecord, 'target/' + fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'file:target/' + fileName

    # Create file definition for FAT-13520-1.mrc-file
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

    # Verify externalIdsHolder.instanceId presented in the record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'

    # Verify that real instance was created with specific fields inside in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].statisticalCodeIds[0] == '6899291a-1fb9-4130-98ce-b40368556818'
    And assert response.instances[0].identifiers[0].identifierTypeId == 'c858e4f2-2b6b-4385-842b-60532ee34abb'
    And assert response.instances[0].identifiers[0].value == 'CNR456'

  Scenario: FAT-13521_1 Update of file using marc-to-marc match by 010$z
    * print 'FAT-13521_1 Match MARC-to-MARC by Cancelled LCCN and update Instance'

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_1: MARC-to-Instance",
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-13521_1'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 010 field to cancelled LCCN
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_1: Match Pofile",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
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
                    "value": "z"
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
                    "value": "010"
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
                    "value": "z"
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
    * def instanceMatchProfileId = $.id

    # Create job profile
    * def jobProfileUpdateName = "FAT-13521_1: Job profile"
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
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
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

    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13521_1', jobName:'customJob' }
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
    * def instanceId = response.instances[0].id

    # Export MARC record by instance id
    * def fileName = 'FAT-13521_1-1.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(defaultJobProfileId)", fileName: "#(fileName)" }
    * javaDemo.writeByteArrayToFile(result.exportedBinaryMarcRecord, 'target/' + fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'file:target/' + fileName

    # Create file definition for FAT-13521_1-1.mrc-file
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

    # Verify externalIdsHolder.instanceId presented in the record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'

    # Verify that real instance was created with specific fields inside in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].statisticalCodeIds[0] == '6899291a-1fb9-4130-98ce-b40368556818'
    And assert response.instances[0].identifiers[0].identifierTypeId == 'c858e4f2-2b6b-4385-842b-60532ee34abb'
    And assert response.instances[0].identifiers[0].value == 'CNR455'

  Scenario: FAT-13521_2 Update of file using marc-to-marc match by 010$z with multiple matches
    * print 'FAT-13521_2 Match MARC-to-MARC by Cancelled LCCN and update Instance with multiple matches'

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_2: MARC-to-Instance",
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-13521_2'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 010 field to cancelled LCCN
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_2: Match Pofile",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
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
                    "value": "z"
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
                    "value": "010"
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
                    "value": "z"
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
    * def instanceMatchProfileId = $.id

    # Create job profile
    * def jobProfileUpdateName = "FAT-13521_2: Job profile"
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
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
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

    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13521_2', jobName:'customJob' }
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
    * def instanceId = response.instances[0].id

    # Import second file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13521_2', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify second job execution for create second instance
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify second instance created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "CREATED"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"

    * def secondSourceRecordId = response.entries[0].sourceRecordId

    # Retrieve second instance hrid from record
    Given path 'source-storage/records', secondSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def secondInstanceHrid = response.externalIdsHolder.instanceHrid

    # Retrieve second instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + secondInstanceHrid
    When method GET
    Then status 200
    * def secondInstanceId = response.instances[0].id

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'classpath:folijet/data-import/samples/mrc-files/' + fileName

    # Create file definition for FAT-13521_2-1.mrc-file
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

    # Verify job execution for data-import completed with error
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    * def importJobExecutionId = response.id
    And assert jobExecution.status == 'ERROR'
    And assert jobExecution.uiStatus == 'ERROR'
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1

    # Verify that needed entities discarded on update
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', importJobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'DISCARDED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'DISCARDED'
    And match response.entries[0].relatedInstanceInfo.error contains 'org.folio.processing.exceptions.MatchingException: Found multiple records matching specified conditions'
    And match response.entries[0].error contains 'org.folio.processing.exceptions.MatchingException: Found multiple records matching specified conditions'
    And def sourceRecordId = response.entries[0].sourceRecordId

    # Verify that real instance was created with no data inside statistical code
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And match response.instances[0].statisticalCodeIds == '#[]'

  Scenario: FAT-13521_3 Update of file using marc-to-marc match by 010$z with multiple matches
    * print 'Match MARC-to-Instance by Cancelled LCCN and update Instance'

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_3: MARC-to-Instance",
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-13521_3'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create match profile for MARC-to-MARC 010$z field to 010$z field
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_3: MARC-to-MARC",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
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
                    "value": "z"
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
                    "value": "010"
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
                    "value": "z"
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
    * def matchProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 010 field to cancelled LCCN
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "FAT-13521_3: Match submatch to cataloged",
          "description": "",
          "incomingRecordType": "STATIC_VALUE",
          "matchDetails": [
            {
              "incomingRecordType": "STATIC_VALUE",
              "existingRecordType": "INSTANCE",
              "incomingMatchExpression": {
                "dataValueType": "STATIC_VALUE",
                "fields": [],
                "staticValueDetails": {
                  "staticValueType": "TEXT",
                  "text": "Cataloged",
                  "number": ""
                }
              },
              "matchCriterion": "EXACTLY_MATCHES",
              "existingMatchExpression": {
                "dataValueType": "VALUE_FROM_RECORD",
                "fields": [
                  {
                    "label": "field",
                    "value": "instance.statusId"
                  }
                ]
              }
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
    * def secondMatchProfileId = $.id

    # Create job profile
    * def jobProfileUpdateName = "FAT-13521_3: Job profile"
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
            "detailProfileId": "#(matchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(matchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(secondMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0,
            "reactTo": "MATCH"
          },
          {
            "masterProfileId": "#(secondMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
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

    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13521_3', jobName:'customJob' }
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
    * eval updatedInstance['statusId'] = "9634a5ab-9228-4703-baf2-4d12ebc77d56"

    # Update statusId
    Given path 'inventory/instances', updatedInstance.id
    And headers headersUser
    And request updatedInstance
    When method PUT
    Then status 204

    # Verify status updated
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And match response.instances[0].statusId == "9634a5ab-9228-4703-baf2-4d12ebc77d56"

    # Import second file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'FAT-13521_3', jobName:'customJob' }
    Then match status != 'ERROR'

    # Verify second job execution for create second instance
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify second instance created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)','x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "CREATED"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"

    * def secondSourceRecordId = response.entries[0].sourceRecordId

    # Retrieve second instance hrid from record
    Given path 'source-storage/records', secondSourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def secondInstanceHrid = response.externalIdsHolder.instanceHrid

    # Retrieve second instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + secondInstanceHrid
    When method GET
    Then status 200
    * def secondInstanceId = response.instances[0].id

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'classpath:folijet/data-import/samples/mrc-files/' + fileName

    # Create file definition for FAT-13521_3-1.mrc-file
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

    # Verify externalIdsHolder.instanceId presented in the record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'

    # Verify that real instance was created with specific fields inside in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].statisticalCodeIds[0] == '6899291a-1fb9-4130-98ce-b40368556818'
    And assert response.instances[0].identifiers[0].identifierTypeId == 'c858e4f2-2b6b-4385-842b-60532ee34abb'
    And assert response.instances[0].identifiers[0].value == 'CNR459'

  Scenario: MODINV-1094 Test import with suppress from discovery
    * print 'MODINV-1094 Test import with suppress from discover'

    # Create mapping profile for create instances
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "MODINV-1094: Create Instances mapping profile",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "",
          "mappingDetails": {
            "name": "instance",
            "recordType": "INSTANCE",
            "mappingFields": [
              {
                "name" : "discoverySuppress",
                "enabled" : "true",
                "required" : false,
                "path" : "instance.discoverySuppress",
                "value" : "",
                "booleanFieldAction" : "ALL_TRUE",
                "subfields" : [ ]
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

    # Create action profile for create instances
    * def folioRecordNameAndDescription = 'MODINV-1094: create Instances'
    * def folioRecord = 'INSTANCE'
    * def profileAction = 'CREATE'
    * def mappingProfileEntityId = createInstancesMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request read(samplePath + 'samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def createInstancesActionProfileId = $.id

    # Create job profile - Create Instance
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "MODINV-1094: Job profile create instances and holdings",
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
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def createJobProfileId = $.id

    # Import file and create instance
    * def jobProfileId = createJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'MODINV-1094', jobName:'customJob' }
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
    And retry until karate.get('response.entries.length') > 0
    When method GET
    Then status 200
    And match response.entries[0].relatedInstanceInfo.actionStatus == "CREATED"
    And def sourceRecordId = response.entries[0].sourceRecordId
    And def jobExecutionId = response.entries[0].jobExecutionId
    And def instanceId = response.entries[0].relatedInstanceInfo.idList[0]
    And def instanceHrid = response.entries[0].relatedInstanceInfo.hridList[0]

    # Verify externalIdsHolder.instanceId presented in the record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'

    # Verify that real instance was created with specific fields inside in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].discoverySuppress == true

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    And match response.additionalInfo.suppressDiscovery == true

  Scenario: MODINV-1094_for_update Match MARC-to-Instance by Cancelled LCCN and update Instance with Suppress From Discovery
    * print 'MODINV-1094_for_update Match MARC-to-Instance by Cancelled LCCN and update Instance with Suppress From Discovery'

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "MODINV-1094_for_update: MARC-to-Instance",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "",
          "mappingDetails": {
            "name": "instance",
            "recordType": "INSTANCE",
            "mappingFields": [
              {
                "name" : "discoverySuppress",
                "enabled" : "true",
                "required" : false,
                "path" : "instance.discoverySuppress",
                "value" : "",
                "booleanFieldAction" : "ALL_TRUE",
                "subfields" : [ ]
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

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'MODINV-1094_for_update'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create match profile for MARC-to-INSTANCE 010 field to cancelled LCCN
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "MODINV-1094_for_update: Match Profile",
          "description": "",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "matchDetails": [
            {
              "incomingRecordType": "MARC_BIBLIOGRAPHIC",
              "incomingMatchExpression": {
                "fields": [
                  {
                    "label": "field",
                    "value": "010"
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
                    "value": "z"
                  }
                ],
                "staticValueDetails": null,
                "dataValueType": "VALUE_FROM_RECORD"
              },
              "existingRecordType": "INSTANCE",
              "existingMatchExpression": {
                "fields" : [ {
                  "label" : "field",
                  "value" : "instance.identifiers[].value"
                }, {
                  "label" : "identifierTypeId",
                  "value" : "c858e4f2-2b6b-4385-842b-60532ee34abb"
                } ],
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

    # Create job profile
    * def jobProfileUpdateName = "MODINV-1094_for_update: Job profile"
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
            "detailProfileId": "#(instanceMatchProfileId)",
            "detailProfileType": "MATCH_PROFILE",
            "order": 0
          },
          {
            "masterProfileId": "#(instanceMatchProfileId)",
            "masterProfileType": "MATCH_PROFILE",
            "detailProfileId": "#(instanceActionProfileId)",
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

    * def createInstanceJobProfileId = 'e34d7b92-9b83-11eb-a8b3-0242ac130003'

    # Import file
    * def jobProfileId = createInstanceJobProfileId
    Given call read(utilFeature+'@ImportRecord') { fileName:'MODINV-1094_for_update', jobName:'customJob' }
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
    * def instanceId = response.instances[0].id

    # Export MARC record by instance id
    * def fileName = 'MODINV-1094_for_update.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(defaultJobProfileId)", fileName: "#(fileName)" }
    * javaDemo.writeByteArrayToFile(result.exportedBinaryMarcRecord, 'target/' + fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber
    * def filePath = 'file:target/' + fileName

    # Create file definition for MODINV-1094_for_update.mrc-file
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

    # Verify externalIdsHolder.instanceId presented in the record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'

    # Verify that real instance was created with specific fields inside in inventory
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].statisticalCodeIds[0] == '6899291a-1fb9-4130-98ce-b40368556818'
    And assert response.instances[0].identifiers[0].identifierTypeId == 'c858e4f2-2b6b-4385-842b-60532ee34abb'
    And assert response.instances[0].identifiers[0].value == 'CNR470'
    And assert response.instances[0].discoverySuppress == true

    # Compare instance source data
    Given path 'source-storage/source-records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.additionalInfo.suppressDiscovery == true
