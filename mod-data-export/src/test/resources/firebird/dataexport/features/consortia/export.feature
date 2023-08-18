Feature: Tests for uploading "uuids file" and exporting the records

  Background:
    * url baseUrl

    * call read(login) universityUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    * def okapiUserToken = okapitoken

    * def headersUser = {'x-okapi-tenant': '#(universityTenant)', 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = {'x-okapi-tenant': '#(universityTenant)', 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 6000, count: 5 }
    * def defaultInstanceJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

  Scenario Outline: test upload file and export flow for instance uuids with tenant in consortia
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
    And call pause 500

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
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
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
      | fileName                               | uploadFormat |
      | test-consortia-export-instance-csv.csv | csv          |