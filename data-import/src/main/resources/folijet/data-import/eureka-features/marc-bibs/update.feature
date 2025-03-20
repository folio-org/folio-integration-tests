Feature: Update Instance, Holdings & Items

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/eureka-global/auth.feature')
    * call read('classpath:folijet/data-import/eureka-global/common-functions.feature')
    * configure retry = { interval: 5000, count: 30 }
    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'
    * def javaWriteData = Java.type('test.java.WriteData')

  Scenario: FAT-939 Modify MARC_Bib, update Instances, Holdings, and Items 1
    * print 'Match MARC-to-MARC, modify MARC_Bib and update Instance, Holdings, and Items'

    # Create MARC-to-MARC mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-MARC-to-MARC-mapping-profile.json')
    When method POST
    Then status 201
    * def marcToMarcMappingProfileId = $.id

    # Create MARC-to-Instance mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-MARC-to-Instance-mapping-profile.json')
    When method POST
    Then status 201
    * def marcToInstanceMappingProfileId = $.id

    # Create MARC-to-Holdings mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-MARC-to-Holdings-mapping-profile.json')
    When method POST
    Then status 201
    * def marcToHoldingsMappingProfileId = $.id

    # Create MARC-to-Item mapping profile
    Given path 'data-import-profiles/mappingProfiles'
    And headers headersUser
    * def mappingProfile = read('update-samples/FAT-939-MARC-to-Item-mapping-profile.json')
    * replace mappingProfile.epoch = epoch
    And request mappingProfile
    When method POST
    Then status 201
    * def marcToItemMappingProfileId = $.id

    # Create action profile for MODIFY MARC bib
    * def mappingProfileEntityId = marcToMarcMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'MODIFY'
    * def folioRecord = 'MARC_BIBLIOGRAPHIC'
    * def userStoryNumber = 'FAT-939'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def marcBibActionProfileId = $.id

    # Create action profile for UPDATE Instance
    * def mappingProfileEntityId = marcToInstanceMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'INSTANCE'
    * def userStoryNumber = 'FAT-939'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def instanceActionProfileId = $.id

    # Create action profile for UPDATE Holdings
    * def mappingProfileEntityId = marcToHoldingsMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'HOLDINGS'
    * def userStoryNumber = 'FAT-939'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def holdingsActionProfileId = $.id

    # Create action profile for UPDATE Item
    * def mappingProfileEntityId = marcToItemMappingProfileId
    Given path 'data-import-profiles/actionProfiles'
    And headers headersUser
    * def profileAction = 'UPDATE'
    * def folioRecord = 'ITEM'
    * def userStoryNumber = 'FAT-939: PTF'
    * def folioRecordNameAndDescription = folioRecord + ' action profile for ' + userStoryNumber
    And request read('classpath:folijet/data-import/samples/samples_for_upload/create_action_profile.json')
    When method POST
    Then status 201
    * def itemActionProfileId = $.id

    # Create match profile for MARC-to-MARC 001 to 001
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-MARC-to-MARC-001-to-001-match-profile.json')
    When method POST
    Then status 201
    * def marcToMarcMatchProfileId = $.id

    # Create match profile for MARC-to-Holdings 901a to Holdings HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-MARC-to-Holdings-901a-to-Holdings-HRID-match-profile.json')
    When method POST
    Then status 201
    * def marcToHoldingsMatchProfileId = $.id

    # Create match profile for MARC-to-Item 902a to Item HRID
    Given path 'data-import-profiles/matchProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-MARC-to-Item-902a-to-Item-HRID-match-profile.json')
    When method POST
    Then status 201
    * def marcToItemMatchProfileId = $.id

    # Create job profile
    Given path 'data-import-profiles/jobProfiles'
    And headers headersUser
    And request read('update-samples/FAT-939-job-profile.json')
    When method POST
    Then status 201
    * def jobProfileId = $.id

    # Create file definition id for data-export
    * def fileDefinitionId = call uuid
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request
      """
      {
        "id": "#(fileDefinitionId)",
        "size": 2,
        "fileName": "FAT-939.csv",
        "uploadFormat": "csv",
      }
      """
    When method POST
    Then status 201
    And match $.status == 'NEW'
    * def fileDefinitionId = $.id

    # Upload file by created file definition id
    Given path 'data-export/file-definitions/', fileDefinitionId, '/upload'
    And headers headersUserOctetStream
    And request karate.readAsString('classpath:folijet/data-import/samples/csv-files/FAT-939.csv')
    When method POST
    Then status 200
    * def exportJobExecutionId = $.jobExecutionId

    # Wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And headers headersUser
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    # Given path 'instance-storage/instances?query=id==c1d3be12-ecec-4fab-9237-baf728575185'
    Given path 'instance-storage/instances'
    And headers headersUser
    And param query = 'id==' + 'c1d3be12-ecec-4fab-9237-baf728575185'
    When method GET
    Then status 200

    # Should export instances and return 204
    Given path 'data-export/export'
    And headers headersUser
    And request
      """
      {
        "fileDefinitionId": "#(fileDefinitionId)",
        "jobProfileId": "#(defaultJobProfileId)"
      }
      """
    When method POST
    Then status 204

    # Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress contains { exported:1, failed:0, duplicatedSrs:0, total:1 }
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 1000

    # Return download link for instance of uploaded file
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = $.link
    * def fileName = 'FAT-939-1.mrc'

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    And javaWriteData.writeByteArrayToFile(response, fileName)

    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-939-1.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read(commonImportFeature) {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'file:FAT-939-1.mrc'}

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
          "id": "#(jobProfileId)",
          "name": "FAT-939: Job profile",
          "dataType": "MARC"
        }
      }
      """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read(completeExecutionFeature) { key: '#(sourcePath)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'
