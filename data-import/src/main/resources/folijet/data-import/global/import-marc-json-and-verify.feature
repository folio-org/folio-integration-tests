Feature: Import MARC JSON and Verify

  Background:
    * url baseUrl
    * call read('classpath:folijet/data-import/global/auth.feature')
    * call read('classpath:folijet/data-import/global/common-functions.feature')

  @ImportMarcJsonAndVerify
  Scenario: Import MARC JSON record and verify
    # Handle parameters with defaults
    * def passedParams = karate.get('__arg', {})
    * def marcJsonObject = passedParams.marcJsonObject
    * def jobName = passedParams.jobName
    * def actionStatus = passedParams.actionStatus
    * def fileName = passedParams.fileName || 'marcRecord_' + java.lang.System.currentTimeMillis()
    * def filePathFromSourceRoot = passedParams.filePathFromSourceRoot

    # Validate that jobProfileId is available (required for customJob.json and similar job files)
    * if (jobName == 'customJob' && typeof jobProfileId == 'undefined') karate.fail('jobProfileId must be defined when using customJob - call @SetupUpdateJobProfile first')

    # Initialize Java utilities
    * def marcConverter = Java.type('test.java.MarcConverter')
    * def javaWriteData = Java.type('test.java.WriteData')

    # Generate file names
    * def binaryFileName = fileName + '.mrc'
    # Use custom path if provided, otherwise default to target directory
    * def defaultFilePathFromSourceRoot = 'file:target/' + binaryFileName
    * def finalFilePathFromSourceRoot = filePathFromSourceRoot || defaultFilePathFromSourceRoot

    # Convert MARC JSON object to string and then to binary format
    * def marcJsonString = JSON.stringify(marcJsonObject)
    * def marcBinaryData = marcConverter.convertJsonStringToBinary(marcJsonString)

    # Write binary data to appropriate directory
    * def targetPath = filePathFromSourceRoot ? filePathFromSourceRoot.replace('file:', '') : 'target/' + binaryFileName
    * javaWriteData.writeByteArrayToFile(marcBinaryData, targetPath)

    # Import file using the job profile ID (jobProfileId must be available in scope)
    # The jobName parameter should reference a job JSON file that uses #(jobProfileId)
    Given call read(utilFeature + '@ImportRecord') { fileName: '#(fileName)', jobName: '#(jobName)', filePathFromSourceRoot: '#(finalFilePathFromSourceRoot)' }
    Then match status != 'ERROR'

    # Verify job execution
    * call read(completeExecutionFeature) { key: '#(sourcePath)' }
    * def jobExecution = response

    # If job failed, get error details from job log entries
    * if (jobExecution.status == 'ERROR') karate.call('classpath:folijet/data-import/global/check-job-log-entries.feature', { jobExecutionId: jobExecution.id, headersUser: headersUser })

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
