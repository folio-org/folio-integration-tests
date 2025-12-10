Feature: Tests export Linked Data records

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

  Scenario Outline: test upload file and export flow for instance UUIDs available as Linked Data.
    #import inventory instance into Linked Data module
    * configure headers = { 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*'  }
    * def inventoryUuid = '02368983-7a01-4a58-ae52-e03542ba2a38'
    Given path 'linked-data/inventory-instance/',inventoryUuid,'/import'
    When method POST
    Then status 201

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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultLinkedDataJobProfileId)'}
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
    And match response.link.split('?')[0].endsWith('.json') == true
    * def downloadLink = response.link

    #download link content should not be empty and should match expected graph structure
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'
    * string downloadContents = response
    * def firstLine = downloadContents.split('\\n')[0]
    * def rdf = JSON.parse(firstLine)
    * def notes = rdf.filter(x => x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Note'))
    * def inventoryUuidNoteId = notes.filter(x => x['http://www.w3.org/2000/01/rdf-schema#label'][0]['@value'] == 'FOLIO Inventory UUID')[0]['@id']
    * def localIds = rdf.filter(x => x['@type'].includes('http://id.loc.gov/ontologies/bibframe/Local'))
    * def inventoryUuidLocal = localIds.filter(x => x['http://id.loc.gov/ontologies/bibframe/note'][0]['@id'] == inventoryUuidNoteId)[0]
    And match inventoryUuidLocal['http://www.w3.org/1999/02/22-rdf-syntax-ns#value'][0]['@value'] == inventoryUuid

    Examples:
      | fileName                        | uploadFormat |
      | test-export-linked-data-csv.csv | csv          |

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204
