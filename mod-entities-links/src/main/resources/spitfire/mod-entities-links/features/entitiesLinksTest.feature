Feature: mod-entities-links tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * def samplePath = 'classpath:spitfire/mod-quick-marc/features/samples/links'
    * def authorityId = karate.properties['authorityId']
    * def instanceId = karate.properties['instanceId']

  Scenario: Create link
    Given path 'links/instances', instanceId
    And request read(samplePath + 'createLink')
    And headers headersUser
    When method PUT
    Then status 200

    Given path 'links/instances', instanceId
    And headers headersUser
    When method GET
    Then status 200
