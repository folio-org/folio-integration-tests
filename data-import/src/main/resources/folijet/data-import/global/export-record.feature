@ignore
Feature: Util feature for MARC records export
  # parameters: instanceId, dataExportJobProfileId, fileName
  # returns: exported MARC record in binary format

  Background:
    * url baseUrl

  @exportRecord
  Scenario: Export record by instance id
    # Export MARC record by instance id
    * print 'Started exporting MARC record by instance id: ', __arg.instanceId, 'jobProfileId:', __arg.dataExportJobProfileId, 'fileName:', __arg.fileName
    Given path 'data-export/quick-export'
    And headers headersUser
    And request
      """
      {
        "jobProfileId": "#(__arg.dataExportJobProfileId)",
        "uuids": ["#(__arg.instanceId)"],
        "type": "uuid",
        "recordType": "INSTANCE",
        "fileName": "#(__arg.fileName)",
      }
      """
    When method POST
    Then status 200
    * def exportJobExecutionId = response.jobExecutionId

    # Return job execution by id
    Given path 'data-export/job-executions'
    And headers headersUser
    And param query = 'id==' + exportJobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress contains {exported: 1, failed: 0, duplicatedSrs: 0, total: 1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId

    # Return download link for file with exported record
    * call pause 1000
    Given path 'data-export/job-executions/',exportJobExecutionId ,'/download/',fileId
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
