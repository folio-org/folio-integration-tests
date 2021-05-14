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
    * def csvFileDefinitionId = '7e8abd2f-e516-4792-8ede-76b04a4d23ff'
    * def cqlFileDefinitionId = 'ee797299-580c-45da-ba3d-e78695e88847'
    * configure headers = headersUser

  Scenario Outline: should create file definition with <uploadFormat> file format and return 201
    Given path 'data-export/file-definitions'
    * def fileDefinition = {'id':'<fileDefinitionId>','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    Examples:
      | fileName        | uploadFormat | fileDefinitionId       |
      | test-export.csv | csv          | #(csvFileDefinitionId) |
      | test-export.cql | cql          | #(cqlFileDefinitionId) |


  Scenario Outline: should return file definition by id

    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    Examples:
      | fileDefinitionId    | uploadFormat |
      | csvFileDefinitionId | csv          |
      | cqlFileDefinitionId | cql          |

  Scenario Outline: should upload <uploadFormat> file by file definition id and return 200

    Given path 'data-export/file-definitions/',<id>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/test-export.<uploadFormat>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'

    Examples:
      | uploadFormat | id                  |
      | csv          | csvFileDefinitionId |
      | cql          | cqlFileDefinitionId |

