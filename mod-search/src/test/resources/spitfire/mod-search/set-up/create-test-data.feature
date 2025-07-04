Feature: Create new tenant and upload test data
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'}
    * configure retry = { count: 30, interval: 2000 }

    * def samplePath = 'classpath:samples/test-data/'

  Scenario: Create service points
    Given path 'service-points'
    And request read(samplePath + 'service-points-cd3.json')
    When method POST
    Then status 201

    Given path 'service-points'
    And request read(samplePath + 'service-points-online.json')
    When method POST
    Then status 201

  Scenario: Create institution
    Given path 'location-units/institutions'
    And request read(samplePath + 'institutions-ku.json')
    When method POST
    Then status 201

  Scenario: Create campuses
    Given path 'location-units/campuses'
    And request read(samplePath + 'campuses-online.json')
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request read(samplePath + 'campuses-city.json')
    When method POST
    Then status 201

  Scenario: Create libraries
    Given path 'location-units/libraries'
    And request read(samplePath + 'libraries-diku.json')
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request read(samplePath + 'libraries-online.json')
    When method POST
    Then status 201

  Scenario: Create locations
    Given path 'locations'
    And request read(samplePath + 'locations-main-library.json')
    When method POST
    Then status 201

    Given path 'locations'
    And request read(samplePath + 'locations-online.json')
    When method POST
    Then status 201

    Given path 'locations'
    And request read(samplePath + 'locations-orwig-ethno-cd.json')
    When method POST
    Then status 201

  Scenario: create statistical code type
    Given path 'statistical-code-types'
    And request read(samplePath + 'statistical-code-type.json')
    When method POST
    Then status 201

  Scenario: create statistical code
    Given path 'statistical-codes'
    And request read(samplePath + 'statistical-code.json')
    When method POST
    Then status 201

  Scenario: Create inventory instances
    Given path '/instance-storage/batch/synchronous'
    And request read(samplePath + 'instances.json')
    When method POST
    Then status 201

    # Wait until last instance is indexed
    Given path '/search/instances'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords == 17
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

  Scenario: Create Authority Source FIle
    Given path 'authority-source-files'
    And request read(samplePath + 'authorities/sourceFiles/AuthoritySourceFIle.json')
    When method POST
    Then status 201

    Given path 'authority-source-files'
    And request read(samplePath + 'authorities/sourceFiles/AuthoritySourceFIleSecond.json')
    When method POST
    Then status 201

    Given path 'authority-source-files'
    And request read(samplePath + 'authorities/sourceFiles/AuthoritySourceFIleThird.json')
    When method POST
    Then status 201

  Scenario: Create authorities
    * call read('create-authority.feature@CreateAuthority')

    Given path '/search/authorities'
    And param query = 'cql.allRecords=1'
    And retry until response.totalRecords > 0
    When method GET
    Then status 200

    Given path 'authority-storage/authorities'
    When method GET
    Then status 200
    And match response.totalRecords == 10

  Scenario: Link authority to an instance
    Given path '/links/instances/7e18b615-0e44-4307-ba78-76f3f447041c'
    And request read('classpath:samples/createLink.json')
    When method PUT
    Then status 204

  Scenario: Link authority to an instance
    Given path '/links/instances/8357ce3f-0364-42bd-bf5b-33d70a7e76cc'
    And request read('classpath:samples/createSecondLink.json')
    When method PUT
    Then status 204
