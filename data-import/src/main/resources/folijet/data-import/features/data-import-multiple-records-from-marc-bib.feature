Feature: Util feature to import multiple entities from one incoming marc bib. Based on FAT-4834 scenario steps.

  # requires {testIdentifier} argument

  Background:
    * url baseUrl
    * def entitiesIdMap = {}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

  @importMultipleHoldingsAndItems
  Scenario: Import Holdings, Items. Based on FAT-4834 scenario steps.
    * print 'Multiple imports from one marc bib file based on FAT-4834 scenario steps'

    # Create mapping profile for Holdings
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    * def profileName = "Test multiple holdings"
    And request
    """
    {
      "profile": {
        "name": "#(profileName)",
        "incomingRecordType": "MARC_BIBLIOGRAPHIC",
        "existingRecordType": "HOLDINGS",
        "description": "",
        "mappingDetails": {
          "name": "holdings",
          "recordType": "HOLDINGS",
          "mappingFields": [
            {
              "name": "permanentLocationId",
              "enabled": "true",
              "path": "holdings.permanentLocationId",
              "value": "945$h",
              "subfields": [],
              "acceptedValues": {
                "53cf956f-c1df-410b-8bea-27f712cca7c0": "Annex (KU/CC/DI/A)",
                "184aae84-a5bf-4c6a-85ba-4a7c73026cd5": "Online (E)",
                "787e5bb0-dfc2-4d72-b173-ba0d62c2432b": "autotest_location_name_707.8329722061326885 (autotest_location_code_594.3894193664064885)",
                "758258bc-ecc1-41b8-abca-f7b610822ffd": "ORWIG ETHNO CD (KU/CC/DI/O)",
                "abebb332-13f5-4ee6-b50e-8f4c94804a0a": "autotest_location_name_972.5551621234004217 (autotest_location_code_906.1103849246704217)",
                "b241764c-1466-4e1d-a028-1a3684a5da87": "Popular Reading Collection (KU/CC/DI/P)",
                "ea1b0cb9-c832-4b95-89fd-97636d90dbfb": "autotest_location_name_976.6356076876502242 (autotest_location_code_817.5452807694649242)",
                "f34d27c6-a8eb-461b-acd6-5dea81771e70": "SECOND FLOOR (KU/CC/DI/2)",
                "fcd64ce1-6995-48f0-840e-89ffa2288371": "Main Library (KU/CC/DI/M)"
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
    * def mappingProfileHoldingsId = $.id

    # Create action profile for CREATE Holdings
    * def mappingProfileEntityId = mappingProfileHoldingsId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'HOLDINGS'
    * def folioRecordNameAndDescription = "Test multiple holdings"
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileHoldingsId = $.id

    # Create mapping profile for Item
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    * def profileName = "Test multiple items"
    And request
    """
    {
      "profile": {
        "name": "#(profileName)",
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
              "value": "945$a",
              "subfields": [],
              "acceptedValues": {
                "1a54b431-2e4f-452d-9cae-9cee66c9a892": "book",
                "5ee11d91-f7e8-481d-b079-65d708582ccc": "dvd",
                "30b3e36a-d3b2-415e-98c2-47fbdf878862": "video recording",
                "71fbd940-1027-40a6-8a48-49b44d795e46": "unspecified",
                "615b8413-82d5-4203-aa6e-e37984cb5ac3": "electronic resource",
                "d9acad2f-2aac-4b48-9097-e6ab85906b25": "text",
                "dd0bf600-dbd9-44ab-9ff2-e2a61a6539f1": "sound recording",
                "fd6c6515-d470-4561-9c32-3e3290d4ca98": "microform"
              }
            },
            {
              "name": "permanentLoanType.id",
              "enabled": true,
              "path": "item.permanentLoanType.id",
              "value": "\"Selected\"",
              "subfields": [],
              "acceptedValues": {
                "2b94c631-fca9-4892-a730-03ee529ffe27": "Can circulate",
                "a1dc1ce3-d56f-4d8a-b498-d5d674ccc845": "Selected",
                "2e48e713-17f3-4c13-a9f8-23845bb210a4": "Reading room",
                "e8b311a6-3b21-43f2-a269-dd9310cb2d0e": "Course reserves"
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

    # Create action profile for CREATE Item
    * def mappingProfileEntityId = mappingProfileItemId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'CREATE'
    * def folioRecord = 'ITEM'
    * def folioRecordNameAndDescription = "Test multiple items"
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def actionProfileItemId = $.id

    # get default create instance action profile
    Given path 'data-import-profiles', 'actionProfiles'
    And headers headersAdmin
    And param query = 'name=="Default - Create instance"'
    When method GET
    Then status 200
    * def actionProfileInstanceId = $.actionProfiles[0].id

    * print 'Default Create Instance Action Profile Id: ', actionProfileInstanceId

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    * def profileName = "Test multiple items"
    And request
    """
    {
      "profile": {
        "name": "#(profileName)",
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
        },
        {
          "masterProfileId": null,
          "masterProfileType": "JOB_PROFILE",
          "detailProfileId": "#(actionProfileItemId)",
          "detailProfileType": "ACTION_PROFILE",
          "order": 2
        }
      ],
      "deletedRelations": []
    }
    """
    When method POST
    Then status 201
    * def jobProfileId = $.id

    * def randomNumber = callonce random
    * def fileName = 'MultipleHold_AndItems.mrc'
    * def uiKey = fileName + randomNumber

    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('classpath:folijet/data-import/global/common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/MultipleHold_AndItems.mrc'}

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
    * def profileName = "Instance Mapping profile "
    And request
    """
    {
      "uploadDefinition": #(result.uploadDefinition),
      "jobProfileInfo": {
        "id": "#(jobProfileId)",
        "name": "#(profileName)",
        "dataType": "MARC"
      }
    }
    """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted') { key: '#(result.s3UploadKey)'}
    # Get child job execution
    Given path 'change-manager/jobExecutions', jobExecutionId
    And headers headersUser
    And print response.status
    When method get
    Then status 200
    And def status = response.status


    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify that needed entities created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until response.entries[0].holdingsActionStatus != null && response.entries[0].itemActionStatus != null
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].holdingsActionStatus == 'CREATED'
    And assert response.entries[0].itemActionStatus == 'CREATED'
    And match response.entries[0].error == '#notpresent'
    * def sourceRecordId = response.entries[0].sourceRecordId

    # Retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # Verify that real instance was created with specific fields in inventory and retrieve instance id
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].contributors[0].name == 'Chin, Staceyann, 1972-'
    And assert response.instances[0].subjects[1].value == 'Poetry'
    * def instanceId = response.instances[0].id

    # Verify that multiple holdings were created
    Given path 'holdings-storage/holdings'
    And headers headersUser
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And assert response.totalRecords == 3
    And assert response.holdingsRecords[0].permanentLocationId == 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    And assert response.holdingsRecords[1].permanentLocationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And assert response.holdingsRecords[2].permanentLocationId == '184aae84-a5bf-4c6a-85ba-4a7c73026cd5'
    * def holdingsId = response.holdingsRecords[0].id
    * def holdingsSourceId = response.holdingsRecords[0].sourceId

    # Verify holdings source id that should be FOLIO
    Given path 'holdings-sources', holdingsSourceId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.name == 'FOLIO'

    # Verify that real item was created in inventory
    Given path 'inventory/items'
    And headers headersUser
    And param query = 'holdingsRecordId==' + holdingsId
    When method GET
    Then status 200
    And assert response.totalRecords == 3
    And assert response.items[0].permanentLoanType.name == 'Selected'
    And assert response.items[0].permanentLoanType.id == 'a1dc1ce3-d56f-4d8a-b498-d5d674ccc845'
    And assert response.items[0].status.name == 'Available'
    And match response.items[0].status.date == '#present'

    # Delete job profile
    Given path 'data-import-profiles/jobProfiles', jobProfileId
    And headers headersUser
    When method DELETE
    Then status 204

    # Delete action profiles
    Given path 'data-import-profiles/actionProfiles', actionProfileHoldingsId
    And headers headersUser
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/actionProfiles', actionProfileItemId
    And headers headersUser
    When method DELETE
    Then status 204

    #Delete mapping profiles
    Given path 'data-import-profiles/mappingProfiles', mappingProfileHoldingsId
    And headers headersUser
    When method DELETE
    Then status 204

    Given path 'data-import-profiles/mappingProfiles', mappingProfileItemId
    And headers headersUser
    When method DELETE
    Then status 204

    * set entitiesIdMap.instanceId = instanceId
