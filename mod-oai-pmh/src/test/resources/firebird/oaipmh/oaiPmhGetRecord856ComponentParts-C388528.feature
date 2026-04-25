@parallel=false
Feature: GetRecord: SRS & Inventory - Verify 856 4 3 and 856 4 4 are returned for instance, holdings and item electronic access

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify GetRecord returns 856 4 3 and 856 4 4 for instance, holdings and item
    * def testInstanceId = '4d112934-30c8-42c3-bfe4-dabdfd4c7c0e'
    * def testSrsId = '2d2673fe-b45f-4e0e-b469-4f8fb76dcd93'
    * def testSnapshotId = '0d7ce273-4332-49ff-bf93-bd8f78e855e2'
    * def testHoldingsId = '27b3f7bc-5a7d-4494-92b8-f2e97a21e825'
    * def testItemId = 'cbc0a59f-b9ff-4f76-9c98-4253f3504d98'
    * def testHrid = 'inst00000085643'
    * def resourceRelationshipId = 'f5d0068e-6272-458e-8a81-b85e7b9a14aa'
    * def versionResourceRelationshipId = '3b430592-2e09-4b48-9a0c-0636d66b9fb3'
    * def componentRelationshipId = '3373f0cf-7a3a-4a65-b0a6-e4f1a3f7d131'
    * def versionComponentRelationshipId = 'd855f394-f9d4-46b6-8435-830eb00d0d57'
    * def instanceComponentUri = 'Component part(s) of resource 4 3'
    * def instanceVersionComponentUri = 'Version of component part(s) of resource 4 4'
    * def holdingsResourceUri = 'Resource 4 0'
    * def holdingsVersionResourceUri = 'Version of resource 4 1'
    * def holdingsComponentUri = 'Component part(s) of resource 4 3'
    * def holdingsVersionComponentUri = 'Version of component part(s) of resource 4 4'
    * def itemComponentUri = 'http://item.example/component-part'
    * def itemVersionComponentUri = 'http://item.example/version-component-part'
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    # Seed the relationship types used for 856 ind2=3 and ind2=4 mappings.
    Given url baseUrl
    And path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "id": "#(componentRelationshipId)",
      "name": "Component part(s) of resource",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    Given url baseUrl
    And path 'electronic-access-relationships'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      "id": "#(versionComponentRelationshipId)",
      "name": "Version of component part(s) of resource",
      "source": "folio"
    }
    """
    When method POST
    Then status 201

    # Create MARC-backed instance.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'MARC'
    * set instance.electronicAccess = []
    And request instance
    When method POST
    Then status 201

    # Create a snapshot for the SRS record.
    Given url baseUrl
    And path 'source-storage/snapshots'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "jobExecutionId": "#(testSnapshotId)",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    # Create SRS MARC bib with the two required 856 fields from a dedicated full source-record fixture.
    Given url baseUrl
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record_856_component_parts.json')
    * set record.id = testSrsId
    * set record.snapshotId = testSnapshotId
    * set record.externalIdsHolder.instanceId = testInstanceId
    * set record.externalIdsHolder.instanceHrid = testHrid
    * set record.matchedId = testSrsId
    And request record
    And header Accept = 'application/json'
    When method POST
    Then status 201

    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * call sleep 5000

    # Verify MARC instance 856 fields are returned in GetRecord marc21 response.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def instance856Fields = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856"]')
    * match instance856Fields == '#[5]'
    * def instanceComponentUriField = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="u"]')
    * match instanceComponentUriField == instanceComponentUri
    * def instanceVersionComponentUriField = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="u"]')
    * match instanceVersionComponentUriField == instanceVersionComponentUri

    # Add Holdings with the same two relationship types.
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = testHoldingsId
    * set holding.instanceId = testInstanceId
    * set holding.hrid = testHrid + '_h1'
    * set holding.electronicAccess = []
    * set holding.electronicAccess[0] = {}
    * set holding.electronicAccess[0].relationshipId = resourceRelationshipId
    * set holding.electronicAccess[0].uri = holdingsResourceUri
    * set holding.electronicAccess[1] = {}
    * set holding.electronicAccess[1].relationshipId = versionResourceRelationshipId
    * set holding.electronicAccess[1].uri = holdingsVersionResourceUri
    * set holding.electronicAccess[2] = {}
    * set holding.electronicAccess[2].relationshipId = componentRelationshipId
    * set holding.electronicAccess[2].uri = holdingsComponentUri
    * set holding.electronicAccess[3] = {}
    * set holding.electronicAccess[3].relationshipId = versionComponentRelationshipId
    * set holding.electronicAccess[3].uri = holdingsVersionComponentUri
    And request holding
    When method POST
    Then status 201

    * call sleep 5000

    # Verify combined instance + holdings response in GetRecord marc21_withholdings.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def holdings856Fields = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856"]')
    * match holdings856Fields == '#[9]'
    * def holdingsComponentUris = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="u"]')
    * match holdingsComponentUris contains instanceComponentUri
    * match holdingsComponentUris contains holdingsComponentUri
    * def holdingsVersionUris = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="u"]')
    * match holdingsVersionUris contains instanceVersionComponentUri
    * match holdingsVersionUris contains holdingsVersionComponentUri

    # Add Item with the same two relationship types.
    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def item = read('classpath:samples/item.json')
    * set item.id = testItemId
    * set item.holdingsRecordId = testHoldingsId
    * set item.hrid = testHrid + '_i1'
    * set item.discoverySuppress = false
    * set item.electronicAccess = []
    * set item.electronicAccess[0] = {}
    * set item.electronicAccess[0].relationshipId = componentRelationshipId
    * set item.electronicAccess[0].uri = itemComponentUri
    * set item.electronicAccess[1] = {}
    * set item.electronicAccess[1].relationshipId = versionComponentRelationshipId
    * set item.electronicAccess[1].uri = itemVersionComponentUri
    And request item
    When method POST
    Then status 201

    * call sleep 5000

    # Verify combined instance + holdings + item response in GetRecord marc21_withholdings.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * def all856Fields = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856"]')
    * match all856Fields == '#[11]'
    * def allComponentUris = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="3"]/*[local-name()="subfield" and @code="u"]')
    * match allComponentUris contains instanceComponentUri
    * match allComponentUris contains holdingsComponentUri
    * match allComponentUris contains itemComponentUri
    * def allVersionUris = karate.xmlPath(response, '//*[local-name()="datafield" and @tag="856" and @ind1="4" and @ind2="4"]/*[local-name()="subfield" and @code="u"]')
    * match allVersionUris contains instanceVersionComponentUri
    * match allVersionUris contains holdingsVersionComponentUri
    * match allVersionUris contains itemVersionComponentUri

    # Cleanup
    Given url baseUrl
    And path 'item-storage/items', testItemId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'source-storage/records', testSrsId
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204
