@parallel=false
Feature: C397334 - ListRecords: Inventory - Verify the response contains 856 field with subfield "t" populated

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_Inventory_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify 856 field with subfield "t" populated for instance, holdings and items
    # Use unique IDs to avoid conflicts with other tests
    * def testInstanceId = '12bc05c4-081f-45ac-8f87-7ff551c3fc16'
    * def testHoldingsId = '8f3ca787-0d3b-4fcd-aba2-b6d459512df0'
    * def testItemId = '88a0b156-d622-4806-9147-f3ce79208696'
    * def testHrid = 'inst000000C397334'

    # Get current date for OAI-PMH request
    * def currentDate = karate.get('$', java.time.LocalDate.now().toString())
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }

    # Relationship types:
    # No information provided: f50c90c9-bae0-4add-9cd0-db9092dbc9dd
    # Related resource: 5bfe1b7b-f151-4501-8cfa-23b321d5cd1e
    # Resource: f5d0068e-6272-458e-8a81-b85e7b9a14aa
    # Version of resource: 3b430592-2e09-4b48-9a0c-0636d66b9fb3

    # Precondition 6: Create FOLIO instance with electronic accesses
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'FOLIO'
    * set instance.electronicAccess = []
    * set instance.electronicAccess[0] = { relationshipId: 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', uri: 'http://instance.com/1' }
    * set instance.electronicAccess[1] = { relationshipId: '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e', uri: 'http://instance.com/2' }
    * set instance.electronicAccess[2] = { relationshipId: 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', uri: 'http://instance.com/3' }
    * set instance.electronicAccess[3] = { relationshipId: '3b430592-2e09-4b48-9a0c-0636d66b9fb3', uri: 'http://instance.com/4' }
    And request instance
    When method POST
    Then status 201

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 1: Note the instance UUID
    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * print 'Instance identifier:', identifierToFind

    # Step 2: Send ListRecords request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response (marc21):', response

    # Verify the instance is present in response
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def recordXPath = '//record[header/identifier[text()="' + identifierToFind + '"]]'
    * def testRecord = karate.xmlPath(response, recordXPath)

    # Verify 856 fields have subfield "t" set to "0" for each electronic access
    * def all856t = karate.xmlPath(testRecord, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856t == '0'
    * match all856t == '#[4]'

    # Step 3: Send ListRecords request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response (marc21_withholdings):', response

    # Verify the instance is present in response
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def testRecordWithholdings = karate.xmlPath(response, recordXPath)

    # Verify 856 fields have subfield "t" set to "0"
    * def all856tWithholdings = karate.xmlPath(testRecordWithholdings, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856tWithholdings == '0'
    * match all856tWithholdings == '#[4]'

    # Step 4: Send GetRecord request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord response (marc21):', response

    # Verify 856 fields have subfield "t" set to "0"
    * def getRecord856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecord856t == '0'
    * match getRecord856t == '#[4]'

    # Step 5: Send GetRecord request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord response (marc21_withholdings):', response

    # Verify 856 fields have subfield "t" set to "0"
    * def getRecordWithholdings856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordWithholdings856t == '0'
    * match getRecordWithholdings856t == '#[4]'

    # Step 6-9: Add Holdings with multiple electronic accesses
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = testHoldingsId
    * set holding.instanceId = testInstanceId
    * set holding.hrid = testHrid + '_h1'
    * set holding.electronicAccess = []
    * set holding.electronicAccess[0] = { relationshipId: 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', uri: 'http://holdings.com/1' }
    * set holding.electronicAccess[1] = { relationshipId: '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e', uri: 'http://holdings.com/2' }
    * set holding.electronicAccess[2] = { relationshipId: 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', uri: 'http://holdings.com/3' }
    * set holding.electronicAccess[3] = { relationshipId: '3b430592-2e09-4b48-9a0c-0636d66b9fb3', uri: 'http://holdings.com/4' }
    * set holding.electronicAccess[4] = { relationshipId: 'ef03d582-219c-4221-8635-bc92f1107021', uri: 'http://holdings.com/5' }
    And request holding
    When method POST
    Then status 201

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 10: Send ListRecords request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response after adding holdings (marc21):', response

    # Verify instance electronic access 856 fields have subfield "t" set to "0"
    * def testRecordWithHoldings = karate.xmlPath(response, recordXPath)
    * def instance856t = karate.xmlPath(testRecordWithHoldings, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each instance856t == '0'
    * match instance856t == '#[4]'

    # Step 11: Send ListRecords request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response after adding holdings (marc21_withholdings):', response

    # Verify both instance and holdings electronic access 856 fields have subfield "t" set to "0"
    * def testRecordWithHoldingsWH = karate.xmlPath(response, recordXPath)
    * def all856tWithHoldings = karate.xmlPath(testRecordWithHoldingsWH, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856tWithHoldings == '0'
    * match all856tWithHoldings == '#[9]'

    # Step 12: Send GetRecord request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord with holdings (marc21):', response

    # Verify instance electronic access 856 fields have subfield "t" set to "0"
    * def getRecordHoldings856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordHoldings856t == '0'
    * match getRecordHoldings856t == '#[4]'

    # Step 13: Send GetRecord request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord with holdings (marc21_withholdings):', response

    # Verify both instance and holdings electronic access 856 fields have subfield "t" set to "0"
    * def getRecordHoldingsWH856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordHoldingsWH856t == '0'
    * match getRecordHoldingsWH856t == '#[9]'

    # Step 14-18: Add Item with multiple electronic accesses
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
    * set item.electronicAccess[0] = { relationshipId: 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', uri: 'http://items.com/1' }
    * set item.electronicAccess[1] = { relationshipId: '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e', uri: 'http://items.com/2' }
    * set item.electronicAccess[2] = { relationshipId: 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', uri: 'http://items.com/3' }
    * set item.electronicAccess[3] = { relationshipId: '3b430592-2e09-4b48-9a0c-0636d66b9fb3', uri: 'http://items.com/4' }
    * set item.electronicAccess[4] = { relationshipId: 'ef03d582-219c-4221-8635-bc92f1107021', uri: 'http://items.com/5' }
    And request item
    When method POST
    Then status 201

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 19: Send ListRecords request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response after adding item (marc21):', response

    # Verify instance electronic access 856 fields have subfield "t" set to "0"
    * def testRecordWithItem = karate.xmlPath(response, recordXPath)
    * def instance856tWithItem = karate.xmlPath(testRecordWithItem, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each instance856tWithItem == '0'
    * match instance856tWithItem == '#[4]'

    # Step 20: Send ListRecords request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response after adding item (marc21_withholdings):', response

    # Verify instance, holdings and items electronic access 856 fields have subfield "t" set to "0"
    * def testRecordWithItemWH = karate.xmlPath(response, recordXPath)
    * def all856tWithItem = karate.xmlPath(testRecordWithItemWH, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856tWithItem == '0'
    * match all856tWithItem == '#[14]'

    # Step 21: Send GetRecord request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord with item (marc21):', response

    # Verify instance electronic access 856 fields have subfield "t" set to "0"
    * def getRecordItem856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordItem856t == '0'
    * match getRecordItem856t == '#[4]'

    # Step 22: Send GetRecord request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord with item (marc21_withholdings):', response

    # Verify instance, holdings and items electronic access 856 fields have subfield "t" set to "0"
    * def getRecordItemWH856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordItemWH856t == '0'
    * match getRecordItemWH856t == '#[14]'

    # Step 23-24: Suppress the instance
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def instanceVersion = $._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    * set instance._version = instanceVersion
    * set instance.discoverySuppress = true
    And request instance
    When method PUT
    Then status 204

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Repeat steps 2-5 with suppressed instance
    # Step 2: Send ListRecords request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with suppressed instance (marc21):', response

    # Verify the instance is present in response
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def testRecordSuppressed = karate.xmlPath(response, recordXPath)

    # Verify 856 fields have subfield "t" set to "1" for suppressed instance
    * def all856tSuppressed = karate.xmlPath(testRecordSuppressed, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856tSuppressed == '1'

    # Step 3: Send ListRecords request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with suppressed instance (marc21_withholdings):', response

    # Verify all 856 fields have subfield "t" set to "1"
    * def testRecordSuppressedWH = karate.xmlPath(response, recordXPath)
    * def all856tSuppressedWH = karate.xmlPath(testRecordSuppressedWH, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856tSuppressedWH == '1'

    # Step 4: Send GetRecord request with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord with suppressed instance (marc21):', response

    # Verify 856 fields have subfield "t" set to "1"
    * def getRecordSuppressed856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordSuppressed856t == '1'

    # Step 5: Send GetRecord request with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = identifierToFind
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'GetRecord with suppressed instance (marc21_withholdings):', response

    # Verify 856 fields have subfield "t" set to "1"
    * def getRecordSuppressedWH856t = karate.xmlPath(response, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each getRecordSuppressedWH856t == '1'

    # Cleanup: Delete test data
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
    And path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

