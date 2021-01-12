Feature: Test mapping profiles

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    # load variables
    * callonce variables
    * json mappingProfile = read('classpath:samples/mapping_profile.json')

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiAdminToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser

  Scenario: Test creating mapping profile

    Given path 'data-export/mapping-profiles'
    And request mappingProfile
    When method POST
    Then status 201
    And match response.id == '#present'
    And match response.name == '#present'
    And match response.userInfo == '#present'
    And match response.transformations == '#present'

  Scenario: Test update mapping profile

    Given path 'data-export/mapping-profiles', mappingProfile.id
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    And request mappingProfile
    And set mappingProfile.description = 'Updated mapping profile description'
    When method PUT
    Then status 204

  Scenario: Test get updated mapping profile

    Given path 'data-export/mapping-profiles', mappingProfile.id
    When method GET
    Then status 200
    And match  response.description contains 'Updated mapping profile description'

  Scenario: Test get mapping profile by query

    Given path 'data-export/mapping-profiles'
    And param query = 'id==' + mappingProfile.id
    When method GET
    Then status 200
    And match  response.mappingProfiles[0].id contains mappingProfile.id
    And match  response.totalRecords contains 1

  Scenario: Test get default mapping profile by id

    Given path 'data-export/mapping-profiles', defaultMappingProfileId
    When method GET
    Then status 200
    Then print response
    And match  response.id contains defaultMappingProfileId
    And match  response.recordTypes[0] contains 'INSTANCE'
    And match  response.name contains 'Default instance mapping profile'
    And match  response.description contains 'Default mapping profile for the inventory instance record'
    And match  response.outputFormat contains 'MARC'

  Scenario: Test update default mapping profile

    Given path 'data-export/mapping-profiles', defaultMappingProfileId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    And request mappingProfile
    And set mappingProfile.id = defaultMappingProfileId
    When method PUT
    Then status 403
    And match response contains 'Editing of default mapping profile is forbidden'

  Scenario: Test delete default mapping profile

    Given path 'data-export/mapping-profiles', defaultMappingProfileId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'text/plain' }
    When method DELETE
    Then status 403
    And match response contains 'Deletion of default mapping profile is forbidden'

