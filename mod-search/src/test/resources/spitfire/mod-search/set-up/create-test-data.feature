Feature: Create new tenant and upload test data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}
    * configure retry = { count: 30, interval: 2000 }

    * def samplePath = 'classpath:samples/test-data/'

  Scenario: Create inventory instances
    Given path '/instance-storage/batch/synchronous'
    And request read(samplePath + 'instances.json')
    When method POST
    Then status 201

    # Wait until last instance is indexed
    Given path '/search/instances'
    And param query = 'id=="af83c0ac-c3ba-4b11-95c8-4110235dec80"'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

  Scenario: Create inventory holdings
    Given path '/holdings-storage/batch/synchronous'
    And request read(samplePath + 'holdings.json')
    When method POST
    Then status 201

    Given path '/search/instances'
    And param query = 'holdings.id=="a663dea9-6547-4b2d-9daa-76cadd662272"'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

  Scenario: Create inventory items
    Given path '/item-storage/batch/synchronous'
    And request read(samplePath + 'items.json')
    When method POST
    Then status 201

    Given path '/search/instances'
    And param query = 'items.id==("100d10bf-2f06-4aa0-be15-0b95b2d9f9e3" or "7212ba6a-8dcf-45a1-be9a-ffaa847c4423")'
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

  Scenario: Create inventory authorities
    Given path 'authority-storage/authorities'
    And request read(samplePath + 'authorities/PersonalAuthority.json')
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request read(samplePath + 'authorities/CorporateAuthority.json')
    When method POST
    Then status 201

    Given path 'authority-storage/authorities'
    And request read(samplePath + 'authorities/MeetingAuthority.json')
    When method POST
    Then status 201

    Given path '/search/authorities'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords == 21
    When method GET
    Then status 200
