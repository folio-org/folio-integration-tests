@parallel=false
Feature: Tests export hodings records

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 15000, count: 10 }


  Scenario Outline: test upload file and export flow for authority when related MARC_AUTHORITY records exist.
    Given path 'data-export/configuration'
    And request
      """
      {
        "key": "slice_size",
        "value": "100000"
      }
      """
    When method POST
    Then status 201

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
    * print 'File definition response:', response

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
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:1}
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

    Examples:
      | fileName                      | uploadFormat |
      | test-export-authority-csv.csv | csv          |

  Scenario Outline: test upload CQL file and export flow for authority uuids when related MARC_AUTHORITY records exist.
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
    And match response.jobExecutions[0].progress == {exported:1, failed:0, duplicatedSrs:0, total:1, readIds:1}
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

    #verify according to C805753
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
    And checker.checkLeaderStatus('d') == false

    Examples:
      | fileName                      | uploadFormat |
      | test-export-authority-cql.cql | cql          |

  #Negative scenarios

  Scenario Outline: test authority export should fail when not default authority job profiled specified.
    #should create file definition
    Given path 'data-export/file-definitions'
    And  def fileDefinitionId = uuid()
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

    #should not export records and complete export with FAIL status
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(defaultInstanceJobProfileId)','idType':'authority'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:0, duplicatedSrs:0, total:0, readIds:0}

    #error logs should be saved
    Given path 'data-export/logs'
    And param query = 'jobExecutionId==' + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.messagePlaceholder'
    And match errorLog.errorMessageValues[0] == 'For exporting authority records only the default authority job profile is supported'

    Examples:
      | fileName                      | uploadFormat |
      | test-export-authority-csv.csv | csv          |

  Scenario: clear storage folder
    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204
