@parallel=false
Feature: C378101 - ListRecords: SRS & Inventory - Verify that effective call number is properly included in response when harvesting instance with holdings (marc21_withholdings)

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify effective call number is properly included in response for holdings and items (marc21_withholdings)
    # Use unique IDs to avoid conflicts with other tests
    * def testInstanceId = 'affcfc75-becf-490c-a15c-9fa9ca33575e'
    * def testHoldingsId = 'b39caf14-795a-4921-a766-9c3f430dc658'
    * def testItemId = 'd89b2bc3-ada0-4aee-8d58-f193c9549fda'
    * def testHrid = 'inst000000C378101'
    * def testSrsId = 'bad51789-8a3d-4799-bf15-e79f6581db77'

    # Get current date for OAI-PMH request
    * def currentDate = karate.get('$', java.time.LocalDate.now().toString())

    # Step 1: Create instance
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'MARC'
    And request instance
    When method POST
    Then status 201

    # Create SRS record for the instance
    Given url baseUrl
    And path 'source-storage/records'
    * def record = read('classpath:samples/marc_record.json')
    * set record.id = testSrsId
    * set record.externalIdsHolder.instanceId = testInstanceId
    * set record.matchedId = testSrsId
    And request record
    And header Accept = 'application/json'
    When method POST
    Then status 201

    # Step 2-4: Add Holdings with call number fields
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = testHoldingsId
    * set holding.instanceId = testInstanceId
    * set holding.hrid = testHrid
    * set holding.copyNumber = 'Holdings copy number'
    * set holding.callNumberTypeId = '512173a7-bd09-490e-b773-17d83f2b63fe'
    * set holding.callNumberPrefix = 'holdings_prefix'
    * set holding.callNumber = 'Holdings call number'
    * set holding.callNumberSuffix = 'holdings_suffix'
    And request holding
    When method POST
    Then status 201

    # Step 5: Wait for OAI-PMH indexing
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * call sleep 5000

    # Step 6: Send ListRecords request and verify holdings call number fields in 952
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response:', response

    # Verify the instance is present in response
    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * print 'Looking for identifier:', identifierToFind
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def recordXPath = '//record[header/identifier[text()="' + identifierToFind + '"]]'
    * def testRecord = karate.xmlPath(response, recordXPath)
    * print 'Test record:', testRecord

    # Verify 952 field contains Holdings call number values
    * def field952e = karate.xmlPath(testRecord, '//datafield[@tag="952"]/subfield[@code="e"]')
    * match field952e contains 'Holdings call number'

    * def field952f = karate.xmlPath(testRecord, '//datafield[@tag="952"]/subfield[@code="f"]')
    * match field952f contains 'holdings_prefix'

    * def field952g = karate.xmlPath(testRecord, '//datafield[@tag="952"]/subfield[@code="g"]')
    * match field952g contains 'holdings_suffix'

    * def field952h = karate.xmlPath(testRecord, '//datafield[@tag="952"]/subfield[@code="h"]')
    * match field952h == '#present'

    * def field952n = karate.xmlPath(testRecord, '//datafield[@tag="952"]/subfield[@code="n"]')
    * match field952n contains 'Holdings copy number'

    # Step 7-10: Add Item with call number fields
    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def item = read('classpath:samples/item.json')
    * set item.id = testItemId
    * set item.holdingsRecordId = testHoldingsId
    * set item.hrid = testHrid
    * set item.copyNumber = 'Item copy number'
    * set item.itemLevelCallNumberTypeId = '512173a7-bd09-490e-b773-17d83f2b63fe'
    * set item.itemLevelCallNumberPrefix = 'item_prefix'
    * set item.itemLevelCallNumber = 'Item call number'
    * set item.itemLevelCallNumberSuffix = 'item_suffix'
    And request item
    When method POST
    Then status 201

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 11: Send ListRecords request and verify item call number fields override holdings values in 952
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with item:', response

    # Verify the instance is present in response
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def testRecordWithItem = karate.xmlPath(response, recordXPath)
    * print 'Test record with item:', testRecordWithItem

    # Verify 952 field contains Item call number values (item overrides holdings)
    * def field952e = karate.xmlPath(testRecordWithItem, '//datafield[@tag="952"]/subfield[@code="e"]')
    * match field952e contains 'Item call number'

    * def field952f = karate.xmlPath(testRecordWithItem, '//datafield[@tag="952"]/subfield[@code="f"]')
    * match field952f contains 'item_prefix'

    * def field952g = karate.xmlPath(testRecordWithItem, '//datafield[@tag="952"]/subfield[@code="g"]')
    * match field952g contains 'item_suffix'

    * def field952h = karate.xmlPath(testRecordWithItem, '//datafield[@tag="952"]/subfield[@code="h"]')
    * match field952h == '#present'

    * def field952n = karate.xmlPath(testRecordWithItem, '//datafield[@tag="952"]/subfield[@code="n"]')
    * match field952n contains 'Item copy number'

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

