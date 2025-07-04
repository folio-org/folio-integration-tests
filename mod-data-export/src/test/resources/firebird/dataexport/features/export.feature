Feature: Tests for uploading "uuids file" and exporting the records

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

  #Positive scenarios

  Scenario Outline: test upload file and export flow for instance uuids.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
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
    And match response.jobExecutionId == '#present'
    And def jobExecutionId = response.jobExecutionId
    And call pause 500

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED' && response.sourcePath != null
    When method GET
    Then status 200

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultInstanceJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204


    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:1}
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #error logs should be empty after successful scenarios

    Given path 'data-export/logs'
    And param query = 'jobExecutionId==' + jobExecutionId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    #download link content should not be empty
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |

  Scenario: error logs should be empty after successful scenarios
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario Outline: test handling records that exceeds its max size of 99999 characters length, only invalid instances file
    #create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.jobExecutionId == '#present'
    And def jobExecutionId = response.jobExecutionId

    #upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED' && response.sourcePath != null
    When method GET
    Then status 200

    #run export and verify 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(customJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #waiting for export job completion
    * pause(20000)

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:1, duplicatedSrs:0, total:1, readIds:1}

    Examples:
      | fileName                    | uploadFormat |
      | instance_with_100_items.csv | csv          |

  Scenario Outline: test handling records 1 valid and 1 invalid instance in a file
    #create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>','uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.jobExecutionId == '#present'
    And def jobExecutionId = response.jobExecutionId

    #waiting for file definition creation
    * pause(20000)

    #upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED' && response.sourcePath != null
    When method GET
    Then status 200

    #run export and verify 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(customJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #waiting for export job completion
    * pause(20000)

    #should return job execution by id and wait until the job status will be 'COMPLETED_WITH_ERRORS'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    And match response.jobExecutions[0].progress == {exported:1, failed:1, duplicatedSrs:0, total:2, readIds:2}

    Examples:
      | fileName            | uploadFormat |
      | mixed_instances.csv | csv          |

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

  Scenario: should not create a file definition and return 422 when invalid format is posted.
    Given path 'data-export/file-definitions'
    * def fileDefinition = {'fileName':'invalid.txt'}
    And request fileDefinition
    When method POST
    Then status 422
    And match response == 'Incorrect file extension of invalid.txt'

  Scenario: should fail export and return 404 when invalid file definition id specified
    Given path 'data-export/export'
    And request {'fileDefinitionId':#(uuid()), 'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'instance'}
    When method POST
    Then status 404
    And match response contains 'Unable to find'

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204
