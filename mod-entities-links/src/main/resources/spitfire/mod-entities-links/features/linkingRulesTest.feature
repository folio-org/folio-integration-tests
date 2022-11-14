Feature: linking-rules tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }
    * def samplePath = 'classpath:spitfire/mod-entities-links/features/samples'

  @Positive
  Scenario: Get instance to authority rules - Should match json rules
    * def jsonRules = read(samplePath + 'linking-rules.instance-authority.json')
    Given path '/linking-rules/instance-authority'
    When method GET
    Then status 200
    And match response == jsonRules