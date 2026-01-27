@parallel=false
Feature: Test delete mapping profile

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables
    * json jobProfileWithCustomMappingToDelete = read('classpath:samples/job-profile-with-custom-mapping-to-delete.json')
    * json mappingProfileToDelete = read('classpath:samples/mapping-profile/mapping-profile-to-delete.json')
    * def mappingProfileToDeleteId = '77648404-54c1-11eb-ae93-0242ac130002'
    * def jobProfileWithCustomMappingToDeleteId = '77171c00-54bd-11eb-ae93-0242ac130002'

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  # Negative scenarios

  Scenario: Verify that locked mapping profile cannot be deleted

    Given path 'data-export/mapping-profiles'
    And request mappingProfileToDelete
    And set mappingProfileToDelete.locked = true
    When method POST
    Then status 201

    #delete mapping profile
    Given path 'data-export/mapping-profiles', mappingProfileToDeleteId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 500
    And match response contains 'This profile is locked. Please unlock the profile to proceed with editing/deletion.'

  Scenario: Verify that unlocked mapping profile cannot be deleted if there is at lease one job profile linked to it

    Given path 'data-export/mapping-profiles', mappingProfileToDeleteId
    * configure headers = headersUser
    When method GET
    Then status 200
    And def customMappingProfileToDelete = response

    Given path 'data-export/mapping-profiles', mappingProfileToDeleteId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    And request mappingProfileToDelete
    And set mappingProfileToDelete.locked = false
    When method PUT
    Then status 204

    #create job profile with linked mapping profile
    Given path 'data-export/job-profiles'
    * configure headers = headersUser
    And request jobProfileWithCustomMappingToDelete
    And set jobProfileWithCustomMappingToDelete.mappingProfileId = mappingProfileToDeleteId
    When method POST
    Then status 201

    #delete mapping profile
    Given path 'data-export/mapping-profiles', mappingProfileToDeleteId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 500
    And match response contains 'Cannot delete mapping profile linked to job profiles: [77171c00-54bd-11eb-ae93-0242ac130002].'

  # Positive scenarios

  Scenario: Verify that unlocked mapping profile without linked job profiles can be deleted

    #first, delete job profile with linked mapping profile
    Given path 'data-export/job-profiles', jobProfileWithCustomMappingToDeleteId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 204

    #delete mapping profile
    Given path 'data-export/mapping-profiles', mappingProfileToDeleteId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 204