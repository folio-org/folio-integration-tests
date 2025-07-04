Feature: init data for mod-data-export

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  Scenario: create custom mapping profile
    * def mappingProfile = read('classpath:samples/mapping-profile/mapping_profile_with_many_fields.json')
    Given path 'data-export/mapping-profiles'
    And request mappingProfile
    When method POST
    Then status 201

  Scenario: create custom job profile
    * def jobProfile = read('classpath:samples/mapping-profile/job_profile_with_many_fields.json')
    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201

  Scenario: create custom mapping profile with suppression
    * def mappingProfile = read('classpath:samples/mapping-profile/mapping_profile_with_suppress.json')
    Given path 'data-export/mapping-profiles'
    And request mappingProfile
    When method POST
    Then status 201

  Scenario: create custom job profile with suppression
    * def jobProfile = read('classpath:samples/mapping-profile/job_profile_with_suppress.json')
    Given path 'data-export/job-profiles'
    And request jobProfile
    When method POST
    Then status 201
