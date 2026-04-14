@parallel=false
Feature: Test lock mapping profile

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables
    * json mappingProfile = read('classpath:samples/mapping-profile/mapping_profile.json')
    * def defaultInstanceMappingProfileId = '25d81cbe-9686-11ea-bb37-0242ac130002'
    * def mappingProfileIdToLock = '0b648404-54c1-11eb-ae93-0242ac130002'

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  # Positive scenarios
  Scenario: Verify that newly created mapping profile is unlocked by default
    Given path 'data-export/mapping-profiles'
    And request mappingProfile
    When method POST
    Then status 201
    And match response.locked == false
    And match response.lockedAt == '#notpresent'
    And match response.lockedBy == '#notpresent'

  Scenario: Verify that newly created mapping profile can be locked
    Given path 'data-export/mapping-profiles', mappingProfileIdToLock
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    And request mappingProfile
    And set mappingProfile.locked = true
    When method PUT
    Then status 204

    Given path 'data-export/mapping-profiles', mappingProfileIdToLock
    * configure headers = headersUser
    When method GET
    Then status 200
    And match response.locked == true
    And match response.lockedAt == '#present'
    And match response.lockedBy == '#present'

  Scenario: Verify that locked mapping profile can be unlocked
    Given path 'data-export/mapping-profiles', mappingProfileIdToLock
    When method GET
    Then status 200
    And def lockedMappingProfile = response

    Given path 'data-export/mapping-profiles', mappingProfileIdToLock
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    And request lockedMappingProfile
    And set lockedMappingProfile.locked = false
    When method PUT
    Then status 204

    Given path 'data-export/mapping-profiles', mappingProfileIdToLock
    * configure headers = headersUser
    When method GET
    Then status 200
    And match response.locked == false
    And match response.lockedAt == '#notpresent'
    And match response.lockedBy == '#notpresent'

  # Negative scenarios

  Scenario: Verify that default mapping profile cannot be locked

    Given path 'data-export/mapping-profiles', defaultInstanceMappingProfileId
    When method GET
    Then status 200
    And def defaultMappingProfile = response

    Given path 'data-export/mapping-profiles', defaultInstanceMappingProfileId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    And request defaultMappingProfile
    And set defaultMappingProfile.locked = true
    When method PUT
    Then status 403
    And match response contains 'Editing of default mapping profile is forbidden'

  Scenario: Verify that default mapping profile cannot be unlocked

    Given path 'data-export/mapping-profiles', defaultInstanceMappingProfileId
    When method GET
    Then status 200
    And def defaultMappingProfile = response

    Given path 'data-export/mapping-profiles', defaultInstanceMappingProfileId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'text/plain' }
    And request defaultMappingProfile
    And set defaultMappingProfile.locked = false
    When method PUT
    Then status 403
    And match response contains 'Editing of default mapping profile is forbidden'
