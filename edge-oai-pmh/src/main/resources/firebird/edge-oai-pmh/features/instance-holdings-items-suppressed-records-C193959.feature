@parallel=false
Feature: ListRecords: Harvest suppressed from discovery instance, holdings and items records with marc21_withholdings

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed records behavior with items when configured to skip suppressed from discovery
    # Create test-specific reference data
    * def instanceTypeId = 'bbbb2222-da28-472b-be90-d442e2428002'
    * def materialTypeId = 'bbbb2222-2e4f-452d-9cae-9cee66c9a002'
    * def permanentLoanTypeId = 'bbbb2222-fca9-4892-a730-03ee529ffe02'
    * def permanentLocationId = 'bbbb2222-a8eb-461b-acd6-5dea81771002'
    * def holdingsSourceId = 'bbbb2222-df79-46b3-8932-cdd35f7a2202'
    * def callNumberTypeId = 'bbbb2222-deb5-4c4d-8c9e-2291b7c0f402'
    
    # Create holdings source
    Given path 'holdings-sources'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(holdingsSourceId)", "name": "FOLIO-C193959", "source": "folio" }
    When method POST
    Then status 201
    
    # Create instance type
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(instanceTypeId)", "name": "text-c193959", "code": "txtc193959", "source": "rdacontent" }
    When method POST
    Then status 201
    
    # Create material type
    Given path 'material-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(materialTypeId)", "name": "book-c193959", "source": "folio" }
    When method POST
    Then status 201
    
    # Create loan type
    Given path 'loan-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(permanentLoanTypeId)", "name": "Can circulate-c193959" }
    When method POST
    Then status 201
    
    # Create call number type
    Given path 'call-number-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(callNumberTypeId)", "name": "UDC-c193959", "source": "folio" }
    When method POST
    Then status 201
    
    # Create location hierarchy (institution -> campus -> library -> location)
    Given path 'location-units/institutions'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "bbbb2222-a518-4b49-be01-0638d0a4ac02", "name": "Test Institution C193959", "code": "TIC193959" }
    When method POST
    Then status 201
    
    Given path 'location-units/campuses'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "bbbb2222-cca5-4d33-9217-edf42ce1a802", "name": "Test Campus C193959", "code": "TCC193959", "institutionId": "bbbb2222-a518-4b49-be01-0638d0a4ac02" }
    When method POST
    Then status 201
    
    Given path 'location-units/libraries'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "bbbb2222-ca04-4b4a-aeae-2c63b9245102", "name": "Test Library C193959", "code": "TLC193959", "campusId": "bbbb2222-cca5-4d33-9217-edf42ce1a802" }
    When method POST
    Then status 201
    
    # Create location (using existing service point from tenant setup)
    Given path 'locations'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request
    """
    {
      "id": "#(permanentLocationId)",
      "name": "Test Location C193959",
      "code": "TI/TC/TL/C193959",
      "isActive": true,
      "institutionId": "bbbb2222-a518-4b49-be01-0638d0a4ac02",
      "campusId": "bbbb2222-cca5-4d33-9217-edf42ce1a802",
      "libraryId": "bbbb2222-ca04-4b4a-aeae-2c63b9245102",
      "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
      "servicePointIds": ["3a40852d-49fd-4df2-a1f9-6e2641a6e91f"],
      "servicePoints": []
    }
    """
    When method POST
    Then status 201

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

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

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
    * set holding.sourceId = holdingsSourceId
    * set holding.callNumberTypeId = callNumberTypeId
    * set holding.discoverySuppress = true
    And request holding
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


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

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


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

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


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
    * set holding2.sourceId = holdingsSourceId
    * set holding2.callNumberTypeId = callNumberTypeId
    * set holding2.discoverySuppress = false
    And request holding2
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

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

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


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

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Get today's date in yyyy-MM-dd format
    * def currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())

    # Wait a moment to ensure records are indexed
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * eval sleep(2000)

    # -------------------------------------------------------
    # Test 1: Verify instance, holdings and items all suppressed
    # → record should NOT be in response
    # -------------------------------------------------------
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200

    * print 'Response for all suppressed test:', response

    # No <record> should be present at all
    And match karate.xmlPath(response, "//*[local-name()='record']") == '#notpresent'

    * print 'Test 1 Passed: Record with instance, holdings, and items all suppressed is not in response'

    # -------------------------------------------------------
    # Wait between tests (good practice)
    # -------------------------------------------------------
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * eval sleep(5000)

    # -------------------------------------------------------
    # Test 2: Verify only item suppressed
    # → instance + holdings present, suppressed item not included
    # IMPORTANT: NO `from` param here
    # -------------------------------------------------------
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    When method GET
    Then status 200
    * print 'Response for item suppressed test:', response

    # -------------------------------------------------------
    # Instance exists
    # -------------------------------------------------------
    And match karate.xmlPath(response, "//*[local-name()='record']") != '#notpresent'
    * print 'Test 2 Part 1 Passed: Instance record is present'

    # -------------------------------------------------------
    # Holdings data is present (via tag 952)
    # -------------------------------------------------------
    * def holdingsTag952 = karate.xmlPath(response, "//*[local-name()='datafield'][@tag='952']")
    * print 'Holdings tag 952:', holdingsTag952
    And match holdingsTag952 != '#notpresent'
    * print 'Test 2 Part 2 Passed: Holdings data (952) is present'

    # -------------------------------------------------------
    # Item data (952): only non-suppressed items
    # -------------------------------------------------------
    * def itemTags952 = karate.xmlPath(response, "//*[local-name()='datafield'][@tag='952']")
    * print 'Item tags 952:', itemTags952
    And match itemTags952 != '#notpresent'
    # -------------------------------------------------------
    # Extract barcodes (subfield m)
    # -------------------------------------------------------
    * def barcodes = karate.xmlPath(response,"//*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m']")
    * print 'Barcodes found:', barcodes

    # -------------------------------------------------------
    # Suppressed item barcode MUST NOT be present
    # -------------------------------------------------------
    * def suppressedBarcodeFound = karate.filter(barcodes, function(bc){ return bc == '645398607548' })
    And match suppressedBarcodeFound == []
    * print 'Test 2 Part 3 Passed: Suppressed item barcode is NOT present'

    # -------------------------------------------------------
    # Non-suppressed item barcode MUST be present
    # -------------------------------------------------------
    * def nonSuppressedBarcodeFound = karate.filter(barcodes, function(bc){ return bc == '645398607547' })
    And match nonSuppressedBarcodeFound != []
    * print 'Test 2 Part 4 Passed: Non-suppressed item barcode IS present'

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000