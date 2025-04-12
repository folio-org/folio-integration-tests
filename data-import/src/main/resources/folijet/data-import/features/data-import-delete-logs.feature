Feature: Data Import Log deletion tests

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }

    * configure retry = { interval: 15000, count: 5 }

    * def javaDemo = Java.type('test.java.WriteData')

    * def defaultJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

  Scenario: FAT-1616 Deleting data-import logs
    * print 'FAT-1616 Deleting data-import logs'
    * def fileName = 'FAT-1616.mrc'
    * def randomNumber = callonce random
    * def uiKey = fileName + randomNumber

    # Create file definition for FAT-1616.mrc-file
    * print 'Before Forwarding : ', 'uiKey : ', uiKey, 'name : ', fileName
    * def result = call read('classpath:folijet/data-import/global/common-data-import.feature') {headersUser: '#(headersUser)', headersUserOctetStream: '#(headersUserOctetStream)', uiKey : '#(uiKey)', fileName: '#(fileName)', 'filePathFromSourceRoot' : 'classpath:folijet/data-import/samples/mrc-files/FAT-937.mrc'}

    * def uploadDefinitionId = result.response.fileDefinitions[0].uploadDefinitionId
    * def sourcePath = result.response.fileDefinitions[0].sourcePath

    # Process file
    Given path '/data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = 'false'
    And headers headersUser
    And request
    """
        {
          "uploadDefinition": "#(result.uploadDefinition)",
          "jobProfileInfo": {
            "id": "e34d7b92-9b83-11eb-a8b3-0242ac130003",
            "name": "Default - Create instance and SRS MARC Bib",
            "dataType": "MARC"
          }
        }
        """
    When method POST
    Then status 204

    # Verify job execution for data-import
    * call read('classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature@getJobWhenJobStatusCompleted') { key: '#(sourcePath)' }
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
    And retry until response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    When method GET
    Then status 200
    And assert response.entries[0].sourceRecordActionStatus == 'CREATED'
    And assert response.entries[0].relatedInstanceInfo.actionStatus == 'CREATED'
    And match response.entries[0].error == ''


    # Delete job execution by id
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

    # verify job execution for data-import is not present
    * call pause 5000
    Given path '/change-manager/jobExecutions', jobExecutionId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And headers headersUser
    When method GET
    Then status 404
