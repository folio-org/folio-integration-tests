Feature: Tests for file definitions

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

  Scenario Outline: test upload file and export flow.
    #should create file definition
    Given path 'data-export/file-definitions'
    * def fileDefinition = {'id':'#(<fileDefinitionId>)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
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
    And request karate.readAsString('classpath:samples/file-definition/test-export.<uploadFormat>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    * def jobExecutionId = response.jobExecutionId

    #should export instances and return 204
    Given path 'data-export/export'
    And request '{fileDefinitionId:#(<fileDefinitionId>),jobProfileId:#(defaultJobProfileId)}'
    When method POST
    Then status 204

    #should return job execution by id
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    When method GET
    Then status 200
    And match response.status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    * def fileId = response.uploadFormat == response.jobExecutions[0].exportedFiles[0].fileId

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #should return instance in marc format
    Given path downloadLink
    When method GET
    Then status 200
    And match response == karate.readAsString('classpath:test-data/expected.mrc)

    Examples:
      | fileName        | uploadFormat | fileDefinitionId    |
      | test-export.csv | csv          | csvFileDefinitionId |
      | test-export.cql | cql          | cqlFileDefinitionId |