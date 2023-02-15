@parallel=false
Feature: Patron type mapping

  Background:
    * url baseUrl + '/inn-reach/central-servers'

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = get[0] response.centralServers[?(@.name == 'Central server 1')]
    * def centralServer2 = get[0] response.centralServers[?(@.name == 'Central server 2')]

    * def mappingPath1 = centralServer1.id + '/patron-type-mappings'
    * def mappingPath2 = centralServer2.id + '/patron-type-mappings'
    # ------------ schema definitions ------------
    * callonce read(globalPath + 'common-schemas.feature')
    * def emptyMappingsSchema = {patronTypeMappings: '#[0]', totalRecords: 0}
    * def mappingItemSchema =
    """
    {
      "id": '#uuid',
      "patronGroupId": '#uuid',
      "patronType": '#number',
      "metadata": '#(metadataSchema)'
    }
    """
    * def mappingsSchema =
    """
    {
      patronTypeMappings: '#[] mappingItemSchema',
      totalRecords: '#number? _ == $.patronTypeMappings.length'
    }
    """

  # ================= positive test cases =================

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
    And match $ == mappingsSchema
    And match $.totalRecords == 2

    * def responseMappings = $.patronTypeMappings
    * def requestMappings = mappings.patronTypeMappings
    And match responseMappings[*].patronGroupId contains only get requestMappings[*].patronGroupId
    And match responseMappings[*].patronType contains only get requestMappings[*].patronType

  Scenario: Put patron type mappings to update mapping
    # create a mapping to be updated
    * def initial = {patronGroupId: '#(uuid())', patronType: 254}
    Given path mappingPath1
    And request {patronTypeMappings: [ '#(initial)' ] }
    When method PUT
    Then status 204

    # get the mapping
    Given path mappingPath1
    When method GET
    Then status 200
    And match $.patronTypeMappings == '#[1]'
    And match $.patronTypeMappings[0] contains initial
    * def mappings = $

    # update mapping
    * set mappings.patronTypeMappings[0].patronGroupId = uuid()
    * set mappings.patronTypeMappings[0].patronType = 255
    Given path mappingPath1
    And request mappings
    When method PUT
    Then status 204

    # get updated mapping and verify
    Given path mappingPath1
    When method GET
    Then status 200

    And match $.patronTypeMappings == '#[1]'

    * def actual = $.patronTypeMappings[0]
    * def expected = mappings.patronTypeMappings[0]
    And match actual.id == expected.id
    And match actual.patronGroupId == expected.patronGroupId
    And match actual.patronType == expected.patronType

  Scenario: Put empty patron type mappings to delete all mappings
    # create mappings to be deleted
    Given path mappingPath1
    And request read(samplesPath + 'patron-type-mapping/patron-type-mappings.json')
    When method PUT
    Then status 204

    # get created mappings and verify the count
    Given path mappingPath1
    When method GET
    Then status 200
    And match $ == mappingsSchema
    And match $.totalRecords == 2

    # send empty mapping list to remove all mappings
    Given path mappingPath1
    And request {patronTypeMappings: [] }
    When method PUT
    Then status 204

    # get the mapping and verify everything is deleted
    Given path mappingPath1
    When method GET
    Then status 200
    And match $ == emptyMappingsSchema

  # ================= negative test cases =================

  Scenario: Get patron type mappings - unknown central server
    * print 'Get patron type mappings - unknown central server'
    * def unknownServerId = uuid()
    Given path unknownServerId, 'patron-type-mappings'
    When method GET
    Then status 200
    And match $ == emptyMappingsSchema

  Scenario: Get patron type mappings - no mappings defined
    * print 'Get patron type mappings - no mappings defined'
    Given path mappingPath2
    When method GET
    Then status 200
    And match $ == emptyMappingsSchema

  Scenario Outline: Put patron type mappings - invalid patron type (type less than 0 or greater than 255)
    * print 'Put patron type mappings - invalid patron type'

    * def mappings = read(samplesPath + 'patron-type-mapping/patron-type-mappings.json')
    * set mappings.patronTypeMappings[0].patronType = <patronType>
    Given path mappingPath1
    And request mappings
    When method PUT
    Then status 400
    And match $ == validationErrorSchema
    And match $.validationErrors[0].fieldName == 'patronTypeMappings[0].patronType'
    And match $.validationErrors[0].message == <message>

    Examples:
      | patronType | message                              |
      | -1         | 'must be greater than or equal to 0' |
      | -100       | 'must be greater than or equal to 0' |
      | 256        | 'must be less than or equal to 255'  |
      | 512        | 'must be less than or equal to 255'  |

  # ================= DB clean up =================

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')