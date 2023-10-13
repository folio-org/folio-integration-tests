Feature: Util feature to import records

  Background:
    * url baseUrl

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * configure retry = { count: 120, interval: 1000 }

    * def samplePath = 'classpath:folijet/data-import/samples/'

    ## Util scenario accept fileName and jobName
    @ImportRecord
  Scenario: Import record
    * def fileName = fileName + '.mrc'
    * def jobName = jobName + '.json'

    ## Create upload definition
    Given path 'data-import/uploadDefinitions'
    And headers headersUser
    And request
    """
    {
     "fileDefinitions":[
        {
          "size": 1,
          "name": "#(fileName)"
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
    And param filename = fileName
    When method get
    Then status 200
    And def s3UploadKey = response.key
    And def s3UploadId = response.uploadId
    And def uploadUrl = response.url

    Given url uploadUrl
    And header Content-Type = 'application/octet-stream'
    And request read(samplePath + 'mrc-files/' + fileName)
    When method put
    Then status 200
    And def s3Etag = responseHeaders['ETag'][0]

    # reset
    * url baseUrl

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId, 'assembleStorageFile'
    And request { key: '#(s3UploadKey)', tags: ['#(s3Etag)'], uploadId: '#(s3UploadId)' }
    When method post
    Then status 204

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    # Initiate data import job
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = false
    And headers headersUser
    And request read(samplePath + 'jobs/' + jobName)
    When method post
    Then status 204

    # splitting process creates additional job executions for parent/child
    # so we need to query to get the correct job execution ID
    * call read('classpath:folijet/data-import/features/get-completed-job-execution-for-key.feature') { key: '#(s3UploadKey)' }

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error
