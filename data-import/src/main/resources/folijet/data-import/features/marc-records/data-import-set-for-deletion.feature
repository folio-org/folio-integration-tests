Feature: Set for deletion logic

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')


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
    # TODO: add explicit parameters for this scenario
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
    * def updatedMarcRecord = javaWriteData.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

    * javaWriteData.writeByteArrayToFile(updatedMarcRecord, 'target/' + fileName + '.mrc')

    Given call read('@SetupUpdateJobProfile') { profileName: 'Update deleted' }
    * def jobProfileId = updateJobProfileId

    Given call read('@ImportRecordAndVerify') { fileName: '#(fileName)', jobName: 'customJob', filePathFromSourceRoot: '#(filePathFromSourceRoot)', actionStatus: 'UPDATED' }
    Given call read('@VerifyInstanceAndRecordMarkedAsDeleted')

  Scenario: Unmark deleted instance
    Given call read('@ImportRecordAndVerify') { fileName: 'marcBibDeletedLeader', jobName: 'createInstance', actionStatus: 'CREATED' }

    * def fileName = 'unmarkDeleted'
    * def filePathFromSourceRoot = 'file:target/' + fileName + '.mrc'
    * def marcRecord = read('classpath:folijet/data-import/samples/mrc-files/marcBib.mrc')
    * def updatedMarcRecord = javaWriteData.modifyMarcRecord(marcRecord, '001', ' ', ' ', ' ', instanceHrid)

    * javaWriteData.writeByteArrayToFile(updatedMarcRecord, 'target/' + fileName + '.mrc')

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

  Scenario: MODSOURCE-898 - Update deleted instance using MARC-MARC matching
    # Step 1: Create MARC instance using default job profile for creating instance
    * def marcBibJson = read('classpath:folijet/data-import/samples/marcBib.mrc.json')
    # Update 245$a with timestamp to make each test run unique
    * def timestamp = '' + java.lang.System.currentTimeMillis()
    * def field245 = marcBibJson.fields.find(field => field['245'])
    * field245['245'].subfields.find(sf => sf.a).a = 'Summerland_MODSOURCE-898' + timestamp + ' /'
    Given call read('classpath:folijet/data-import/global/import-marc-json-and-verify.feature') { marcJsonObject: '#(marcBibJson)', fileName: 'marcBib', jobName: 'createInstance', actionStatus: 'CREATED' }

    # Step 2: Mark instance as deleted using DELETE /inventory/instances/{id}/mark-deleted
    Given path 'inventory/instances', instanceId, 'mark-deleted'
    And headers headersUser
    When method DELETE
    Then status 204

    # Step 3: Export MARC instance using data export
    # Create export mapping and job profiles for export
    * def exportMappingProfileName = 'MODSOURCE-898 Export mapping profile'
    * def dataExportMappingProfile = read('classpath:folijet/data-import/samples/profiles/data-export-mapping-profile.json')
    * def result = call createExportMappingProfile { mappingProfile: "#(dataExportMappingProfile)" }
    * def exportJobProfileName = 'MODSOURCE-898 Export job profile'
    * def result = call createExportJobProfile { jobProfileName: "#(exportJobProfileName)", dataExportMappingProfileId: "#(result.dataExportMappingProfileId)" }
    * def dataExportJobProfileId = result.dataExportJobProfileId

    # Export MARC record by instance id
    * def fileName = 'MODSOURCE-898-exported.mrc'
    * def result = call read(exportRecordFeature) { instanceId: "#(instanceId)", dataExportJobProfileId: "#(dataExportJobProfileId)", fileName: "#(fileName)" }

    # Step 4: Create MARC update job profile (MARC-MARC matching with 999ff$i)
    Given call read('classpath:folijet/data-import/global/setup-marc-to-marc-update-profile.feature') { profileName: 'MODSOURCE-898 MARC-MARC Update deleted', actionType: 'UPDATE', mappingOption: 'UPDATE' }
    * def jobProfileId = updateJobProfileId

    # Step 5: Make changes in exported file (add "upd" in 245 field)
    # Modify the exported MARC record using javaWriteData utility
    * def modifiedFileName = 'MODSOURCE-898-modified.mrc'
    * def modifiedMarcRecord = javaWriteData.modifyMarcRecord(result.exportedBinaryMarcRecord, '245', '1', '0', 'a', 'Summerland_MODSOURCE-898' + timestamp + ' upd /')
    * javaWriteData.writeByteArrayToFile(modifiedMarcRecord, modifiedFileName)

    # Step 6: Run import with created job profile and updated file
    * def filePathFromSourceRoot = 'file:' + modifiedFileName
    # Note: jobProfileId from Step 4 is used by customJob.json within the ImportRecord function
    Given call read(utilFeature + '@ImportRecord') { fileName: '#(modifiedFileName)', jobName: 'customJob', filePathFromSourceRoot: '#(filePathFromSourceRoot)' }

    # Verify job execution for update job execution
    * call read(completeExecutionFeature) { key: '#(sourcePath)' }
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'

    # Verify the record was successfully updated via MARC-MARC matching
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And match response.entries[0].sourceRecordActionStatus == "UPDATED"
    And match response.entries[0].relatedInstanceInfo.actionStatus == "UPDATED"
    * def instanceId = response.entries[0].relatedInstanceInfo.idList[0]

    # Verify the source record content was properly updated
    # Retrieving the source record by instanceId so that the latest generation of the instance is fetched
    # There will be two source records for the same instanceId, one for the original import and one for the update
    Given path 'source-storage/records', instanceId, 'formatted'
    And param idType = 'INSTANCE'
    And headers headersUser
    When method GET
    Then status 200
    ### MODINV-1232
    # Verify the response contains parsedRecord with content and leader
    Then match response.parsedRecord.content.fields == '#present'
    And match response.parsedRecord.content.leader == '#present'
    ### END
    * def sourceRecordId = response.id
    * def updatedParsedContent = response.parsedRecord.content
    * def finalMarcJson = (typeof updatedParsedContent === 'string') ? JSON.parse(updatedParsedContent) : updatedParsedContent
    # Verify the 245 field was updated with "upd"
    * def field245Final = finalMarcJson.fields.find(field => field['245'])
    And match field245Final['245'].subfields[0].a contains 'upd'

    # Verify instance and record remain marked as deleted
    Given call read('@VerifyInstanceAndRecordMarkedAsDeleted')
