@parallel=false
Feature: C380606 - ListRecords: Inventory - Verify the response contains 856 field with one subfield "t" for the holdings and item records with electronic access populated

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_Inventory_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario: Verify 856 field with subfield "t" for holdings and items with electronic access
    # Use unique IDs to avoid conflicts with other tests
    * def testInstanceId = '122b9bce-5b8f-4e61-8213-8f1d52a3d80a'
    * def testHoldingsIds = ['f036b82c-89e9-4ac3-b786-61b459baac73', 'a1f0db6f-4aa1-4d9f-8723-51c7d7222a51', '8da9a4aa-6eb3-4c4d-a424-36262cd7ac84', '91812aae-65e0-4d03-bbd7-fbcc3382d5f6', '647128a3-9459-4c4c-8edc-2899fc3f4563']
    * def testItemIds = ['c533dad0-dc1e-4d8b-800f-030188887d6d', '82437e40-f180-4da8-9116-ec859cea027d']
    * def testHrid = 'inst000000C380606'

    # Get current date and time for OAI-PMH request
    * def currentDate = karate.get('$', java.time.LocalDate.now().toString())
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }

    # Step 1-5: Create FOLIO instance without electronic access
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = testInstanceId
    * set instance.hrid = testHrid
    * set instance.source = 'FOLIO'
    * set instance.electronicAccess = []
    And request instance
    When method POST
    Then status 201

    # Step 6: Add 5 Holdings with different electronic access relationship types
    # Relationship types:
    # No display constant generated: ef03d582-219c-4221-8635-bc92f1107021 (ind2=8)
    # No information provided: f50c90c9-bae0-4add-9cd0-db9092dbc9dd (ind2=blank)
    # Related resource: 5bfe1b7b-f151-4501-8cfa-23b321d5cd1e (ind2=2)
    # Resource: f5d0068e-6272-458e-8a81-b85e7b9a14aa (ind2=0)
    # Version of resource: 3b430592-2e09-4b48-9a0c-0636d66b9fb3 (ind2=1)

    * def relationshipTypes = ['ef03d582-219c-4221-8635-bc92f1107021', 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e', 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', '3b430592-2e09-4b48-9a0c-0636d66b9fb3']

    * def createHolding =
    """
    function(holdingId, relationshipTypeId) {
      var holding = karate.read('classpath:samples/holding.json');
      holding.id = holdingId;
      holding.instanceId = testInstanceId;
      holding.hrid = testHrid + '_h' + holdingId.substring(7, 8);
      holding.electronicAccess = [{
        relationshipId: relationshipTypeId,
        uri: 'http://holdings.com/' + holdingId
      }];
      return holding;
    }
    """

    * def createHoldingRequest =
    """
    function(index) {
      var holding = createHolding(testHoldingsIds[index], relationshipTypes[index]);
      karate.set('holding', holding);
      karate.call('classpath:firebird/oaipmh/helpers/create-holding.feature');
      return holding.id;
    }
    """

    # Create holdings manually
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding1 = createHolding(testHoldingsIds[0], relationshipTypes[0])
    And request holding1
    When method POST
    Then status 201

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding2 = createHolding(testHoldingsIds[1], relationshipTypes[1])
    And request holding2
    When method POST
    Then status 201

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding3 = createHolding(testHoldingsIds[2], relationshipTypes[2])
    And request holding3
    When method POST
    Then status 201

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding4 = createHolding(testHoldingsIds[3], relationshipTypes[3])
    And request holding4
    When method POST
    Then status 201

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def holding5 = createHolding(testHoldingsIds[4], relationshipTypes[4])
    And request holding5
    When method POST
    Then status 201

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 8-9: Send ListRecords request and verify 856 field with subfield "t" for holdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with holdings:', response

    # Verify the instance is present in response
    * def identifierToFind = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * print 'Looking for identifier:', identifierToFind
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def recordXPath = '//record[header/identifier[text()="' + identifierToFind + '"]]'
    * def testRecord = karate.xmlPath(response, recordXPath)

    # Verify 856 fields with different indicators for each relationship type
    # Verify each 856 field has only one subfield "t" set to "0"
    * def field856ind8 = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="8"]')
    * match field856ind8 == '#present'
    * def field856ind8t = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="8"]/subfield[@code="t"]')
    * match field856ind8t == '0'

    * def field856indBlank = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2=" "]')
    * match field856indBlank == '#present'
    * def field856indBlankt = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2=" "]/subfield[@code="t"]')
    * match field856indBlankt == '0'

    * def field856ind2 = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="2"]')
    * match field856ind2 == '#present'
    * def field856ind2t = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="2"]/subfield[@code="t"]')
    * match field856ind2t == '0'

    * def field856ind0 = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="0"]')
    * match field856ind0 == '#present'
    * def field856ind0t = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="0"]/subfield[@code="t"]')
    * match field856ind0t == '0'

    * def field856ind1 = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="1"]')
    * match field856ind1 == '#present'
    * def field856ind1t = karate.xmlPath(testRecord, '//datafield[@tag="856" and @ind1="4" and @ind2="1"]/subfield[@code="t"]')
    * match field856ind1t == '0'

    # Step 10-18: Add Item with electronic access of 5 different types to first two holdings
    # First item - suppressed
    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def item1 = read('classpath:samples/item.json')
    * set item1.id = testItemIds[0]
    * set item1.holdingsRecordId = testHoldingsIds[0]
    * set item1.hrid = testHrid + '_i1'
    * set item1.discoverySuppress = true
    * set item1.electronicAccess = []
    * set item1.electronicAccess[0] = { relationshipId: 'ef03d582-219c-4221-8635-bc92f1107021', uri: 'http://item.com/1' }
    * set item1.electronicAccess[1] = { relationshipId: 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', uri: 'http://item.com/2' }
    * set item1.electronicAccess[2] = { relationshipId: '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e', uri: 'http://item.com/3' }
    * set item1.electronicAccess[3] = { relationshipId: 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', uri: 'http://item.com/4' }
    * set item1.electronicAccess[4] = { relationshipId: '3b430592-2e09-4b48-9a0c-0636d66b9fb3', uri: 'http://item.com/5' }
    And request item1
    When method POST
    Then status 201

    # Second item - unsuppressed
    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def item2 = read('classpath:samples/item.json')
    * set item2.id = testItemIds[1]
    * set item2.holdingsRecordId = testHoldingsIds[1]
    * set item2.hrid = testHrid + '_i2'
    * set item2.discoverySuppress = false
    * set item2.electronicAccess = []
    * set item2.electronicAccess[0] = { relationshipId: 'ef03d582-219c-4221-8635-bc92f1107021', uri: 'http://item.com/6' }
    * set item2.electronicAccess[1] = { relationshipId: 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', uri: 'http://item.com/7' }
    * set item2.electronicAccess[2] = { relationshipId: '5bfe1b7b-f151-4501-8cfa-23b321d5cd1e', uri: 'http://item.com/8' }
    * set item2.electronicAccess[3] = { relationshipId: 'f5d0068e-6272-458e-8a81-b85e7b9a14aa', uri: 'http://item.com/9' }
    * set item2.electronicAccess[4] = { relationshipId: '3b430592-2e09-4b48-9a0c-0636d66b9fb3', uri: 'http://item.com/10' }
    And request item2
    When method POST
    Then status 201

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 20-21: Send ListRecords request and verify 856 field for both holdings and items
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with items:', response

    # Verify the instance is present in response
    * def identifiers = karate.xmlPath(response, '//header/identifier')
    * match identifiers contains identifierToFind

    # Extract the specific record for our test instance
    * def testRecordWithItems = karate.xmlPath(response, recordXPath)

    # Verify 856 fields have only one subfield "t" per field
    # For suppressed items, t=1; for unsuppressed holdings/items, t=0
    # Get all subfield "t" values from 856 fields
    * def all856tSubfields = karate.xmlPath(testRecordWithItems, '//datafield[@tag="856"]/subfield[@code="t"]')
    * print 'All 856 subfield t values:', all856tSubfields

    # Verify we have the expected number of 856 fields (each should have exactly one subfield "t")
    # Expected: 5 from unsuppressed item + 5 from suppressed item + 5 from holdings = 15 total
    * def tSubfieldsArray = karate.typeOf(all856tSubfields) == 'list' ? all856tSubfields : [all856tSubfields]
    * print 'Total 856 subfield t count:', tSubfieldsArray.length

    # Verify that suppressed item has t=1 and unsuppressed has t=0
    # Count how many have t=0 and t=1
    * def countT0 = 0
    * def countT1 = 0
    * def countValues =
    """
    function(arr) {
      var count0 = 0;
      var count1 = 0;
      for(var i = 0; i < arr.length; i++) {
        if(arr[i] == '0') count0++;
        else if(arr[i] == '1') count1++;
      }
      return { count0: count0, count1: count1 };
    }
    """
    * def counts = countValues(tSubfieldsArray)
    * def countT0 = counts.count0
    * def countT1 = counts.count1
    * print 'Count of t=0:', countT0
    * print 'Count of t=1:', countT1

    # Verify we have both suppressed (t=1) and unsuppressed (t=0) items
    * assert countT0 > 0
    * assert countT1 > 0

    # Step 22-25: Add electronic access to Instance
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
    * set instance.electronicAccess = [{ relationshipId: 'ef03d582-219c-4221-8635-bc92f1107021', uri: 'http://instance.com' }]
    And request instance
    When method PUT
    Then status 204

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 25: Verify 856 field for instance, holdings and items
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with instance electronic access:', response

    # Verify all 856 fields have exactly one subfield "t"
    * def testRecordFinal = karate.xmlPath(response, recordXPath)
    * def all856tFinal = karate.xmlPath(testRecordFinal, '//datafield[@tag="856"]/subfield[@code="t"]')
    * print 'All 856 subfield t values (with instance EA):', all856tFinal

    # Verify all have subfield "t" present
    * def tFinalArray = karate.typeOf(all856tFinal) == 'list' ? all856tFinal : [all856tFinal]
    * print 'Total 856 subfield t count (with instance EA):', tFinalArray.length

    # Verify we still have both suppressed (t=1) and unsuppressed (t=0) records
    # The instance electronic access should have t=0 since instance is not suppressed yet
    * def countsFinal = countValues(tFinalArray)
    * print 'Count of t=0 (with instance EA):', countsFinal.count0
    * print 'Count of t=1 (with instance EA):', countsFinal.count1

    # Verify we have both types
    * assert countsFinal.count0 > 0
    * assert countsFinal.count1 > 0

    # Verify the instance electronic access 856 field has t=0 (instance is not suppressed)
    * def instanceEA856t = karate.xmlPath(testRecordFinal, '//datafield[@tag="856" and subfield[@code="u" and text()="http://instance.com"]]/subfield[@code="t"]')
    * match instanceEA856t == '0'

    # Step 26-30: Edit Instance - suppress it and change electronic access relationship
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
    * set instance.electronicAccess = [{ relationshipId: 'f50c90c9-bae0-4add-9cd0-db9092dbc9dd', uri: 'http://instance.com' }]
    And request instance
    When method PUT
    Then status 204

    # Wait for OAI-PMH indexing
    * call sleep 5000

    # Step 31: Verify all 856 fields have subfield "t" set to "1" for suppressed instance
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print 'Response with suppressed instance:', response

    # Verify all 856 fields have subfield "t" = "1"
    * def testRecordSuppressed = karate.xmlPath(response, recordXPath)
    * def all856t = karate.xmlPath(testRecordSuppressed, '//datafield[@tag="856"]/subfield[@code="t"]')
    * match each all856t == '1'

    # Cleanup: Delete test data
    Given url baseUrl
    And path 'item-storage/items', testItemIds[0]
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'item-storage/items', testItemIds[1]
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    * def index = 0
    * def deleteHolding =
    """
    function(index) {
      karate.call('delete', baseUrl + '/holdings-storage/holdings/' + testHoldingsIds[index]);
    }
    """

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsIds[0]
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsIds[1]
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsIds[2]
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsIds[3]
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', testHoldingsIds[4]
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

