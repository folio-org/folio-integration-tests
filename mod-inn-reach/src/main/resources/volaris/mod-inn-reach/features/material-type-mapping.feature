@ignore
@parallel=false
Feature: Material type mapping

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

  @create
  Scenario: Create material type mappings

    * print 'Create material type mapping 1'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-1.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "337e0bfa-9781-44b8-ac90-5bd459623fb9"
    And match response.centralItemType == 1
    And match response.id == '#notnull'

    * print 'Create material type mapping 2'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-2.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "2541dcf3-ba2f-4175-b32b-63078cbb9342"
    And match response.centralItemType == 2
    And match response.id == '#notnull'

  Scenario: Failed to create material type mapping with not valid data

    * print 'Create material type mapping with not valid data'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-bad-request.json")
    When method POST
    Then status 400

  Scenario: Failed to create existed material type mapping

    * print 'Create existed material type mapping'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-1.json")
    When method POST
    Then status 409

  Scenario: Get material type mappings by server id

    * print 'Get material type mappings by server id'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 2

  Scenario: Get empty list of material type mappings

    * print 'Get material type mappings by server id'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/material-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario: Update material type mappings

    * print 'Update material type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/update-material-type-mappings-request.json")
    When method PUT
    Then status 204

    * print 'Check updated material type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.materialTypeMappings[0].materialTypeId == "337e0bfa-9781-44b8-ac90-5bd459623fb9"
    And match response.materialTypeMappings[0].centralItemType == 100
    And match response.materialTypeMappings[1].materialTypeId == "2541dcf3-ba2f-4175-b32b-63078cbb9342"
    And match response.materialTypeMappings[1].centralItemType == 200

  Scenario: Update material type mappings which not exist

    * print 'Update material type mappings which not exist'
    Given path '/inn-reach/central-servers/' + centralServer2.id + '/material-type-mappings'
    And request read(samplesPath + "material-type-mapping/update-material-type-mappings-request.json")
    When method PUT
    Then status 204

    * print 'Check updated material type mappings'
    Given path '/inn-reach/central-servers/' + centralServer1.id + '/material-type-mappings'
    When method GET
    Then status 200
    And match response.totalRecords == 2

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')
