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

