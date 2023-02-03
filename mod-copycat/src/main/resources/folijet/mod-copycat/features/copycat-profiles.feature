Feature: COPYCAT

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def copycat_profile = read('classpath:samples/copycat_profile.json')

  @Positive
  Scenario: POST 'copycat/profiles' should return 200
    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method POST
    Then status 201

  @Positive
  Scenario: POST 'copycat/profiles' if allowedCreateJobProfileIds or allowedUpdateJobProfileIds is null then it should be populated with default job profile id
    * def copycat_profile_empty_allowed_lists = copycat_profile
    * remove copycat_profile_empty_allowed_lists.allowedCreateJobProfileIds
    * remove copycat_profile_empty_allowed_lists.allowedUpdateJobProfileIds

    Given path 'copycat', 'profiles'
    And request copycat_profile_empty_allowed_lists
    When method POST
    Then status 201
    And match response.allowedCreateJobProfileIds[0] == copycat_profile_empty_allowed_lists.createJobProfileId
    And match response.allowedUpdateJobProfileIds[0] == copycat_profile_empty_allowed_lists.updateJobProfileId

  @Positive
  Scenario: POST 'copycat/profiles' should return 422 if some of required fields is not specified
    * def invalid_copycat_profile = copycat_profile
    * remove invalid_copycat_profile.name

    Given path 'copycat', 'profiles'
    And request invalid_copycat_profile
    When method POST
    Then status 422

  @Positive
  Scenario: GET 'copycat/profiles' should return list of profiles
    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method POST
    Then status 201

    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method GET
    Then status 200
    And assert response.totalRecords > 0
    And assert response.profiles.length > 0

  @Positive
  Scenario: GET 'copycat/profiles' by id should return profile
    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method POST
    Then status 201

    * def profileId = response.id

    Given path 'copycat', 'profiles', profileId
    And request copycat_profile
    When method GET
    Then status 200
    And match response.id == profileId

  @Positive
  Scenario: PUT 'copycat/profiles' should update profile
    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method POST
    Then status 201

    * def profileId = response.id
    * def updatedCopycatProfile = copycat_profile
    * set updatedCopycatProfile.name = 'updated profile'

    Given path 'copycat', 'profiles', profileId
    And request updatedCopycatProfile
    When method PUT
    Then status 204

    Given path 'copycat', 'profiles', profileId
    And request copycat_profile
    When method GET
    Then status 200
    And match response.id == profileId
    And match response.name == updatedCopycatProfile.name

  @Positive
  Scenario: PUT 'copycat/profiles' with invalid profile should return 422
    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method POST
    Then status 201

    * def profileId = response.id
    * def invalid_copycat_profile = copycat_profile
    * remove invalid_copycat_profile.name

    Given path 'copycat', 'profiles', profileId
    And request invalid_copycat_profile
    When method PUT
    Then status 422

  @Positive
  Scenario: DELETE 'copycat/profiles' should delete profile
    Given path 'copycat', 'profiles'
    And request copycat_profile
    When method POST
    Then status 201

    * def profileId = response.id

    Given path 'copycat', 'profiles', profileId
    When method DELETE
    Then status 204

    Given path 'copycat', 'profiles', profileId
    And request copycat_profile
    When method GET
    Then status 404