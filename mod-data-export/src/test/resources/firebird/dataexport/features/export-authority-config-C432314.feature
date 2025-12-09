@parallel=false
Feature: Verify configured limit of exported file size - Authorities (UUID)

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

  Scenario Outline: setting configuration slice_size to 1, test upload file and export flow for authority uuids when related MARC_AUTHORITY records exist.
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

    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultAuthorityJobProfileId)','idType':'authority'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].progress == {exported:3, failed:0, duplicatedSrs:0, total:3, readIds:3}
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    Given url downloadLink
    When method GET
    Then status 200
    * print response
    And match response == '#notnull'

    * def ByteArrayInputStream = Java.type('java.io.ByteArrayInputStream')
    * def ZipInputStream = Java.type('java.util.zip.ZipInputStream')
    * def IOUtils = Java.type('org.apache.commons.io.IOUtils')
    * def ByteArrayOutputStream = Java.type('java.io.ByteArrayOutputStream')

    * def bais = new ByteArrayInputStream(responseBytes)
    * def zis = new ZipInputStream(bais)

    # Extract files
    * def fileNames = []
    * def marcFiles = []

    * eval
      """
      var entry = zis.getNextEntry();
      while (entry != null) {
        var name = entry.getName();
        if (name.includes('.')) {
          fileNames.push(name);
          var baos = new ByteArrayOutputStream();
          IOUtils.copy(zis, baos);
          marcFiles.push(baos.toByteArray());
        }
        entry = zis.getNextEntry();
      }
      """

    * print 'File names in ZIP:', fileNames
    * print 'Number of MARC files in ZIP:', marcFiles.length

    Examples:
      | fileName                                    | uploadFormat |
      | test-export-config-authority-csv.csv        | csv          |

  Scenario Outline: test upload file and export flow for authority uuids when related MARC_AUTHORITY records exist.
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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultAuthorityJobProfileId)','idType':'authority'}
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
    And match response.jobExecutions[0].progress == {exported:3, failed:0, duplicatedSrs:0, total:3, readIds:3}
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
      | fileName                                    | uploadFormat |
      | test-export-config-authority-csv.csv        | csv          |

  Scenario Outline: test upload file and export flow for authority uuids when related MARC_AUTHORITY records exist.
    #should create file definition

    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "2"
      }
      """
    When method POST
    Then status 201

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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultAuthorityJobProfileId)','idType':'authority'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].progress == {exported:3, failed:0, duplicatedSrs:0, total:3, readIds:3}
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    Given url downloadLink
    When method GET
    Then status 200
    * print response
    And match response == '#notnull'
    * def ByteArrayInputStream = Java.type('java.io.ByteArrayInputStream')
    * def ZipInputStream = Java.type('java.util.zip.ZipInputStream')
    * def IOUtils = Java.type('org.apache.commons.io.IOUtils')
    * def ByteArrayOutputStream = Java.type('java.io.ByteArrayOutputStream')

    * def bais = new ByteArrayInputStream(responseBytes)
    * def zis = new ZipInputStream(bais)

    # Extract files
    * def fileNames = []
    * def marcFiles = []

    * eval
      """
      var entry = zis.getNextEntry();
      while (entry != null) {
        var name = entry.getName();
        if (name.includes('.')) {
          fileNames.push(name);
          var baos = new ByteArrayOutputStream();
          IOUtils.copy(zis, baos);
          marcFiles.push(baos.toByteArray());
        }
        entry = zis.getNextEntry();
      }
      """

    * print 'File names in ZIP:', fileNames
    * print 'Number of MARC files in ZIP:', marcFiles.length

    Examples:
      | fileName                                    | uploadFormat |
      | test-export-config-authority-csv.csv        | csv          |

  Scenario: reset configuration to default
    #reset slice_size back to default value to avoid affecting other tests
    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "1000"
      }
      """
    When method POST
    Then status 201

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204