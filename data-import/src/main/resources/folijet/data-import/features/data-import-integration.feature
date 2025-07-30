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
    * def completeExecutionFeature = 'classpath:folijet/data-import/global/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def exportRecordFeature = 'classpath:folijet/data-import/global/export-record.feature'
    * def createExportMappingProfile = read('classpath:folijet/data-import/global/data-export-profiles.feature@createMappingProfile')
    * def createExportJobProfile = read('classpath:folijet/data-import/global/data-export-profiles.feature@createJobProfile')

    * def samplePath = 'classpath:folijet/data-import/samples/'
    * def updateHoldings = 'classpath:folijet/data-import/features/data-import-integration.feature@UpdateHoldings'


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












