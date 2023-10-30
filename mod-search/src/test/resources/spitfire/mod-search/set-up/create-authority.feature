Feature: Create new Authority record

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}
    * def samplePath = 'classpath:samples/test-data/'

  @CreateAuthority
  Scenario: Create MARC-AUTHORITY record
    Given path 'authority-storage/authorities'
    And request karate.get('authorityDto', read(samplePath + 'authorities/personal-authority.json'))
    When method POST
    Then status 201