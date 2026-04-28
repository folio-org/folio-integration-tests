Feature: Set, get and delete preferred profile

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Set preferred profile for resourceType, verify it is returned on get and removed after delete
    * def monographProfileId = 3
    * def instanceResourceType = 'http://bibfra.me/vocab/lite/Instance'

    # Set preferred profile for Instance resource type
    Given path 'linked-data/profile/preferred'
    And request { "id": '#(monographProfileId)', "resourceType": '#(instanceResourceType)' }
    When method POST
    Then status 204

    # Get preferred profile and verify Monograph entry is returned
    Given path 'linked-data/profile/preferred'
    And param resourceType = instanceResourceType
    When method GET
    Then status 200

    * def monograph = karate.filter(response, function(x){ return x.name == 'Monograph' })[0]
    * match monograph.id == monographProfileId
    * match monograph.resourceType == instanceResourceType

    # Delete preferred profile for Instance resource type
    Given path 'linked-data/profile/preferred'
    And param resourceType = instanceResourceType
    When method DELETE
    Then status 204

    # Get preferred profile and verify it is removed
    Given path 'linked-data/profile/preferred'
    And param resourceType = instanceResourceType
    When method GET
    Then status 200
    * match response == []
