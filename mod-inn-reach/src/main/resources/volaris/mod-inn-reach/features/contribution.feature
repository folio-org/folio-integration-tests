@ignore
@parallel=false
Feature: Contribution

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

  @Undefined
  Scenario: Get current contribution by server id
    * print 'Get current contribution by server id'

  Scenario: Get empty contribution history by server id

    * print 'Get empty contribution history by server id'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/contributions/history'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Get contribution history by server id

    * print 'Get contribution history by server id'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/contributions/history'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Start initial contribution
    * print 'Create material type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/create-material-type-mappings.json")
    When method PUT
    Then status 204

    * print 'Prepare INN Reach locations'
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "scdes",
      "description": "location 1"
     }
    """
    When method POST
    Then status 201
    * def innReachLocation1 = $.id

    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "plgen",
      "description": "location 2"
     }
    """
    When method POST
    Then status 201
    * def innReachLocation2 = $.id
    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "xxdes",
      "description": "location 3"
     }
    """
    When method POST
    Then status 201
    * def innReachLocation3 = $.id

    Given path 'inn-reach/locations'
    And request
    """
     {
      "code": "yydes",
      "description": "location 4"
     }
    """
    When method POST
    Then status 201
    * def innReachLocation4 = $.id

    * print 'Add library mappings'
    * def libraryMappingPath = 'inn-reach/central-servers/' + centralServer1.id + '/libraries/location-mappings'
    Given path libraryMappingPath
    And request read(samplesPath + 'library-mapping/library-mappings1.json')
    When method PUT
    Then status 204

    Given path 'inn-reach/central-servers/', centralServer1.id, '/contributions'
    When method POST
    Then status 201
