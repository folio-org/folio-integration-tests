@ignore
@parallel=false
Feature: Material type mapping

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * def mockServer = karate.start(mocksPath + 'general/auth-mock.feature')
    * def port = mockServer.port
    * def centralServerUrl = 'http://10.0.2.2:' + port

  @Undefined
  Scenario: Get material type mappings by server id
    * print 'Create central server'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId1 = response.id

    * print 'Create material type mapping 1'
    * configure headers = headersUser
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId1
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-1.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "337e0bfa-9781-44b8-ac90-5bd459623fb9"
    And match response.centralItemType == 1
    And match response.id == '#notnull'

    * print 'Create material type mapping 2'
    * configure headers = headersUser
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId1
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-2.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "2541dcf3-ba2f-4175-b32b-63078cbb9342"
    And match response.centralItemType == 2
    And match response.id == '#notnull'
    * def materialTypeMappingId = response.id

    * print 'Get material type mappings by server id'
    * configure headers = headersUsers
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId
    When method GET
    Then status 200
    And match response.totalRecords == 2

  @Undefined
  Scenario: Get material type mapping by id
    * print 'Get material type mapping by id'

  Scenario: Create material type mapping
    * print 'Create central server'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId1 = response.id

    * print 'Create material type mapping'
    * configure headers = headersUser
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-1.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "337e0bfa-9781-44b8-ac90-5bd459623fb9"
    And match response.centralItemType == 1
    And match response.id == '#notnull'

  Scenario: Update material type mappings
    * print 'Create central server 1'
    * configure headers = headersUser
    Given path '/inn-reach/central-servers'
    And request read(samplesPath + "central-server/create-central-server1.json")
    When method POST
    Then status 201
    * def centralServerId1 = response.id

    * print 'Create material type mapping 1'
    * configure headers = headersUser
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId1
    And request read(samplesPath + "material-type-mapping/create-material-type-mappings-request-1.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "337e0bfa-9781-44b8-ac90-5bd459623fb9"
    And match response.centralItemType == 1
    And match response.id == '#notnull'

    * print 'Create material type mapping 2'
    * configure headers = headersUser
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId1
    And request read(samplesPath + "material-type-mapping/create-material-type-mapping-request-2.json")
    When method POST
    Then status 201
    And match response.materialTypeId == "2541dcf3-ba2f-4175-b32b-63078cbb9342"
    And match response.centralItemType == 2
    And match response.id == '#notnull'
    * def materialTypeMappingId = response.id

    * print 'Update material type mappings'
    * configure headers = headersUser
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId1
    And request read(samplesPath + "material-type-mapping/update-material-type-mappings-request.json")
    When method PUT
    Then status 204

    * print 'Check created material type mappings'
    * configure headers = headersUsers
    Given path '/inn-reach/{centralServerId}/material-type-mappings', centralServerId
    When method GET
    Then status 200
    And match response.totalRecords == 3

  @Undefined
  Scenario: Update material type mapping
    * print 'Update material type mapping'

  @Undefined
  Scenario: Delete material type mapping
    * print 'Delete material type mapping'
