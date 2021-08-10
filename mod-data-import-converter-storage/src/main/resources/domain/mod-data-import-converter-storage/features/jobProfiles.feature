Feature: Job Profiles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all profiles
    Given path 'data-import-profiles', 'jobProfiles'
    When method GET
    Then status 200

  @Undefined
  Scenario: FAT-936 Create JobProfile for Instance, Holdings, Items creation
    * print 'Create mapping profiles, create action profiles and link them to corresponding mapping profiles, create JobProfile'