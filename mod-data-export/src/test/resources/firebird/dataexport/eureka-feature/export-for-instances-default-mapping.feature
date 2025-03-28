Feature: Tests mapping instance to marc file and presence of necessary fields

  Background:
    * url baseUrl
    * callonce login testUser
    * callonce loadTestVariables
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }

  Scenario Outline: test should check record fields when source is FOLIO and file format is csv.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)', 'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
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

    #when follows download link marc file with necessary fields should be returned
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'
    And def Checker = Java.type("org.folio.utils.MarcFileInstanceFieldsExistenceChecker")
    And def checker = new Checker(response)
    And checker.checkLccn() == true
    And checker.checkCancelledSystemControlNumbers() == true
    And checker.checkIssn() == true
    And checker.checkUpc() == true
    And checker.checkInvalidUpc() == true
    And checker.checkIsmn() == true
    And checker.checkInvalidIssn() == true
    And checker.checkDoi() == true
    And checker.checkHandle() == true
    And checker.checkUrn() == true
    And checker.checkAsin() == true
    And checker.checkBnb() == true
    And checker.checkLocalIdentifier() == true
    And checker.checkOtherStandartIdentifier() == true
    And checker.checkStdEdNl() == true
    And checker.checkUkMac() == true
    And checker.checkPublisherDistributionNumber() == true
    And checker.checkCoden() == true
    And checker.checkSystemControlNumber() == true
    And checker.checkGpoItemNumber() == true
    And checker.checkReportNumber() == true
    And checker.checkUniformTitle() == true
    And checker.checkTitle() == true
    And checker.checkVariantTitle() == true
    And checker.checkFormerTitle() == true
    And checker.checkEdition() == true
    And checker.checkPlacePublisherPublicationDate() == true
    And checker.checkPublicationFrequency() == true
    And checker.checkText() == true
    And checker.checkPublicationRange() == true
    And checker.checkSeriesStatements() == true
    And checker.checkGeneralNote() == true
    And checker.checkSubjects() == true
    And checker.checkGenre() == true
    And checker.checkContributorPersonalName() == true
    And checker.checkContributorCorporateName() == true
    And checker.checkContributorMeetingName() == true
    And checker.checkElectronicAccessResourceRelationship() == true
    And checker.checkElectronicAccessVersionOfResourceRelationship() == true
    And checker.checkElectronicAccessRelatedResourceRelationship() == true
    And checker.checkElectronicAccessOtherRelationship() == true
    And checker.checkId() == true

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |

  Scenario Outline:  test should check record fields when source is FOLIO and file format is cql.
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

    #when follows download link marc file with necessary fields should be returned
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'
    And def Checker = Java.type("org.folio.utils.MarcFileInstanceFieldsExistenceChecker")
    And def checker = new Checker(response)
    And checker.checkLccn() == true
    And checker.checkCancelledSystemControlNumbers() == true
    And checker.checkIssn() == true
    And checker.checkUpc() == true
    And checker.checkInvalidUpc() == true
    And checker.checkIsmn() == true
    And checker.checkInvalidIssn() == true
    And checker.checkDoi() == true
    And checker.checkHandle() == true
    And checker.checkUrn() == true
    And checker.checkAsin() == true
    And checker.checkBnb() == true
    And checker.checkLocalIdentifier() == true
    And checker.checkOtherStandartIdentifier() == true
    And checker.checkStdEdNl() == true
    And checker.checkUkMac() == true
    And checker.checkPublisherDistributionNumber() == true
    And checker.checkCoden() == true
    And checker.checkSystemControlNumber() == true
    And checker.checkGpoItemNumber() == true
    And checker.checkReportNumber() == true
    And checker.checkUniformTitle() == true
    And checker.checkTitle() == true
    And checker.checkVariantTitle() == true
    And checker.checkFormerTitle() == true
    And checker.checkEdition() == true
    And checker.checkPlacePublisherPublicationDate() == true
    And checker.checkPublicationFrequency() == true
    And checker.checkText() == true
    And checker.checkPublicationRange() == true
    And checker.checkSeriesStatements() == true
    And checker.checkGeneralNote() == true
    And checker.checkSubjects() == true
    And checker.checkGenre() == true
    And checker.checkContributorPersonalName() == true
    And checker.checkContributorCorporateName() == true
    And checker.checkContributorMeetingName() == true
    And checker.checkElectronicAccessResourceRelationship() == true
    And checker.checkElectronicAccessVersionOfResourceRelationship() == true
    And checker.checkElectronicAccessRelatedResourceRelationship() == true
    And checker.checkElectronicAccessOtherRelationship() == true
    And checker.checkId() == true

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-cql.cql | cql          |

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204