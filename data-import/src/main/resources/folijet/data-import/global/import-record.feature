Feature: Util feature to import records

  Background:
    * url baseUrl
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:folijet/data-import/samples/'

  ## Util scenario accept fileName and jobName
  @ImportRecord
  Scenario: Import record
    * def fileName = fileName + '.mrc'
    * def jobName = jobName + '.json'

    ## Upload marc file
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
    * def HfileId = response.fileDefinitions[0].id

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'files', fileId
    And headers headersUserOctetStream
    And request read(samplePath + 'mrc-files/' + fileName)
    When method post
    Then status 200

    Given path 'data-import/uploadDefinitions', uploadDefinitionId
    And headers headersUser
    When method get
    Then status 200
    * def uploadDefinition = $

    * def jobExecutionId = uploadDefinition.fileDefinitions[0].jobExecutionId

    Given path 'data-import/uploadDefinitions', uploadDefinitionId, 'processFiles'
    And param defaultMapping = false
    And headers headersUser
    And request read(samplePath + 'jobs/' + jobName)
    When method post
    Then status 204

    Given path 'change-manager/jobExecutions', jobExecutionId
    And headers headersUser
    And retry until response.status == 'COMMITTED' || response.status == 'ERROR'
    When method get
    Then status 200
    And def status = response.status

    # Take job execution logs
    Given path 'metadata-provider/jobLogEntries', jobExecutionId
    And headers headersUser
    When method get
    Then status 200
    And def errorMessage = response.entries[0].error