@parallel=false
Feature: ListRecords: Harvest suppressed from discovery instance, holdings and items records with marc21_withholdings

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed records behavior with items when configured to skip suppressed from discovery
    # Configure OAI-PMH to skip suppressed records
    Given path '/oai-pmh/configuration-settings'
    And param name = 'behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def configResponse = response
    * def behaviorId = get[0] configResponse.configurationSettings[?(@.configName=='behavior')].id
    * def updatePayload = read('classpath:samples/behavior.json')
    * set updatePayload.configValue.suppressedRecordsProcessing = 'false'
    * set updatePayload.configValue.recordsSource = 'Source record storage'
    * set updatePayload.configValue.deletedRecordsSupport = 'persistent'
    * set updatePayload.configValue.errorsProcessing = '200'
    Given path '/oai-pmh/configuration-settings', behaviorId
    And request updatePayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

    # Scenario 1: Create instance, holdings, and items all suppressed
    # Create instance with discoverySuppress set to true
    * def allSuppressedInstanceId = 'dddd4444-9f41-4837-8662-a1d99118003a'
    * def allSuppressedInstanceHrid = 'inst000000001003'
    * def allSuppressedJobExecutionId = 'dddd4444-1caf-4470-9ad1-d533f6360bc3'
    * def allSuppressedRecordId = 'dddd4444-1caf-4470-9ad1-d533f6360bc3'
    * def allSuppressedMatchedId = 'dddd4444-e1d4-11e8-9f32-f2801f1b9fd3'
    * def allSuppressedHoldingId = 'dddd4444-e4f1-4e4f-9024-adf0b0039d03'
    * def allSuppressedHoldingHrid = 'hold000000001003'
    * def allSuppressedItemId = 'dddd4444-c008-4c96-8f8f-b666850ee103'
    * def allSuppressedItemHrid = 'item000000001003'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = allSuppressedInstanceId
    * set instance.instanceTypeId = instanceTypeId
    * set instance.hrid = allSuppressedInstanceHrid
    * set instance.source = 'MARC'
    * set instance.discoverySuppress = true
    And request instance
    When method POST
    Then status 201

    # Create SRS record for the instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(allSuppressedJobExecutionId)', instanceId: '#(allSuppressedInstanceId)', recordId: '#(allSuppressedRecordId)', matchedId: '#(allSuppressedMatchedId)'}

    # Create holdings with discoverySuppress set to true
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = allSuppressedHoldingId
    * set holding.instanceId = allSuppressedInstanceId
    * set holding.hrid = allSuppressedHoldingHrid
    * set holding.permanentLocationId = permanentLocationId
    * set holding.discoverySuppress = true
    And request holding
    When method POST
    Then status 201

    # Create item with discoverySuppress set to true
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item = read('classpath:samples/item.json')
    * set item.id = allSuppressedItemId
    * set item.hrid = allSuppressedItemHrid
    * set item.barcode = '145398607547'
    * set item.holdingsRecordId = allSuppressedHoldingId
    * set item.materialTypeId = materialTypeId
    * set item.permanentLoanTypeId = permanentLoanTypeId
    * set item.effectiveLocationId = permanentLocationId
    * set item.discoverySuppress = true
    And request item
    When method POST
    Then status 201

    # Scenario 2: Create instance (not suppressed), holdings (not suppressed), but item suppressed
    * def itemSuppressedInstanceId = 'eeee5555-9f41-4837-8662-a1d99118004a'
    * def itemSuppressedInstanceHrid = 'inst000000001004'
    * def itemSuppressedJobExecutionId = 'eeee5555-1caf-4470-9ad1-d533f6360bc4'
    * def itemSuppressedRecordId = 'eeee5555-1caf-4470-9ad1-d533f6360bc4'
    * def itemSuppressedMatchedId = 'eeee5555-e1d4-11e8-9f32-f2801f1b9fd4'
    * def itemSuppressedHoldingId = 'eeee5555-e4f1-4e4f-9024-adf0b0039d04'
    * def itemSuppressedHoldingHrid = 'hold000000001004'
    * def itemSuppressedItemId = 'eeee5555-c008-4c96-8f8f-b666850ee104'
    * def itemSuppressedItemHrid = 'item000000001004'
    * def itemSuppressedItem2Id = 'eeee5555-c008-4c96-8f8f-b666850ee105'
    * def itemSuppressedItem2Hrid = 'item000000001005'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance2 = read('classpath:samples/instance.json')
    * set instance2.id = itemSuppressedInstanceId
    * set instance2.instanceTypeId = instanceTypeId
    * set instance2.hrid = itemSuppressedInstanceHrid
    * set instance2.source = 'MARC'
    * set instance2.discoverySuppress = false
    And request instance2
    When method POST
    Then status 201

    # Create SRS record for the instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(itemSuppressedJobExecutionId)', instanceId: '#(itemSuppressedInstanceId)', recordId: '#(itemSuppressedRecordId)', matchedId: '#(itemSuppressedMatchedId)'}

    # Create holdings with discoverySuppress set to false
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding2 = read('classpath:samples/holding.json')
    * set holding2.id = itemSuppressedHoldingId
    * set holding2.instanceId = itemSuppressedInstanceId
    * set holding2.hrid = itemSuppressedHoldingHrid
    * set holding2.permanentLocationId = permanentLocationId
    * set holding2.discoverySuppress = false
    And request holding2
    When method POST
    Then status 201

    # Create item with discoverySuppress set to true
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item2 = read('classpath:samples/item.json')
    * set item2.id = itemSuppressedItemId
    * set item2.hrid = itemSuppressedItemHrid
    * set item2.holdingsRecordId = itemSuppressedHoldingId
    * set item2.materialTypeId = materialTypeId
    * set item2.permanentLoanTypeId = permanentLoanTypeId
    * set item2.effectiveLocationId = permanentLocationId
    * set item2.discoverySuppress = true
    * set item2.barcode = '645398607548'
    And request item2
    When method POST
    Then status 201

    # Create a second item (not suppressed) for the same holdings to verify partial item suppression
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item3 = read('classpath:samples/item.json')
    * set item3.id = itemSuppressedItem2Id
    * set item3.hrid = itemSuppressedItem2Hrid
    * set item3.holdingsRecordId = itemSuppressedHoldingId
    * set item3.materialTypeId = materialTypeId
    * set item3.permanentLoanTypeId = permanentLoanTypeId
    * set item3.effectiveLocationId = permanentLocationId
    * set item3.discoverySuppress = false
    * set item3.barcode = '645398607549'
    And request item3
    When method POST
    Then status 201

    # Get today's date in yyyy-MM-dd format
    * def currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())

    # Wait a moment to ensure records are indexed
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * eval sleep(2000)

    # Test 1: Verify instance, holdings and items all suppressed - record should NOT be in response
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response for all suppressed test:', response
    * def records = get response //record
    * def allSuppressedFound = karate.filter(records, function(r){ return r.header.identifier == allSuppressedInstanceId })
    And match allSuppressedFound == []
    * print 'Test 1 Passed: Record with instance, holdings, and items all suppressed is not in response'

    # Test 2: Verify only item suppressed - instance and holdings should be in response, but suppressed item data should not be included
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response for item suppressed test:', response
    * def records2 = get response //record
    * def itemSuppressedFound = karate.filter(records2, function(r){ return r.header.identifier == itemSuppressedInstanceId })
    
    # Verify the instance record is present
    And match itemSuppressedFound != []
    And match itemSuppressedFound[0].header.identifier == itemSuppressedInstanceId
    * print 'Test 2 Part 1 Passed: Instance record is present when only item is suppressed'

    # Verify holdings data (tag 852) IS present for this record
    * def recordMetadata = itemSuppressedFound[0].metadata
    * def xmlString = karate.xmlPath(recordMetadata, '/')
    * print 'Record XML:', xmlString
    
    # Check that holdings-specific tag 852 is present
    * def holdingsTag852 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='852']")
    * print 'Holdings tag 852:', holdingsTag852
    And match holdingsTag852 != []
    * print 'Test 2 Part 2 Passed: Holdings data (tag 852) is present'

    # Verify item data (tag 952) - should contain only non-suppressed item
    * def itemTags952 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='952']")
    * print 'Item tags 952:', itemTags952
    
    # Get all barcodes from tag 952
    * def barcodes = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m']")
    * print 'Barcodes found:', barcodes
    
    # Verify that suppressed item barcode '645398607548' is NOT present
    * def suppressedBarcodeFound = karate.filter(barcodes, function(bc){ return bc == '645398607548' })
    And match suppressedBarcodeFound == []
    * print 'Test 2 Part 3 Passed: Suppressed item barcode (645398607548) is not in response'
    
    # Verify that non-suppressed item barcode '645398607549' IS present
    * def nonSuppressedBarcodeFound = karate.filter(barcodes, function(bc){ return bc == '645398607549' })
    And match nonSuppressedBarcodeFound != []
    * print 'Test 2 Part 4 Passed: Non-suppressed item barcode (645398607549) is present in response'

    # Cleanup: Delete created records in reverse order (items -> holdings -> instances)
    * url baseUrl
    Given path 'item-storage/items', allSuppressedItemId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', allSuppressedHoldingId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', allSuppressedInstanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'item-storage/items', itemSuppressedItemId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'item-storage/items', itemSuppressedItem2Id
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', itemSuppressedHoldingId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', itemSuppressedInstanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204
