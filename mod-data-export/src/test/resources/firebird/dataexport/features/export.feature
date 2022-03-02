Feature: Tests for uploading "uuids file" and exporting the records

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
    * configure retry = { interval: 3000, count: 10 }

  #Positive scenarios

  Scenario Outline: test upload file and export flow for instance uuids.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'
    And call pause 500

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #error logs should be empty after successful scenarios
    Given path 'data-export/logs?query=jobExecutionId=' + jobExecutionId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    #download link content should not be empty
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'

    Examples:
      | fileName                     | uploadFormat | fileDefinitionId                       |
      | test-export-instance-csv.csv | csv          | 'b882e94d-ffd8-4ef7-baee-f950099223d9' |
      | test-export-instance-cql.cql | cql          | 'a6147567-9577-4d2c-b1ef-cb96066f1684' |

  Scenario Outline: test upload file and export flow for holding uuids when related MARC_HOLDING records exist.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId

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
      | fileName                    | uploadFormat | fileDefinitionId                       |
      | test-export-holding-csv.csv | csv          | '85b46f94-452b-4094-899d-03b239e69d31' |

  Scenario: error logs should be empty after successful scenarios
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario Outline: test handling records that exceeds its max size of 99999 characters length, only invalid instances file
    #create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #run export and verify 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(customJobProfileId)','idType':'instance'}
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
    And match response.jobExecutions[0].progress == {exported:0, failed:1, total:1}

    Examples:
      | fileName                    | uploadFormat | fileDefinitionId                       |
      | instance_with_100_items.csv | csv          | '66c16ca2-b3da-4783-a8c2-5d30094221fc' |
      | instance_with_100_items.cql | cql          | 'dc9dbb48-d54b-4b79-9041-30fee39f7f70' |

  Scenario Outline: test handling records that exceeds its max size of 99999 characters length, 1 valid and 1 invalid instance in a file
    #create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>','uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #run export and verify 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(customJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED_WITH_ERRORS'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    And match response.jobExecutions[0].progress == {exported:1, failed:1, total:2}

    Examples:
      | fileName            | uploadFormat | fileDefinitionId                       |
      | mixed_instances.csv | csv          | '472dd53f-a535-4a9d-9ea4-f11425c413d6' |
      | mixed_instances.cql | cql          | '89a9d426-3666-457e-8c7b-7dd4cb3f3275' |

  Scenario: error logs should not be empty after export scenarios with failed records presented
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords != 0


  Scenario: Should return transformation fields
    Given path 'data-export/transformation-fields'
    When method GET
    Then status 200
    And assert response.transformationFields.length > 0

  #Negative scenarios

  Scenario Outline: test holdings export should fail when not default holding job profiled specified.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #should not export records and complete export with FAIL status
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'holding'}
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
      | fileName                    | uploadFormat | fileDefinitionId                       |
      | test-export-holding-csv.csv | csv          | '420b3c16-824a-4ee3-86bd-0bd5c59d0059' |

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
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == 'cql'
    And match response.sourcePath == '#present'
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
    And match errorLog.errorMessageCode == 'error.messagePlaceholder'
    And match errorLog.errorMessageValues[0] == 'Only csv format is supported for holdings export'

  Scenario Outline: test should generate marc record on the fly when export holding without underlying MARC_HOLDING records.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}

    #error logs should be empty
    Given path 'data-export/logs?query=jobExecutionId=' + jobExecutionId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Examples:
      | fileName                                        | uploadFormat | fileDefinitionId                       |
      | test-export-holding-without-marc-record-csv.csv | csv          | 'b58916fb-7fc2-4417-bda1-d0a0f4ac1da1' |

  Scenario: should not create a file definition and return 422 when invalid format is posted.
    Given path 'data-export/file-definitions'
    * def fileDefinition = {'fileName':'invalid.txt'}
    And request fileDefinition
    When method POST
    Then status 422
    And match response == 'File name extension does not corresponds csv format'

  Scenario: export should fail and return 400 when invalid job profile specified
    Given path 'data-export/file-definitions'
    And request {'fileName':'test.csv'}
    When method POST
    Then status 201
    And def testFileDefinitionId = response.id

    Given path 'data-export/file-definitions/',testFileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/test-export-instance-csv.csv')
    When method POST
    Then status 200

    Given path 'data-export/export'
    And configure headers = headersUser
    And request {'fileDefinitionId':'#(testFileDefinitionId)', 'jobProfileId':#(uuid()),'idType':'instance'}
    When method POST
    Then status 400
    And match response contains 'JobProfile not found with id'

  Scenario: should fail export and return 400 when invalid file definition id specified
    Given path 'data-export/export'
    And request {'fileDefinitionId':#(uuid()), 'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'instance'}
    When method POST
    Then status 400
    And match response contains 'File definition not found with id'

    #Clear storage folder

    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204