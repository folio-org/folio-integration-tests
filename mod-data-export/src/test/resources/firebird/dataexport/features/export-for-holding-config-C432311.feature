Feature: Verify configured limit of exported file size - Holdings (UUID)

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

  Scenario Outline: test should generate marc record on the fly when export holding without underlying MARC_HOLDING records.
    #should create file definition

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "1"
      }
      """
    When method POST
    Then status 201

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

    #should export holdings and return 204
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
    And match response.jobExecutions[0].progress.exported == 4
    And match response.jobExecutions[0].progress.failed == 0
    And match response.jobExecutions[0].progress.duplicatedSrs == 0
    And match response.jobExecutions[0].progress.total == 4
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * print response
    * def downloadLink = response.link

    #when follows download link marc file with necessary fields should be returned
    Given url downloadLink
    When method GET
    Then status 200
    * print response
    And match response == '#notnull'
    * def ByteArrayInputStream = Java.type('java.io.ByteArrayInputStream')
    * def ZipInputStream = Java.type('java.util.zip.ZipInputStream')
    * def IOUtils = Java.type('org.apache.commons.io.IOUtils')
    * def bais = new ByteArrayInputStream(responseBytes)
    * def zis = new ZipInputStream(bais)
    # read first entry in the zip
    * def entry = zis.getNextEntry()
    * def unzippedResponse = IOUtils.toString(zis, 'UTF-8')
    * print unzippedResponse
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
      | fileName                                        | uploadFormat |
      | test-export-config-holding-csv.csv              | csv          |

  Scenario Outline: test should generate marc record on the fly when export holding without underlying MARC_HOLDING records.
    #should create file definition

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "4"
      }
      """
    When method POST
    Then status 201

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

    #should export holdings and return 204
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
    * def files = response.jobExecutions[0].exportedFiles
    * match each files[*].fileName contains 'mrc'
    #    And match response.jobExecutions[0].progress == {exported:4, failed:0, duplicatedSrs:0, total:4, readIds:2}
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for holdings of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * print response
    * def downloadLink = response.link

    Examples:
      | fileName                                        | uploadFormat |
      | test-export-config-holding-csv.csv              | csv          |

  Scenario Outline: test should generate marc record on the fly when export holding without underlying MARC_HOLDING records.
    #should create file definition

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "3"
      }
      """
    When method POST
    Then status 201

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

    #should export holdings and return 204
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
    And match response.jobExecutions[0].progress.exported == 4
    And match response.jobExecutions[0].progress.failed == 0
    And match response.jobExecutions[0].progress.duplicatedSrs == 0
    And match response.jobExecutions[0].progress.total == 4
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * print response
    * def downloadLink = response.link

    #when follows download link marc file with necessary fields should be returned
    Given url downloadLink
    When method GET
    Then status 200
    * print response
    And match response == '#notnull'
    * def ByteArrayInputStream = Java.type('java.io.ByteArrayInputStream')
    * def ZipInputStream = Java.type('java.util.zip.ZipInputStream')
    * def IOUtils = Java.type('org.apache.commons.io.IOUtils')
    * def bais = new ByteArrayInputStream(responseBytes)
    * def zis = new ZipInputStream(bais)
    # read first entry in the zip
    * def entry = zis.getNextEntry()
    * def unzippedResponse = IOUtils.toString(zis, 'UTF-8')
    * print unzippedResponse
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
      | fileName                                        | uploadFormat |
      | test-export-config-holding-csv.csv              | csv          |

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204