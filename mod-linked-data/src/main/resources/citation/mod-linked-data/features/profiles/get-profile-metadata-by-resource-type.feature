Feature: Get Profile Metadata by Resource Type

  Background:
    * url baseUrl

    * call login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    * configure headers = testUserHeaders

  @Positive
  Scenario: Get profile metadata by resourceType Instance and verify entries returned
    Given path 'linked-data/profile/metadata'
    And param resourceType = 'http://bibfra.me/vocab/lite/Instance'
    When method GET
    Then status 200

    * def monograph = karate.filter(response, function(x){ return x.name == 'Monograph' })[0]
    * match monograph.resourceType == 'http://bibfra.me/vocab/lite/Instance'

    * def rareBooks = karate.filter(response, function(x){ return x.name == 'Rare Books' })[0]
    * match rareBooks.resourceType == 'http://bibfra.me/vocab/lite/Instance'

    * def serials = karate.filter(response, function(x){ return x.name == 'Serials' })[0]
    * match serials.resourceType == 'http://bibfra.me/vocab/lite/Instance'

  @Positive
  Scenario: Get profile metadata by resourceType Work and verify entries returned
    Given path 'linked-data/profile/metadata'
    And param resourceType = 'http://bibfra.me/vocab/lite/Work'
    When method GET
    Then status 200

    * def books = karate.filter(response, function(x){ return x.name == 'Books' })[0]
    * match books.resourceType == 'http://bibfra.me/vocab/lite/Work'

    * def serialsWork = karate.filter(response, function(x){ return x.name == 'Serials Work' })[0]
    * match serialsWork.resourceType == 'http://bibfra.me/vocab/lite/Work'

  @Positive
  Scenario: Get profile metadata by resourceType Hub and verify entries returned
    Given path 'linked-data/profile/metadata'
    And param resourceType = 'http://bibfra.me/vocab/lite/Hub'
    When method GET
    Then status 200

    * def hubs = karate.filter(response, function(x){ return x.name == 'Hubs' })[0]
    * match hubs.resourceType == 'http://bibfra.me/vocab/lite/Hub'
