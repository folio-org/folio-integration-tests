Feature: Tests export hodings records

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 6000, count: 5 }

  #Positive scenarios

  Scenario Outline: test upload file and export flow for holding uuids when related MARC_HOLDING records exist.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':#(fileDefinitionId),'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.uploadFormat == '<uploadFormat>'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED' && response.sourcePath != null
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #download link content should not be empty
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'

    Examples:
      | fileName                                     | uploadFormat |
      | test-export-holding-with-marc-record-csv.csv | csv          |

  Scenario Outline: test should generate marc record on the fly when export holding without underlying MARC_HOLDING records.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id': '#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.uploadFormat == '<uploadFormat>'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED' && response.sourcePath != null
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED' && JSON.stringify(response.jobExecutions[0].progress) == '{"exported":1,"total":1,"failed":0}'
    When method GET
    Then status 200

    #error logs should be empty
    Given path 'data-export/logs?query=jobExecutionId=' + jobExecutionId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Examples:
      | fileName                                        | uploadFormat |
      | test-export-holding-without-marc-record-csv.csv | csv          |

  #Negative scenarios

  Scenario Outline: test holdings export should fail when not default holding job profiled specified.
    #should create file definition
    Given path 'data-export/file-definitions'
    And  def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.uploadFormat == '<uploadFormat>'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED' && response.sourcePath != null
    When method GET
    Then status 200

    #should not export records and complete export with FAIL status
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultInstanceJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:0, total:0}

    #error logs should be saved
    Given path 'data-export/logs?query=jobExecutionId=' + jobExecutionId
    And param query = "jobExecutionId=" + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.messagePlaceholder'
    And match errorLog.errorMessageValues[0] == 'For exporting holding records only the default holding job profile is supported'

    Examples:
      | fileName                    | uploadFormat |
      | test-export-holding-csv.csv | csv          |

  Scenario: test holdings export should fail when cql uploadFormat specified
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':#(fileDefinitionId),'fileName':'test_cql.cql', 'uploadFormat':'cql'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == 'cql'
    And def fileDefinitionId = response.id

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == 'cql'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/test-export-holding-csv.csv')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.uploadFormat == 'cql'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #should not export records and complete export with FAIL status
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':#(fileDefinitionId),'jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:0, total:0}

    #error logs should be saved
    Given path 'data-export/logs?query=jobExecutionId=' + jobExecutionId
    And param query = "jobExecutionId=" + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.uploadedFile.invalidExtension'
    And match errorLog.errorMessageValues[0] == 'Only csv format is supported for holdings export'


