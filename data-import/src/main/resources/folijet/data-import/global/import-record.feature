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

    # Create upload definition and upload/assemble file
    * call read('classpath:folijet/data-import/global/common-data-import.feature') ({ fileName: fileName, filePathFromSourceRoot: samplePath + 'mrc-files/' + fileName, uiKey: '' })

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
