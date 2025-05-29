Feature: Data Import Set For Deletion Utility Functions

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')
    * def javaDemo = Java.type('test.java.WriteData')

  @SetupUpdateJobProfile
  Scenario: Create job profile for Instance update set for deletion
    * def profileName = __arg.profileName
    # Create job profile for Instance update
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "description": "Mapping profile",
          "mappingDetails": {}
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def mappingProfileId = $.id

    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "action": "UPDATE",
          "folioRecord": "INSTANCE",
          "description": "Action profile"
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

    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "description": "Match profile by HRID",
          "incomingRecordType": "MARC_BIBLIOGRAPHIC",
          "existingRecordType": "INSTANCE",
          "matchDetails": [ {
            "incomingRecordType" : "MARC_BIBLIOGRAPHIC",
            "existingRecordType" : "INSTANCE",
            "incomingMatchExpression" : {
              "dataValueType" : "VALUE_FROM_RECORD",
              "fields" : [ {
                "label" : "field",
                "value" : "001"
              }, {
                "label" : "indicator1",
                "value" : ""
              }, {
                "label" : "indicator2",
                "value" : ""
              }, {
                "label" : "recordSubfield",
                "value" : ""
              } ]
            },
            "matchCriterion" : "EXACTLY_MATCHES",
            "existingMatchExpression" : {
              "dataValueType" : "VALUE_FROM_RECORD",
              "fields" : [ {
                "label" : "field",
                "value" : "instance.hrid"
              } ]
            }
          } ]
        },
        "addedRelations": [],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def matchProfileId = $.id

    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request
      """
      {
        "profile": {
          "name": "#(profileName)",
          "description": "Job profile",
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
            "detailProfileId": "#(actionProfileId)",
            "detailProfileType": "ACTION_PROFILE",
            "order": 1,
            "reactTo": "MATCH"
          }
        ],
        "deletedRelations": []
      }
      """
    When method POST
    Then status 201
    * def updateJobProfileId = $.id

  @ImportRecordAndVerify
  Scenario: Import marc record
    * def fileName = __arg.fileName
    * def jobName = __arg.jobName
    * def filePathFromSourceRoot = __arg.filePathFromSourceRoot
    * def actionStatus = __arg.actionStatus
    # Import file
    * def importArgs = { fileName: '#(fileName)', jobName: '#(jobName)' }
    * if (filePathFromSourceRoot) importArgs.filePathFromSourceRoot = filePathFromSourceRoot
    Given call read(utilFeature + '@ImportRecord') importArgs
    Then match status != 'ERROR'

    # Verify job execution
    * call read(completeExecutionFeature) { key: '#(sourcePath)' }
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # Verify instance created
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    And retry until karate.get('response.entries[0].relatedInstanceInfo.actionStatus') != null
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "#(actionStatus)"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "#(actionStatus)"
    * def instanceId = response.entries[0].relatedInstanceInfo.idList[0]
    * def instanceHrid = response.entries[0].relatedInstanceInfo.hridList[0]

    # Retrieve instance hrid from record
    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    And headers headersUser
    When method GET
    Then status 200
    * def sourceRecordId = response.id

  @VerifyInstanceAndRecordMarkedAsDeleted
  Scenario: Verify instance and record are marked as deleted
    * def instanceHrid = instanceHrid
    * def sourceRecordId = sourceRecordId
    # Retrieve instance
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    * def createdInstance = response.instances[0]

    # Verify instance mark as deleted
    And assert createdInstance.staffSuppress == true
    And assert createdInstance.discoverySuppress == true
    And assert createdInstance.deleted == true

    # Retrieve source record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.deleted == true
    And match response.additionalInfo.suppressDiscovery == true
    And match response.state == 'DELETED'
    And match response.leaderRecordStatus == 'd'