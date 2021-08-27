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
					"name": "instanceTypeId",
					"enabled": false,
					"path": "instance.instanceTypeId",
					"value": "",
					"subfields": []
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
          "name": "instance",
          "recordType": "HOLDINGS"
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
          "name": "instance",
          "recordType": "ITEM"
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

