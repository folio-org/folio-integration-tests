Feature: Test for suppressing fields

  Background:
    * url baseUrl
    * callonce login testUser
    * callonce loadTestVariables
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(customJobProfileSuppressId)','idType':'instance'}
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
    * string marc = response
    And match marc !contains '  atext'
    And match marc !contains '1 aPratchett'
    And match marc !contains 'ffib73eccf0-57a6-495e-898d-32b9b2210f2f'

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204