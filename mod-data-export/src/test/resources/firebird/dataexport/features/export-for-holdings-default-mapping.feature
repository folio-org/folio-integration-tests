Feature: Tests mapping holdings to marc file and presence of necessary fields

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
    * configure retry = { interval: 30000, count: 20 }

  Scenario Outline: test should check record fields when source is FOLIO and file format is csv.
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
    And match response.jobExecutionId == '#present'
    And def jobExecutionId = response.jobExecutionId

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
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:1}
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #when follows download link marc file with necessary fields should be returned
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'
    And def Checker = Java.type("org.folio.utils.MarcFileHoldingFieldsExistenceChecker")
    And def checker = new Checker(response)
    And checker.checkForHrId() == true
    And checker.checkForInstanceId() == true
    And checker.checkForHoldingStatementField() == true
    And checker.checkForHoldingStatementSubField() == true
    And checker.checkForHoldingStatementNoteSubField() == true
    And checker.checkForHoldingStatementForSupplementsField() == true
    And checker.checkForHoldingStatementForSupplementsSubField() == true
    And checker.checkForHoldingStatementForSupplementsNoteSubField() == true
    And checker.checkForHoldingStatementForIndexesField() == true
    And checker.checkForHoldingStatementForIndexesSubField() == true
    And checker.checkForHoldingStatementForIndexesNoteSubField() == true
    And checker.checkForHoldingUuidField() == true
    And checker.checkForHoldingUuidSubfield() == true


    Examples:
      | fileName                                                         | uploadFormat |
      | test-export-holding-default.csv                                  | csv          |

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204
