@ignore
@parallel=false
Feature: item type mapping

  Background:
    * url baseUrl + '/inn-reach/central-servers'

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * print 'Prepare central servers'
    * callonce read(featuresPath + 'central-server.feature@create')
    * def centralServer1 = response.centralServers[0]
    * def centralServer2 = response.centralServers[1]

    * def mappingPath1 = centralServer1.id + '/item-type-mappings'
    * def mappingPath2 = centralServer2.id + '/item-type-mappings'
    # ------------ schema definitions ------------
    * callonce read(globalPath + 'common-schemas.feature')
    * def emptyMappingsSchema = {itemTypeMappings: '#[0]', totalRecords: 0}
    * def mappingItemSchema = read(samplesPath + 'item-type-mapping/item-type-mapping-schema.json')
    * def mappingsSchema =
    """
    {
      itemTypeMappings: '#[] mappingItemSchema',
      totalRecords: '#number? _ == $.itemTypeMappings.length'
    }
    """

  # ================= positive test cases =================

  Scenario: Create and get item type mappings
    * print 'Create initial item type mappings'
    * def mappings = read(samplesPath + 'item-type-mapping/item-type-mappings.json')
    Given path mappingPath1
    And request mappings
    When method PUT
    Then status 204

    * print 'Get initial item type mappings'
    Given path mappingPath1
    When method GET
    Then status 200
    And match $ == mappingsSchema
    And match $.totalRecords == 2

    * def responseMappings = $.itemTypeMappings
    * def requestMappings = mappings.itemTypeMappings
    And match responseMappings[*].materialTypeId contains only get requestMappings[*].materialTypeId
    And match responseMappings[*].centralItemType contains only get requestMappings[*].centralItemType

  Scenario: Put item type mappings to update mapping
    # create a mapping to be updated
    * def initial = {materialTypeId: '#(uuid())', centralItemType: 254}
    Given path mappingPath1
    And request {itemTypeMappings: [ '#(initial)' ] }
    When method PUT
    Then status 204

    # get the mapping
    Given path mappingPath1
    When method GET
    Then status 200
    And match $.itemTypeMappings == '#[1]'
    And match $.itemTypeMappings[0] contains initial
    * def mappings = $

    # update mapping
    * set mappings.itemTypeMappings[0].materialTypeId = uuid()
    * set mappings.itemTypeMappings[0].centralItemType = 255
    Given path mappingPath1
    And request mappings
    When method PUT
    Then status 204

    # get updated mapping and verify
    Given path mappingPath1
    When method GET
    Then status 200

    And match $.itemTypeMappings == '#[1]'

    * def actual = $.itemTypeMappings[0]
    * def expected = mappings.itemTypeMappings[0]
    And match actual.id == expected.id
    And match actual.materialTypeId == expected.materialTypeId
    And match actual.centralItemType == expected.centralItemType

  Scenario: Put empty item type mappings to delete all mappings
    # create mappings to be deleted
    Given path mappingPath1
    And request read(samplesPath + 'item-type-mapping/item-type-mappings.json')
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
    And request {itemTypeMappings: [] }
    When method PUT
    Then status 204

    # get the mapping and verify everything is deleted
    Given path mappingPath1
    When method GET
    Then status 200
    And match $ == emptyMappingsSchema

  # ================= negative test cases =================

  Scenario: Get item type mappings - unknown central server
    * print 'Get item type mappings - unknown central server'
    * def unknownServerId = uuid()
    Given path unknownServerId, 'item-type-mappings'
    When method GET
    Then status 200
    And match $ == emptyMappingsSchema

  Scenario: Get item type mappings - no mappings defined
    * print 'Get item type mappings - no mappings defined'
    Given path mappingPath2
    When method GET
    Then status 200
    And match $ == emptyMappingsSchema

  Scenario Outline: Put item type mappings - invalid item type (type less than 0 or greater than 255)
    * print 'Put item type mappings - invalid item type'

    * def mappings = read(samplesPath + 'item-type-mapping/item-type-mappings.json')
    * set mappings.itemTypeMappings[0].centralItemType = <centralItemType>
    Given path mappingPath1
    And request mappings
    When method PUT
    Then status 400
    And match $ == validationErrorSchema
    And match $.validationErrors[0].fieldName == 'itemTypeMappings[0].centralItemType'
    And match $.validationErrors[0].message == <message>

    Examples:
      | centralItemType | message                              |
      | -1              | 'must be greater than or equal to 0' |
      | -100            | 'must be greater than or equal to 0' |
      | 256             | 'must be less than or equal to 255'  |
      | 512             | 'must be less than or equal to 255'  |

  # ================= DB clean up =================

  Scenario: Delete central servers
    * print 'Delete central servers'
    * call read(featuresPath + 'central-server.feature@delete')