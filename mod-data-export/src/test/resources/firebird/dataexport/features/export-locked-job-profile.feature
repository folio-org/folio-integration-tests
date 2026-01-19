@parallel=false
Feature: Test lock job profile

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables
    * json jobProfile = read('classpath:samples/job_profile_with_default_mapping.json')
    * json jobProfileWithCustomMapping = read('classpath:samples/job_profile_with_custom_mapping.json')
    * json mappingProfile = read('classpath:samples/mapping-profile/mapping_profile.json')
    * def defaultInstanceJobProfileId = '6f7f3cd7-9f24-42eb-ae91-91af1cd54d0a'

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  # Positive scenarios
  Scenario: Verify that newly created job profile is unlocked by default
    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201
    And def jobProfileIdToLock = response.id
    And match response.lock == false

  Scenario: Verify that newly created job profile can be locked
    Given path 'data-export/job-profiles', jobProfileIdToLock
    And request jobProfile
    And set jobProfile.lock = true
    When method PUT
    Then status 204

    Given path 'data-export/job-profiles', jobProfileIdToLock
    When method GET
    Then status 200
    And match response.lock == true

  # Negative scenarios
  Scenario: Verify that already locked job profile cannot be locked again

    # Try to lock already locked job profile
    Given path 'data-export/job-profiles', jobProfileIdToLock
    And request jobProfile
    And set jobProfile.lock = true
    When method PUT
    Then status 500
    And match response == 'Profile is already locked.'

  Scenario: Verify that default job profile cannot be locked

    Given path 'data-export/job-profiles', defaultInstanceJobProfileId
    When method GET
    Then status 200
    And def defaultJobProfile = response

    Given path 'data-export/job-profiles', defaultInstanceJobProfileId
    And request defaultJobProfile
    And set defaultJobProfile.lock = true
    When method PUT
    Then status 403
    And match response contains 'Editing of default job profile is forbidden'

  Scenario: Verify that default job profile cannot be unlocked

    Given path 'data-export/job-profiles', defaultInstanceJobProfileId
    And request defaultJobProfile
    And set defaultJobProfile.lock = false
    When method PUT
    Then status 403
    And match response contains 'Editing of default job profile is forbidden'