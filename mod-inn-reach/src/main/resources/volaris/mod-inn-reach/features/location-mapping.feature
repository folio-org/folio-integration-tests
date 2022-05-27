@ignore
@parallel=false
Feature: Location mapping

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

    * def libraryId = 'a2709e94-954d-4800-bb97-8167fd712d0a'

    * def unknownLibraryId = 'ebb44070-df35-48de-af1c-9147cbb23dcf'
    * def unknownCentralServerId = 'f18c9e64-c2b7-415c-935e-84c7e200b48c'

    * def locationMappingPath1 = 'inn-reach/central-servers/' + centralServer1.id + '/libraries/' + libraryId + '/locations/location-mappings'
    * def locationMappingPath2 = 'inn-reach/central-servers/' + centralServer2.id + '/libraries/' + libraryId + '/locations/location-mappings'

  Scenario: Create and get location mappings
    * print 'Create Location mappings'
    Given path locationMappingPath1
    And request read(samplesPath + 'location-mapping/location-mappings.json')
    When method PUT
    Then status 204

    * print 'Get Location mappings'
    Given path locationMappingPath1
    When method GET
    Then status 200
    And match response.totalRecords == 2

    * def locationMappings = response.locationMappings
    And match locationMappings[0].locationId == '53cf956f-c1df-410b-8bea-27f712cca7c0'
    And match locationMappings[0].innReachLocationId == innReachLocation1

    And match locationMappings[1].locationId == 'fcd64ce1-6995-48f0-840e-89ffa2288371'
    And match locationMappings[1].innReachLocationId == innReachLocation2

  Scenario: Unknown central server
    * print 'Get Location mappings'
    Given path 'inn-reach/central-servers/' + unknownCentralServerId + '/libraries/' + libraryId + '/locations/location-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Unknown library
    * print 'Get Location mappings'
    Given path 'inn-reach/central-servers/' + centralServer1.id + '/libraries/' + unknownLibraryId + '/locations/location-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: No mappings found
    * print 'Get Location mappings'
    Given path locationMappingPath2
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Delete
    * print 'Delete mappings'
    * call read(featuresPath + 'inn-reach-location.feature@delete')
    * call read(featuresPath + 'central-server.feature@delete')

    Given path locationMappingPath1
    When method GET
    Then status 200
    And match response.totalRecords == 0

    Given path locationMappingPath2
    When method GET
    Then status 200
    And match response.totalRecords == 0


