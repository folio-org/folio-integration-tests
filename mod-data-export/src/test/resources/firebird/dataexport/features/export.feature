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
    * configure retry = { interval: 3000, count: 5 }

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
      | test-export-instance-csv.csv | csv          | 'aab00a45-45b6-4d44-8fc6-0c6f96b8f798' |
      | test-export-instance-cql.cql | cql          | '1d900f47-8c58-432d-98c9-79aa46856c67' |

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
      | test-export-holding-csv.csv | csv          | 'f3aac6cd-3d73-48a2-8758-a4bb62e5ab10' |

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
      | instance_with_100_items.csv | csv          | 'd8d0de0a-2b2d-4563-a1fe-fbe26a8ac72f' |
      | instance_with_100_items.cql | cql          | '20dfe0d8-6d80-4793-a5c2-cf4a534a3f57' |

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
      | mixed_instances.csv | csv          | 'd28581c6-6e3d-487b-8317-a65712fed2d5' |
      | mixed_instances.cql | cql          | 'e1cb67a3-7e52-45bc-b9d1-06cdfde2abfa' |

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
      | test-export-holding-csv.csv | csv          | '40b0a614-3687-4467-b892-ea1886ba0d32' |

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
      | test-export-holding-without-marc-record-csv.csv | csv          | 'af92166e-1d1e-4c8f-91c7-f6d06c083956' |

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