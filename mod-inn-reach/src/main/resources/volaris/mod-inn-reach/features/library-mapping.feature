@ignore
@parallel=false
Feature: Library mapping

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

    * print 'Prepare INN Reach locations'
    * callonce read(featuresPath + 'inn-reach-location.feature@create')
    * def innReachLocation1 = response.locations[0].id
    * def innReachLocation2 = response.locations[1].id

  Scenario: Add and get library mappings
    * print 'Add library mappings'
    * def libraryMappingPath = 'inn-reach/central-servers/' + centralServer1.id + '/libraries/location-mappings'
    Given path libraryMappingPath
    And request read(samplesPath + 'library-mapping/library-mappings.json')
    When method PUT
    Then status 204

    * print 'Get Library mappings'
    Given path libraryMappingPath
    When method GET
    Then status 200
    And match response.totalRecords == 2

    * def libraryMappings = response.libraryMappings
    And match libraryMappings[0].id == '13eb7b80-6de7-40b6-94c6-f5b3575b42d2'
    And match libraryMappings[0].libraryId == '5d78803e-ca04-4b4a-aeae-2c63b924518b'
    And match libraryMappings[0].innReachLocationId == innReachLocation1

    And match libraryMappings[1].id == 'ba27baee-59a6-408b-b289-0c268dad5e63'
    And match libraryMappings[1].libraryId == 'c2549bb4-19c7-4fcc-8b52-39e612fb7dbe'
    And match libraryMappings[1].innReachLocationId == innReachLocation2

  Scenario: Unknown central server
    * print 'Get Library mappings'
    Given path 'inn-reach/central-servers/' + '#(uuid())' + '/libraries/location-mappings'
    When method GET
    Then status 404

  Scenario: No mappings found
    * print 'Get Library mappings'
    Given path 'inn-reach/central-servers/' + centralServer2.id + '/libraries/location-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Delete
    * print 'Delete mappings'
    * call read(featuresPath + 'inn-reach-location.feature@delete')
    * call read(featuresPath + 'central-server.feature@delete')

    Given path 'inn-reach/central-servers/' + centralServer1.id + '/libraries/location-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path 'inn-reach/central-servers/' + centralServer2.id + '/libraries/location-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0


