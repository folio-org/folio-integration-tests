Feature: Tests for uploading "uuids file" and exporting the records

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    # load variables
    * callonce variables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  #Positive scenarios

  Scenario Outline: test upload file and export flow.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':'#(<fileDefinitionId>)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
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
    And call pause 500

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(<fileDefinitionId>)','jobProfileId':'#(defaultJobProfileId)'}
    And request requestBody
    When method POST
    Then status 204
    And call pause 5000

    #should return job execution by id
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
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
      | fileName        | uploadFormat | fileDefinitionId    |
      | test-export-csv.csv | csv          | csvFileDefinitionId |
      | test-export-cql.cql | cql          | cqlFileDefinitionId |

  Scenario: error logs should be empty after successful scenarios
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Should return transformation fields
    Given path 'data-export/transformation-fields'
    When method GET
    Then status 200
    And assert response.transformationFields.length > 0

  Scenario: should clean expired jobs if exist and return 204
    Given path 'data-export/expire-jobs'
    When method GET
    Then status 204

  Scenario: should clean expired files if exist and return 204
    Given path 'data-export/clean-up-files'
    When method GET
    Then status 204

  #Negative scenarios

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
    And request karate.readAsString('classpath:samples/file-definition/test-export-csv.csv')
    When method POST
    Then status 200

    Given path 'data-export/export'
    And configure headers = headersUser
    And request {'fileDefinitionId':'#(testFileDefinitionId)', 'jobProfileId':#(uuid())}
    When method POST
    Then status 400

  Scenario: should fail export and return 400 when invalid file definition id specified
    Given path 'data-export/export'
    And request {'fileDefinitionId':#(uuid()), 'jobProfileId':'#(defaultJobProfileId)'}
    When method POST
    Then status 400