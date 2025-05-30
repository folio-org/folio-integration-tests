Feature: Set for deletion logic

  Background:
    * url baseUrl
    * call login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def utilFeature = 'classpath:folijet/data-import/global/import-record.feature'
    * def commonImportFeature = 'classpath:folijet/data-import/global/common-data-import.feature'
    * def completeExecutionFeature = 'classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted'
    * def samplePath = 'classpath:folijet/data-import/samples/'

    * def javaDemo = Java.type('test.java.WriteData')

  @Ignore
  @SetupUpdateJobProfile
  Scenario: Create job profile for Instance update set for deletion
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

  @Ignore
  @ImportRecordAndVerify
  Scenario: Import marc record
    # Import file
    Given call read(utilFeature + '@ImportRecord') { fileName: '#(__arg.fileName)', jobName: '#(__arg.jobName)', filePathFromSourceRoot: '#(__arg.filePathFromSourceRoot)' }
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

  @Ignore
  @VerifyInstanceAndRecordMarkedAsDeleted
  Scenario: Verify instance and record are marked as deleted
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

  Scenario: Create instance using marc with deleted leader
    Given call read('@ImportRecordAndVerify') { fileName: 'marcBibDeletedLeader', jobName: 'createInstance', actionStatus: 'CREATED' }
    Given call read('@VerifyInstanceAndRecordMarkedAsDeleted')

  Scenario: Update instance using marc with deleted leader
    Given call read('@ImportRecordAndVerify') { fileName: 'marcBib', jobName: 'createInstance', actionStatus: 'CREATED' }

    * def fileName = 'updateMarcBibDeletedLeader'
    * def filePathFromSourceRoot = 'file:target/' + fileName + '.mrc'
    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/marcBibDeletedLeader.mrc')
    * def updatedMarcRecord = javaDemo.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

    * javaDemo.writeByteArrayToFile(updatedMarcRecord, 'target/' + fileName + '.mrc')

    Given call read('@SetupUpdateJobProfile') { profileName: 'Update deleted' }
    * def jobProfileId = updateJobProfileId

    Given call read('@ImportRecordAndVerify') { fileName: '#(fileName)', jobName: 'customJob', filePathFromSourceRoot: '#(filePathFromSourceRoot)', actionStatus: 'UPDATED' }
    Given call read('@VerifyInstanceAndRecordMarkedAsDeleted')

  Scenario: Unmark deleted instance
    Given call read('@ImportRecordAndVerify') { fileName: 'marcBibDeletedLeader', jobName: 'createInstance', actionStatus: 'CREATED' }

    * def fileName = 'unmarkDeleted'
    * def filePathFromSourceRoot = 'file:target/' + fileName + '.mrc'
    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/marcBib.mrc')
    * def updatedMarcRecord = javaDemo.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

    * javaDemo.writeByteArrayToFile(updatedMarcRecord, 'target/' + fileName + '.mrc')

    Given call read('@SetupUpdateJobProfile') { profileName: 'Unmark deleted' }
    * def jobProfileId = updateJobProfileId

    Given call read('@ImportRecordAndVerify') { fileName: '#(fileName)', jobName: 'customJob', filePathFromSourceRoot: '#(filePathFromSourceRoot)', actionStatus: 'UPDATED' }

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
    And assert createdInstance.deleted == false

    # Retrieve source record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.deleted == false
    And match response.additionalInfo.suppressDiscovery == true
    And match response.state == 'ACTUAL'
    And match response.leaderRecordStatus == 'c'
