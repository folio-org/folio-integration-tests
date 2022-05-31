@ignore
@parallel=false
Feature: Patron type mapping

  Background:
    * url baseUrl + '/inn-reach/central-servers'
    * def mappingPath = function(serverId) { return serverId + '/patron-type-mappings'}

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

    * def libraryId = 'a2709e94-954d-4800-bb97-8167fd712d0a'

    * def unknownLibraryId = 'ebb44070-df35-48de-af1c-9147cbb23dcf'
    * def unknownCentralServerId = 'f18c9e64-c2b7-415c-935e-84c7e200b48c'

    * def mappingPath1 = centralServer1.id + '/patron-type-mappings'
    * def mappingPath2 = centralServer2.id + '/patron-type-mappings'
    # ------------ schema definitions ------------
    * def isValidDateTime = read(globalPath + 'datetime-validator.js')
    * def emptyMappingsSchema = {patronTypeMappings: '#[0]', totalRecords: 0}
    * def mappingItemSchema =
    """
    {
      "id": '#uuid',
      "patronGroupId": '#uuid',
      "patronType": '#number',
      "metadata": {
        "createdDate": '#string',
        "createdByUserId": '#uuid',
        "createdByUsername": '#string',
        "updatedDate": '##string',
        "updatedByUserId": '##uuid',
        "updatedByUsername": '##string'
      }
    }
    """
    * def mappingsSchema =
    """
    {
      patronTypeMappings: '#[] mappingItemSchema',
      totalRecords: '#number? _ >= 0'
    }
    """

  Scenario: Create and get patron type mappings
    * print 'Create initial patron type mappings'
    * def mappings = read(samplesPath + 'patron-type-mapping/patron-type-mappings.json')
    Given path mappingPath1
    And request mappings
    When method PUT
    Then status 204

    * print 'Get initial patron type mappings'
    Given path mappingPath1
    When method GET
    Then status 200
    And match response == mappingsSchema
    And match response.totalRecords == 2

    * def responseMappings = response.patronTypeMappings
    * def requestMappings = mappings.patronTypeMappings
    And match responseMappings[*].patronGroupId contains get requestMappings[*].patronGroupId
    And match responseMappings[*].patronType contains get requestMappings[*].patronType

  Scenario: Unknown central server
    * print 'Get Location mappings'
    * def unknownServerId = uuid()
    Given path unknownServerId, 'patron-type-mappings'
    When method GET
    Then status 200
    And match response == emptyMappingsSchema

  Scenario: No mappings found
    * print 'Get Location mappings'
    Given path mappingPath2
    When method GET
    Then status 200
    And match response == emptyMappingsSchema

  @Undefined
  Scenario: Get patron type mappings by server id
    * print 'Get patron type mappings by server id'

  @Undefined
  Scenario: Update patron type mappings
    * print 'Update patron type mappings'
