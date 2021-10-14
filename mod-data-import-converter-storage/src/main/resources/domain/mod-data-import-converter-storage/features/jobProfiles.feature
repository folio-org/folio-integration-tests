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
  Scenario: Build Profile Snapshot Wrapper POST on /data-import-profiles/jobProfileSnapshots/{profileId}
    * print 'Create mapping, action, match and job profiles, link them accordingly, build profile snapshot wrapper, verify it is successful'

  @Undefined
  Scenario: Should no build profile with static match as primary match
    * print 'Create mapping and action profile, then create match profile with match on static value and try to assemble them in job profile'