Feature: Util feature to import records

  Background:
    * url baseUrl

    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * configure retry = { count: 30, interval: 5000 }

    * def samplePath = 'classpath:folijet/data-import/samples/'

  ## Util scenario accept fileName and jobName
  @ImportRecord
  Scenario: Import record
    * def fileName = __arg.fileName + '.mrc'
    * def jobName = jobName + '.json'
    * def filePathFromSourceRoot = (typeof __arg.filePathFromSourceRoot !== 'undefined' && __arg.filePathFromSourceRoot) ? __arg.filePathFromSourceRoot : samplePath + 'mrc-files/' + fileName

    # Create upload definition and upload/assemble file
    * call read('classpath:folijet/data-import/global/common-data-import.feature') ({ fileName: fileName, filePathFromSourceRoot: filePathFromSourceRoot, uiKey: '' })

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
    And retry until response.entries.length > 0
    When method get
    Then status 200
    And match response.entries == '#array'
    * def errorMessage = response.entries[0].error
