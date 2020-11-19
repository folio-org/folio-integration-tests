Feature: tests for mapping profile

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json,text/plain', 'x-okapi-token' : #(adminToken)}

  Scenario: get default mapping profile
    Given path 'data-export/mapping-profiles/25d81cbe-9686-11ea-bb37-0242ac130002'
    When method GET
    Then status 200

  Scenario: should return UnprocessableEntity response when post mapping profile with invalid transformations - invalid tag
    Given path 'data-export/mapping-profiles'
    * print read('classpath:test-data/mapping-profile/mp-transformation_invalid_tag.json')
    And def invalidMappingProfile = read('classpath:test-data/mapping-profile/mp-transformation_invalid_tag.json')
    And request invalidMappingProfile
    When method POST
    Then status 422

  Scenario: should return UnprocessableEntity response when post mapping profile with invalid transformations - invalid index
    Given path 'data-export/mapping-profiles'
    And def invalidMappingProfile = read('classpath:test-data/mapping-profile/mp-transformation_invalid_index.json')
    And request invalidMappingProfile
    When method POST
    Then status 422

  Scenario: should return UnprocessableEntity response when post mapping profile with invalid transformations - invalid subfield
    Given path 'data-export/mapping-profiles'
    And def invalidMappingProfile = read('classpath:test-data/mapping-profile/mp-transformation_invalid_subfield.json')
    And request invalidMappingProfile
    When method POST
    Then status 422

  Scenario: should return OK response when post mapping profile with valid transformations
    Given path 'data-export/mapping-profiles'
    And def validMappingProfile = read('classpath:test-data/mapping-profile/mp-valid_transformation.json')
    And set validMappingProfile.id = uuid()
    And set validMappingProfile.name = randomString(10)
    * print validMappingProfile
    And request validMappingProfile
    When method POST
    Then status 201




