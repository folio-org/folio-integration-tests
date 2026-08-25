@ignore
Feature: Util feature for MARC authority records export
  # parameters: authorityIds (array of UUIDs), fileName
  # returns: exportedBinaryMarcRecord - exported MARC authority records in binary format
  #
  # global/export-record.feature exports instances through data-export/quick-export, which only
  # accepts recordType INSTANCE. Authorities are exported through a CSV file definition instead.

  Background:
    * url baseUrl
    * configure retry = { count: 30, interval: 5000 }

  @exportAuthorityRecords
  Scenario: Export authority records by id
    * print 'Started exporting MARC authority records:', __arg.authorityIds, 'fileName:', __arg.fileName

    * def defaultAuthorityExportJobProfileId = '56944b1c-f3f9-475b-bed0-7387c33620ce'
    * def fileDefinitionId = uuid()
    * def csvFileName = __arg.fileName + '.csv'

    # Create file definition for the list of authority ids to export
    Given path 'data-export/file-definitions'
    And headers headersUser
    And request { id: '#(fileDefinitionId)', fileName: '#(csvFileName)', uploadFormat: 'csv' }
    When method POST
    Then status 201
    And match response.status == 'NEW'

    # Upload the authority ids to export, one per line
    * def authorityIdsCsv = __arg.authorityIds.join('\n')
    Given path 'data-export/file-definitions', fileDefinitionId, 'upload'
    And headers headersUserOctetStream
    And request authorityIdsCsv
    When method POST
    Then status 200
    * def exportJobExecutionId = response.jobExecutionId

    # Trigger the export
    Given path 'data-export/export'
    And headers headersUser
    And request { fileDefinitionId: '#(fileDefinitionId)', jobProfileId: '#(defaultAuthorityExportJobProfileId)', idType: 'authority' }
    When method POST
    Then status 204

    # Wait for any terminal state, so a failed export reports the real reason straight away instead
    # of retrying until the access token expires
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until karate.match(response.jobExecutions[0].status, '#regex COMPLETED|COMPLETED_WITH_ERRORS|FAIL').pass
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress.failed == 0
    And match response.jobExecutions[0].progress.exported == karate.sizeOf(__arg.authorityIds)
    * def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    # Return download link for the file with the exported records
    * call pause 1000
    Given path 'data-export/job-executions/', exportJobExecutionId, '/download/', fileId
    And headers headersUser
    When method GET
    Then status 200
    * def downloadLink = response.link

    # Download exported *.mrc file
    Given url downloadLink
    And headers headersUser
    When method GET
    Then status 200
    * def exportedBinaryMarcRecord = response
