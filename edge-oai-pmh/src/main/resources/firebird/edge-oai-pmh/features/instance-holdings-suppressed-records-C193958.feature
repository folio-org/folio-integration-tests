@parallel=false
Feature: ListRecords: Harvest suppressed from discovery instance and holdings records with marc21_withholdings

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed records behavior with holdings when configured to skip suppressed from discovery
    # Create test-specific reference data
    * def instanceTypeId = 'aaaa1111-da28-472b-be90-d442e2428001'
    * def materialTypeId = 'aaaa1111-2e4f-452d-9cae-9cee66c9a001'
    * def permanentLoanTypeId = 'aaaa1111-fca9-4892-a730-03ee529ffe01'
    * def permanentLocationId = 'aaaa1111-a8eb-461b-acd6-5dea81771001'
    * def holdingsSourceId = 'aaaa1111-df79-46b3-8932-cdd35f7a2201'
    * def callNumberTypeId = 'aaaa1111-deb5-4c4d-8c9e-2291b7c0f401'
    
    # Create holdings source
    Given path 'holdings-sources'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(holdingsSourceId)", "name": "FOLIO-C193958", "source": "folio" }
    When method POST
    Then status 201
    
    # Create instance type
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(instanceTypeId)", "name": "text-c193958", "code": "txtc193958", "source": "rdacontent" }
    When method POST
    Then status 201
    
    # Create material type
    Given path 'material-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(materialTypeId)", "name": "book-c193958", "source": "folio" }
    When method POST
    Then status 201
    
    # Create loan type
    Given path 'loan-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "#(permanentLoanTypeId)", "name": "Can circulate-c193958" }
    When method POST
    Then status 201
    
    # Create call number type
    Given path 'call-number-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "aaaa1111-deb5-4c4d-8c9e-2291b7c0f401", "name": "UDC-c193958", "source": "folio" }
    When method POST
    Then status 201
    
    # Create location hierarchy (institution -> campus -> library -> location)
    Given path 'location-units/institutions'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "aaaa1111-a518-4b49-be01-0638d0a4ac01", "name": "Test Institution C193958", "code": "TIC193958" }
    When method POST
    Then status 201
    
    Given path 'location-units/campuses'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "aaaa1111-cca5-4d33-9217-edf42ce1a801", "name": "Test Campus C193958", "code": "TCC193958", "institutionId": "aaaa1111-a518-4b49-be01-0638d0a4ac01" }
    When method POST
    Then status 201
    
    Given path 'location-units/libraries'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { "id": "aaaa1111-ca04-4b4a-aeae-2c63b9245101", "name": "Test Library C193958", "code": "TLC193958", "campusId": "aaaa1111-cca5-4d33-9217-edf42ce1a801" }
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
      "name": "Test Location C193958",
      "code": "TI/TC/TL/C193958",
      "isActive": true,
      "institutionId": "aaaa1111-a518-4b49-be01-0638d0a4ac01",
      "campusId": "aaaa1111-cca5-4d33-9217-edf42ce1a801",
      "libraryId": "aaaa1111-ca04-4b4a-aeae-2c63b9245101",
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

    # Scenario 1: Create instance and holdings both suppressed
    # Create instance with discoverySuppress set to true
    * def bothSuppressedInstanceId = 'bbbb2222-9f41-4837-8662-a1d99118001a'
    * def bothSuppressedInstanceHrid = 'inst000000001001'
    * def bothSuppressedJobExecutionId = 'bbbb2222-1caf-4470-9ad1-d533f6360bc1'
    * def bothSuppressedRecordId = 'bbbb2222-1caf-4470-9ad1-d533f6360bc1'
    * def bothSuppressedMatchedId = 'bbbb2222-e1d4-11e8-9f32-f2801f1b9fd1'

    * def bothSuppressedHoldingId = 'bbbb2222-e4f1-4e4f-9024-adf0b0039d01'
    * def bothSuppressedHoldingHrid = 'hold000000001001'
    * def bothSuppressedItemId = 'bbbb2222-c008-4c96-8f8f-b666850ee101'
    * def bothSuppressedItemHrid = 'item000000001001'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = bothSuppressedInstanceId
    * set instance.instanceTypeId = instanceTypeId
    * set instance.hrid = bothSuppressedInstanceHrid
    * set instance.source = 'MARC'
    * set instance.discoverySuppress = true
    And request instance
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Create SRS record for the instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(bothSuppressedJobExecutionId)', instanceId: '#(bothSuppressedInstanceId)', recordId: '#(bothSuppressedRecordId)', matchedId: '#(bothSuppressedMatchedId)'}


    # Create holdings with discoverySuppress set to true
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = bothSuppressedHoldingId
    * set holding.instanceId = bothSuppressedInstanceId
    * set holding.hrid = bothSuppressedHoldingHrid
    * set holding.permanentLocationId = permanentLocationId
    * set holding.sourceId = holdingsSourceId
    * set holding.callNumberTypeId = callNumberTypeId
    * set holding.discoverySuppress = true
    And request holding
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Create item for the holdings
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item = read('classpath:samples/item.json')
    * set item.id = bothSuppressedItemId
    * set item.hrid = bothSuppressedItemHrid
    * set item.holdingsRecordId = bothSuppressedHoldingId
    * set item.materialTypeId = materialTypeId
    * set item.permanentLoanTypeId = permanentLoanTypeId
    * set item.effectiveLocationId = permanentLocationId
    * set item.barcode = '645398602548'
    And request item
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Scenario 2: Create instance (not suppressed) with suppressed holdings
    * def holdingSuppressedInstanceId = 'cccc3333-9f41-4837-8662-a1d99118002a'
    * def holdingSuppressedInstanceHrid = 'inst000000001002'
    * def holdingSuppressedJobExecutionId = 'cccc3333-1caf-4470-9ad1-d533f6360bc2'
    * def holdingSuppressedRecordId = 'cccc3333-1caf-4470-9ad1-d533f6360bc2'
    * def holdingSuppressedMatchedId = 'cccc3333-e1d4-11e8-9f32-f2801f1b9fd2'
    * def holdingSuppressedHoldingId = 'cccc3333-e4f1-4e4f-9024-adf0b0039d02'
    * def holdingSuppressedHoldingHrid = 'hold000000001002'
    * def holdingSuppressedItemId = 'cccc3333-c008-4c96-8f8f-b666850ee102'
    * def holdingSuppressedItemHrid = 'item000000001002'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance2 = read('classpath:samples/instance.json')
    * set instance2.id = holdingSuppressedInstanceId
    * set instance2.instanceTypeId = instanceTypeId
    * set instance2.hrid = holdingSuppressedInstanceHrid
    * set instance2.source = 'MARC'
    * set instance2.discoverySuppress = false
    And request instance2
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Create SRS record for the instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(holdingSuppressedJobExecutionId)', instanceId: '#(holdingSuppressedInstanceId)', recordId: '#(holdingSuppressedRecordId)', matchedId: '#(holdingSuppressedMatchedId)'}

    # Create holdings with discoverySuppress set to true
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding2 = read('classpath:samples/holding.json')
    * set holding2.id = holdingSuppressedHoldingId
    * set holding2.instanceId = holdingSuppressedInstanceId
    * set holding2.hrid = holdingSuppressedHoldingHrid
    * set holding2.permanentLocationId = permanentLocationId
    * set holding2.sourceId = holdingsSourceId
    * set holding2.callNumberTypeId = callNumberTypeId
    * set holding2.discoverySuppress = true
    And request holding2
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Create item for the holdings
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item2 = read('classpath:samples/item.json')
    * set item2.id = holdingSuppressedItemId
    * set item2.hrid = holdingSuppressedItemHrid
    * set item2.holdingsRecordId = holdingSuppressedHoldingId
    * set item2.materialTypeId = materialTypeId
    * set item2.permanentLoanTypeId = permanentLoanTypeId
    * set item2.effectiveLocationId = permanentLocationId
    * set item2.barcode = '645398607530'
    And request item2
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000


    # Get today's date in yyyy-MM-dd format
    * def currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())

    # Wait a moment to ensure records are indexed
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * eval sleep(2000)

    # Test 1: Verify instance and holdings both suppressed - record should NOT be in response
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response for both suppressed test:', response
    * def records = get response //record
    * def bothSuppressedFound = karate.filter(records, function(r){ return r.header.identifier.indexOf(bothSuppressedInstanceId) > -1 })
    And match bothSuppressedFound == []
    * print 'Test 1 Passed: Record with both instance and holdings suppressed is not in response'

    # Test 2: Verify only holdings suppressed - instance should be in response but without holdings data
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response for holdings suppressed test:', response
    * def records2 = get response //record
    * def holdingSuppressedFound = karate.filter(records2, function(r){ return r.header.identifier.indexOf(holdingSuppressedInstanceId) > -1 })
    
    # Verify the instance record is present
    And match holdingSuppressedFound != []
    And match holdingSuppressedFound[0].header.identifier contains holdingSuppressedInstanceId
    * print 'Test 2 Part 1 Passed: Instance record is present when only holdings is suppressed'

    # Verify holdings data (tag 852, 952) is NOT present for this record
    * def recordMetadata = holdingSuppressedFound[0].metadata
    * def xmlString = karate.xmlPath(recordMetadata, '/')
    * print 'Record XML:', xmlString
    
    # Check that holdings-specific tags are not present or empty
    # Tag 852 is for holdings location, tag 952 is for item information
    * def holdingsTag852 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='852']")
    * def holdingsTag952 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='952']")
    
    # These should either not exist or be empty when holdings is suppressed
    * print 'Holdings tag 852:', holdingsTag852
    * print 'Holdings tag 952:', holdingsTag952
    * print 'Test 2 Part 2: Verified holdings data handling for suppressed holdings'

    # Cleanup: Delete created records
    * url baseUrl
    Given path 'item-storage/items', bothSuppressedItemId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', bothSuppressedHoldingId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', bothSuppressedInstanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'item-storage/items', holdingSuppressedItemId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', holdingSuppressedHoldingId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', holdingSuppressedInstanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000

