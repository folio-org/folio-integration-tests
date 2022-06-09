Feature: Data Import Log deletion tests

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersHost = { 'Host': '#(baseUrl)'  }

    * configure retry = { interval: 15000, count: 5 }

    * def javaDemo = Java.type('test.java.WriteData')

    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

  Scenario: FAT-1616 Deleting data-import logs
    * print 'FAT-1616 Deleting data-import logs'
    * def fileName = 'FAT-1616.mrc'
    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    ## Create file definition for FAT-1616.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-937.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def fileId = result.response.fileDefinitions[0].id
    * def jobExecutionId = result.response.fileDefinitions[0].jobExecutionId
    * def metaJobExecutionId = result.response.metaJobExecutionId
    * def createDate = result.response.fileDefinitions[0].createDate
    * def uploadedDate = result.response.fileDefinitions[0].createDate
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    ## Process file
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
                "name": "#(fileName)",
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
            "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
            "name": "Default - Create instance and SRS MARC Bib",
            "dataType": "MARC"
          }
        }
        """
    When method POST
    Then status 204

    ## verify job execution for data-import
    * call pause 180000
    * call read('classpath:folijet/data-import/features/get-completed-job-execution.feature@getJobWhenJobStatusCompleted') { jobExecutionId: '#(jobExecutionId)'}
    * def jobExecution = response
    And assert jobExecution.status == 'COMMITTED'
    And assert jobExecution.uiStatus == 'RUNNING_COMPLETE'
    And assert jobExecution.progress.current == 1
    And assert jobExecution.progress.total == 1
    And match jobExecution.runBy == '#present'
    And match jobExecution.progress == '#present'

    # verify that needed entities created
    * call pause 10000
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].instanceActionStatus == 'CREATED'
    And match response.entries[0].error == '#notpresent'

    * def sourceRecordId = response.entries[0].sourceRecordId

    # retrieve instance hrid from record
    Given path 'source-storage/records', sourceRecordId
    And headers headersUser
    When method GET
    Then status 200
    And match response.externalIdsHolder.instanceId == '#present'
    * def instanceHrid = response.externalIdsHolder.instanceHrid

    # verify that real instance was created with specific fields in inventory and retrieve instance id
    Given path 'inventory/instances'
    And headers headersUser
    And param query = 'hrid==' + instanceHrid
    When method GET
    Then status 200
    And assert response.totalRecords == 1
    And match response.instances[0].title == '#present'
    And assert response.instances[0].identifiers[0].identifierTypeId == 'c858e4f2-2b6b-4385-842b-60732ee14abb'
    And assert response.instances[0].identifiers[0].value == '2020031972'
    And assert response.instances[0].identifiers[1].identifierTypeId == '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef'
    And assert response.instances[0].identifiers[1].value == '(OCoLC)ybp16851676'
    And assert response.instances[0].notes[0].instanceNoteTypeId == '86b6e817-e1bc-42fb-bab0-70e7547de6c1'
    And assert response.instances[0].notes[0].note == 'Includes bibliographical references and index'
    And assert response.instances[0].notes[0].staffOnly == false
    And match response.instances[0].subjects contains  "Diseases--Religious aspects--Christianity"
    And match response.instances[0].subjects !contains "United States"

    ## delete job execution by id
    Given path '/change-manager/jobExecutions'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And headers headersUser
    And request
    """
    {
      "ids":
      [
        "#(jobExecutionId)"
      ]
    }
    """
    When method DELETE
    Then status 200
    And assert response.jobExecutionDetails[0].jobExecutionId == jobExecutionId
    And assert response.jobExecutionDetails[0].isDeleted == true

    ## verify job execution for data-import is not present
    * call pause 5000
    Given path '/change-manager/jobExecutions', jobExecutionId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And headers headersUser
    When method GET
    Then status 404