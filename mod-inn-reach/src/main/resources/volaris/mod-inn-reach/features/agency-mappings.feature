@parallel=false
Feature: Agency mappings

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Create central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

  Scenario: Create, get, update, delete agency mappings by server id
    * print 'Create agency mapping'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/agency-mappings'
    And request read(samplesPath + "agency-mapping/create-agency-mapping-request.json")
    When method PUT
    Then status 204

    * print 'Get agency mapping'
    Given path 'inn-reach/central-servers/', centralServer1.id, '/agency-mappings'
    When method GET
    Then status 200

    * def mappingResponse = $
    And match mappingResponse.libraryId == "1a551e37-af8a-40f5-b25e-0837db791429"
    And match mappingResponse.locationId == "ab6a8c69-ee1a-4b52-a881-dc86da6be857"
    And match mappingResponse.localServers[0].localCode == "5htxv"
    And match mappingResponse.localServers[0].libraryId == "86dc48c5-9bea-4006-bb43-82f250089651"
    And match mappingResponse.localServers[0].locationId == "edb00dae-2735-4e38-bd41-69427295fdbe"
    And match mappingResponse.localServers[0].agencyCodeMappings[0].agencyCode == "5zxcv"
    And match mappingResponse.localServers[0].agencyCodeMappings[0].libraryId == "22dcf77c-08ef-43ac-a254-4d3f996a0de9"
    And match mappingResponse.localServers[0].agencyCodeMappings[0].locationId == "8c0f7109-2f56-41ab-b2fd-7e326a9323dc"

    * print 'Update agency mapping'
    Given path 'inn-reach/central-servers/', centralServer1.id, '/agency-mappings'
    And request read(samplesPath + "agency-mapping/update-agency-mapping-request.json")
    When method PUT
    Then status 204

    Given path 'inn-reach/central-servers/', centralServer1.id, '/agency-mappings'
    When method GET
    Then status 200

    * def mappingResponse = $
    And match mappingResponse.locationId == "0a9853b9-684e-441d-b052-b275b3613b8d"
    And match mappingResponse.localServers[0].localCode == "1asdf"
    And match mappingResponse.localServers[0].libraryId == "ce0b8609-25be-48da-96be-96ef04973178"
    And match mappingResponse.localServers[0].agencyCodeMappings[0].libraryId == "da308f5e-ea26-40ea-9949-c6c9cab9b006"
    And match mappingResponse.localServers[0].agencyCodeMappings[1].locationId == "a174be47-1049-4c0d-ab16-4b2eddde52bc"

    * print 'Delete agency mapping'
    Given path 'inn-reach/central-servers/', centralServer1.id, '/agency-mappings'
    And request read(samplesPath + "agency-mapping/delete-agency-mapping-request.json")
    When method PUT
    Then status 204

    Given path 'inn-reach/central-servers/', centralServer1.id, '/agency-mappings'
    When method GET
    Then status 200

    * def mappingResponse = $
    * print mappingResponse.localServers
    And assert mappingResponse.localServers.length == 0

  Scenario: Failed to get non-existing agency mapping
    * print 'Get non-existing agency mapping'
    Given path 'inn-reach/central-servers/', centralServer2.id, '/agency-mappings'
    When method GET
    Then status 404

  Scenario: Failed to create material type mapping with not valid data
    * print 'Create material type mapping with not valid data'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/agency-mappings'
    And request read(samplesPath + "agency-mapping/create-agency-mapping-bad-request.json")
    When method PUT
    Then status 400

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')
