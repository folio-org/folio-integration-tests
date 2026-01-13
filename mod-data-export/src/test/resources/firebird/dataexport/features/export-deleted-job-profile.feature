@parallel=false
Feature: Test delete job profile

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables
    * json jobProfile = read('classpath:samples/job_profile_with_default_mapping.json')
    * json jobProfileWithCustomMapping = read('classpath:samples/job_profile_with_custom_mapping.json')
    * json mappingProfile = read('classpath:samples/mapping-profile/mapping_profile.json')

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  # Positive scenarios

  Scenario Outline: Verify that all exported files associated with deleted instance job profile were deleted from S3

    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201
    And def jobProfileIdToDelete = response.id
    And match jobProfileIdToDelete == '#present'

    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(jobProfileIdToDelete)','idType':'instance'}
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

    #delete job profile
    Given path 'data-export/job-profiles', jobProfileIdToDelete
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 204

    #should verify that file by downloadLink was removed from S3
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 500

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |

  Scenario Outline: Verify that mapping profile used with deleted job profile was not deleted

    Given path 'data-export/mapping-profiles'
    And request mappingProfile
    When method POST
    Then status 201
    And def customMappingProfileId = response.id

    Given path 'data-export/job-profiles'
    And request jobProfileWithCustomMapping
    When method POST
    Then status 201
    And def jobProfileIdToDelete = response.id
    And match jobProfileIdToDelete == '#present'

    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(jobProfileIdToDelete)','idType':'instance'}
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

    #delete job profile
    Given path 'data-export/job-profiles', jobProfileIdToDelete
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 204

    #verify that mapping profile used with deleted job profile was not deleted
    Given path 'data-export/mapping-profiles', customMappingProfileId
    And configure headers = headersUser
    When method GET
    Then status 200
    And match response.id == customMappingProfileId

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |

  Scenario Outline: Check whether all data export logs associated with the deleted job profile were not deleted

    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201
    And def jobProfileIdToDelete = response.id
    And def jobProfileNameToDelete = response.name
    And match jobProfileIdToDelete == '#present'

    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(jobProfileIdToDelete)','idType':'instance'}
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

    #delete job profile
    Given path 'data-export/job-profiles', jobProfileIdToDelete
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 204

    #check whether all data export logs associated with the deleted job profile were not deleted
    Given path 'data-export/job-executions'
    And configure headers = headersUser
    And param query = 'jobProfileName==' + jobProfileNameToDelete
    When method GET
    Then status 200
    And match response.totalRecords == 2

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |

  Scenario Outline: Verify that all error logs associated with the deleted job profile were deleted

    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201
    And def jobProfileIdToDelete = response.id
    And def jobProfileNameToDelete = response.name
    And match jobProfileIdToDelete == '#present'

    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':'#(fileDefinitionId)','fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
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
    And def requestBody = {'fileDefinitionId':'#(fileDefinitionId)','jobProfileId':'#(jobProfileIdToDelete)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    When method GET
    Then status 200
    And match response.jobExecutions[0].progress == {exported:1, failed:1, duplicatedSrs:0, total:2, readIds:2}

    #delete job profile
    Given path 'data-export/job-profiles', jobProfileIdToDelete
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 204

    #check whether all data export logs associated with the deleted job profile were not deleted
    Given path 'data-export/logs'
    And param query = 'jobExecutionId==' + jobExecutionId
    And configure headers = headersUser
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Examples:
      | fileName                             | uploadFormat |
      | test-export-instance-csv-invalid.csv | csv          |

  # Negative scenarios (attempt to delete locked job profile), to be completed