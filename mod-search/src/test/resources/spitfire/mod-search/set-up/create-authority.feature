@Ignore
Feature: Create new Authority record

  Background:
    * url baseUrl
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}
    * def samplePath = 'classpath:samples/test-data/'

  @CreateAuthority
  Scenario: Create MARC-AUTHORITY record
    * def personalAuthority = read(samplePath + 'authorities/personal-authority.json')
    * def corporateAuthority = read(samplePath + 'authorities/corporate-authority.json')
    * def meetingAuthority = read(samplePath + 'authorities/meeting-authority.json')
    * def personalTitleAuthority = read(samplePath + 'authorities/personal-title-authority.json')
    * def corporateTitleAuthority = read(samplePath + 'authorities/corporate-title-authority.json')
    * def meetingTitleAuthority = read(samplePath + 'authorities/meeting-title-authority.json')
    * def genreAuthority = read(samplePath + 'authorities/genre-authority.json')
    * def geographicAuthority = read(samplePath + 'authorities/geographic-authority.json')
    * def topicalAuthority = read(samplePath + 'authorities/topical-authority.json')
    * def uniformAuthority = read(samplePath + 'authorities/uniform-authority.json')

    Given path 'authority-storage/authorities'
    And request personalAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request corporateAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request meetingAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request personalTitleAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request corporateTitleAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request meetingTitleAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request genreAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request geographicAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request topicalAuthority
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request uniformAuthority
    When method POST
    Then status 201