Feature: Test job profiles

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables
    * json jobProfile = read('classpath:samples/job_profile.json')

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  Scenario: Test creating job profile

    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201
    And match response.id == '#present'
    And match response.name == '#present'
    And match response.userInfo == '#present'

  Scenario: Test update job profile

    Given path 'data-export/job-profiles', jobProfile.id
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    And request jobProfile
    And set jobProfile.name = 'Updated APITest-JobProfile'
    When method PUT
    Then status 204

  Scenario: Test get updated job profile

    Given path 'data-export/job-profiles', jobProfile.id
    When method GET
    Then status 200
    And match  response.name contains 'Updated APITest-JobProfile'

  Scenario: Test get job profile by query

    Given path 'data-export/job-profiles'
    And param query = 'id==' + jobProfile.id
    When method GET
    Then status 200
    And match  response.jobProfiles[0].id contains jobProfile.id
    And match  response.totalRecords == 1

  Scenario: Test get default job profile by id

    Given path 'data-export/job-profiles', defaultInstanceJobProfileId
    When method GET
    Then status 200
    Then print response
    And match  response.id contains defaultInstanceJobProfileId
    And match  response.name contains 'Default instances export job profile'
    And match  response.description contains 'Default instances export job profile'
    And match  response.mappingProfileId contains defaultInstanceMappingProfileId

  Scenario: Test update default job profile

    Given path 'data-export/job-profiles', defaultInstanceJobProfileId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    And request jobProfile
    And set jobProfile.id = defaultInstanceJobProfileId
    When method PUT
    Then status 403
    And match response contains 'Editing of default job profile is forbidden'

  Scenario: Test delete default job profile

    Given path 'data-export/job-profiles', defaultInstanceJobProfileId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 403
    And match response contains 'Deletion of default job profile is forbidden'

  Scenario: Test get only used job profiles

    Given path 'data-export/job-profiles'
    And param used = true
    When method GET
    Then status 200
    #should be 0 because no job executions
    And match  response.totalRecords == 0

  Scenario: Test get all job profiles

    Given path 'data-export/job-profiles'
    When method GET
    Then status 200
    #5 not used job profiles in total
    And match  response.totalRecords == 5

  Scenario Outline: Test used job profiles

    #First of all, need to perform data export to have 1 used job profile.

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
    And call pause 500

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.uploadFormat == '<uploadFormat>'
    And def jobExecutionId = response.jobExecutionId

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

    #data export was done, so now should be 1 used job profile
    Given path 'data-export/job-profiles'
    And param used = true
    When method GET
    Then status 200
    #verify that among 5 job profiles 1 is used
    And match  response.totalRecords == 1

    Examples:
      | fileName                     | uploadFormat |
      | test-export-instance-csv.csv | csv          |
