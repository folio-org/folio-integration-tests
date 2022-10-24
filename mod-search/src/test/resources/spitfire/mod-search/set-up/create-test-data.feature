Feature: Create new tenant and upload test data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}
    * configure retry = { count: 30, interval: 2000 }

    * def samplePath = 'classpath:samples/test-data/'

  Scenario: Enable tenant features
    Given path '/search/config/features'
    And request '{"feature":"browse.cn.intermediate.values","enabled":true}'
    When method POST
    Then status 200

  Scenario: Create inventory instances
    Given path '/instance-storage/batch/synchronous'
    And request read(samplePath + 'instances.json')
    When method POST
    Then status 201

    # Wait until last instance is indexed
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords == 15
    When method GET
    Then status 200

  Scenario: Create inventory holdings
    Given path '/holdings-storage/batch/synchronous'
    And request read(samplePath + 'holdings.json')
    When method POST
    Then status 201

    Given path '/search/instances'
    And param query = 'holdings.id=*'
    And param expandAll = true
    And retry until response.totalRecords == 15
    When method GET
    Then status 200

  Scenario: Create inventory items
    Given path '/item-storage/batch/synchronous'
    And request read(samplePath + 'items.json')
    When method POST
    Then status 201

    Given path '/search/instances'
    And param query = 'items.id=*'
    And param expandAll = true
    And retry until response.totalRecords == 15
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
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    
  Scenario: Link authority to an instance
    Given path '/links/instances/7e18b615-0e44-4307-ba78-76f3f447041c'
    And request read('classpath:samples/createLink.json')
    When method PUT
    Then status 204
