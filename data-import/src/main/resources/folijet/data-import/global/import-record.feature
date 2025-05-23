Feature: Util feature to import records

  Background:
    * url baseUrl
    * def importHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure retry = { count: 30, interval: 5000 }
    * def samplePath = 'classpath:folijet/data-import/samples/'

  ## Util scenario accept fileName and jobName
  @ImportRecord
  Scenario: Import record
    * def fileName = fileName + '.mrc'
    * def jobName = jobName + '.json'
    # Use __arg to only get parameters explicitly passed to this feature call
    * def passedParams = karate.get('__arg', {})
    * def filePathFromSourceRoot = passedParams.filePathFromSourceRoot ? passedParams.filePathFromSourceRoot : samplePath + 'mrc-files/' + fileName

    # Create upload definition and upload/assemble file
    * call read('classpath:folijet/data-import/global/common-data-import.feature') ({ fileName: fileName, filePathFromSourceRoot: filePathFromSourceRoot, uiKey: '' })

    # Initiate data import job
    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And headers importHeaders
    And param defaultMapping = false
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
