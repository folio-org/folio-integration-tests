@parallel=false
Feature: ListRecords: Harvest suppressed holdings and items records with discovery flag using marc21_withholdings

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed holdings and items are included with discovery flags when configured to transfer suppressed records
    # Create unique reference data for this test
    
    # Create instance type
    * def instanceTypeId = '7243993f-a801-4608-a49b-abb2c17feefe'
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(instanceTypeId)', name: 'Test Type C193961', code: 'ttc193961', source: 'local' }
    When method POST
    Then status 201

    # Create material type
    * def materialTypeId = '43ed07a4-52ab-4b82-b0e1-8aa6084d2a41'
    Given path 'material-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(materialTypeId)', name: 'Test Material C193961', source: 'local' }
    When method POST
    Then status 201

    # Create loan type
    * def permanentLoanTypeId = 'd832b6fd-2518-4ad3-b0d4-70cd34eeb821'
    Given path 'loan-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(permanentLoanTypeId)', name: 'Test Loan C193961' }
    When method POST
    Then status 201

    # Create call number type
    * def callNumberTypeId = '51945daa-5a88-43be-b041-9b42069514c2'
    Given path 'call-number-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(callNumberTypeId)', name: 'Test Call Number C193961', source: 'local' }
    When method POST
    Then status 201

    # Create holdings source
    * def holdingsSourceId = '6f42c264-076b-4834-86ff-a4b7760c312e'
    Given path 'holdings-sources'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(holdingsSourceId)', name: 'Test Source C193961', source: 'local' }
    When method POST
    Then status 201

    # Create location hierarchy (institution -> campus -> library -> location)
    * def institutionId = '8f42c264-076b-4834-86ff-a4b7760c312e'
    Given path 'location-units/institutions'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(institutionId)', name: 'Test Institution C193961', code: 'TIC193961' }
    When method POST
    Then status 201

    * def campusId = '6f42c264-076b-4834-86ef-a4b7760c312e'
    Given path 'location-units/campuses'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(campusId)', name: 'Test Campus C193961', code: 'TCC193961', institutionId: '#(institutionId)' }
    When method POST
    Then status 201

    * def libraryId = '484f5d79-202d-41cf-8243-6802b0697874'
    Given path 'location-units/libraries'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(libraryId)', name: 'Test Library C193961', code: 'TLC193961', campusId: '#(campusId)' }
    When method POST
    Then status 201

    * def permanentLocationId = '95eb9afd-e7a3-48db-ac00-3fffc96ea50e'
    * def servicePointId = '3a40852d-49fd-4df2-a1f9-6e2641a6e91f'
    Given path 'locations'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(permanentLocationId)', name: 'Test Location C193961', code: 'TLC193961', institutionId: '#(institutionId)', campusId: '#(campusId)', libraryId: '#(libraryId)', primaryServicePoint: '#(servicePointId)', servicePointIds: ['#(servicePointId)'] }
    When method POST
    Then status 201
    # Configure OAI-PMH to transfer suppressed records with discovery flag
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
    * set updatePayload.configValue.suppressedRecordsProcessing = 'true'
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

    # Create a new instance (not suppressed)
    * def instanceId = 'aaaa7777-9f41-4837-8662-a1d99118007a'
    * def instanceHrid = 'inst000000001008'
    * def jobExecutionId = 'aaaa7777-1caf-4470-9ad1-d533f6360bc7'
    * def recordId = 'aaaa7777-1caf-4470-9ad1-d533f6360bc7'
    * def matchedId = 'aaaa7777-e1d4-11e8-9f32-f2801f1b9fd7'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.instanceTypeId = instanceTypeId
    * set instance.hrid = instanceHrid
    * set instance.source = 'MARC'
    * set instance.discoverySuppress = false
    And request instance
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Create SRS record for the instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(jobExecutionId)', instanceId: '#(instanceId)', recordId: '#(recordId)', matchedId: '#(matchedId)'}

    # Create holdings with discoverySuppress set to true
    * def holdingId = 'aaaa7777-e4f1-4e4f-9024-adf0b0039d07'
    * def holdingHrid = 'hold000000001008'

    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = holdingId
    * set holding.instanceId = instanceId
    * set holding.hrid = holdingHrid
    * set holding.permanentLocationId = permanentLocationId
    * set holding.callNumberTypeId = callNumberTypeId
    * set holding.sourceId = holdingsSourceId
    * set holding.discoverySuppress = true
    And request holding
    When method POST
    Then status 201

    # Create item with discoverySuppress set to true
    * def itemId = 'aaaa7777-c008-4c96-8f8f-b666850ee107'
    * def itemHrid = 'item000000001008'

    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item = read('classpath:samples/item.json')
    * set item.id = itemId
    * set item.hrid = itemHrid
    * set item.holdingsRecordId = holdingId
    * set item.materialTypeId = materialTypeId
    * set item.permanentLoanTypeId = permanentLoanTypeId
    * set item.effectiveLocationId = permanentLocationId
    * set item.discoverySuppress = true
    * set item.barcode = '645398607550'
    And request item
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Get today's date in yyyy-MM-dd format
    * def currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())

    # Wait a moment to ensure records are indexed
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * eval sleep(2000)

    # Verify the record with suppressed holdings and items IS in the response with discovery flags
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response for suppressed holdings and items with discovery flags:', response
    
    # The response should contain the record
    * def records = get response //record
    * def recordFound = karate.filter(records, function(r){ return r.header.identifier == instanceId })
    And match recordFound != []
    * print 'Test 1 Passed: Record with suppressed holdings and items is present in response'

    # Get the record metadata
    * def recordMetadata = recordFound[0].metadata
    * def xmlString = karate.xmlPath(recordMetadata, '/')
    * print 'Record XML:', xmlString

    # Verify 999 field contains subfield $t set to 0 (instance not suppressed)
    * def field999 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='999']")
    * print '999 field:', field999
    And match field999 != []
    * print 'Test 2 Passed: 999 field is present'
    
    * def field999_subfield_t = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t']")
    * print '999 field subfield $t value:', field999_subfield_t
    And match field999_subfield_t != []
    
    # Verify that 999 subfield $t is set to 0 (instance is not suppressed)
    * def field999_subfieldValue = field999_subfield_t[0]
    * print '999 field subfield $t content:', field999_subfieldValue
    And match field999_subfieldValue == '0'
    * print 'Test 3 Passed: 999 field subfield $t is set to 0 (instance not suppressed)'

    # Verify 852 field (holdings) contains subfield $t set to 1 (holdings suppressed)
    * def field852 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='852']")
    * print '852 field:', field852
    And match field852 != []
    * print 'Test 4 Passed: 852 field (holdings) is present'
    
    * def field852_subfield_t = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='852']/*[local-name()='subfield'][@code='t']")
    * print '852 field subfield $t value:', field852_subfield_t
    And match field852_subfield_t != []
    
    # Verify that 852 subfield $t is set to 1 (holdings is suppressed)
    * def field852_subfieldValue = field852_subfield_t[0]
    * print '852 field subfield $t content:', field852_subfieldValue
    And match field852_subfieldValue == '1'
    * print 'Test 5 Passed: 852 field subfield $t is set to 1 (holdings suppressed)'

    # Verify 952 field (item) contains subfield $t set to 1 (item suppressed)
    * def field952 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='952']")
    * print '952 field:', field952
    And match field952 != []
    * print 'Test 6 Passed: 952 field (item) is present'
    
    * def field952_subfield_t = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t']")
    * print '952 field subfield $t value:', field952_subfield_t
    And match field952_subfield_t != []
    
    # Verify that 952 subfield $t is set to 1 (item is suppressed)
    * def field952_subfieldValue = field952_subfield_t[0]
    * print '952 field subfield $t content:', field952_subfieldValue
    And match field952_subfieldValue == '1'
    * print 'Test 7 Passed: 952 field subfield $t is set to 1 (item suppressed)'

    # Verify the barcode is present in the response (item data is included)
    * def barcodes = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m']")
    * print 'Barcodes found:', barcodes
    And match barcodes contains '645398607550'
    * print 'Test 8 Passed: Suppressed item barcode is present in response'

    # Create a second scenario with non-suppressed holdings and items for comparison
    * def instanceId2 = 'bbbb8888-9f41-4837-8662-a1d99118008a'
    * def instanceHrid2 = 'inst000000001009'
    * def jobExecutionId2 = 'bbbb8888-1caf-4470-9ad1-d533f6360bc8'
    * def recordId2 = 'bbbb8888-1caf-4470-9ad1-d533f6360bc8'
    * def matchedId2 = 'bbbb8888-e1d4-11e8-9f32-f2801f1b9fd8'
    * def holdingId2 = 'bbbb8888-e4f1-4e4f-9024-adf0b0039d08'
    * def holdingHrid2 = 'hold000000001009'
    * def itemId2 = 'bbbb8888-c008-4c96-8f8f-b666850ee108'
    * def itemHrid2 = 'item000000001009'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance2 = read('classpath:samples/instance.json')
    * set instance2.id = instanceId2
    * set instance2.instanceTypeId = instanceTypeId
    * set instance2.hrid = instanceHrid2
    * set instance2.source = 'MARC'
    * set instance2.discoverySuppress = false
    And request instance2
    When method POST
    Then status 201

    # Create SRS record for the instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(jobExecutionId2)', instanceId: '#(instanceId2)', recordId: '#(recordId2)', matchedId: '#(matchedId2)'}

    # Create holdings with discoverySuppress set to false
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding2 = read('classpath:samples/holding.json')
    * set holding2.id = holdingId2
    * set holding2.instanceId = instanceId2
    * set holding2.hrid = holdingHrid2
    * set holding2.permanentLocationId = permanentLocationId
    * set holding2.callNumberTypeId = callNumberTypeId
    * set holding2.sourceId = holdingsSourceId
    * set holding2.discoverySuppress = false
    And request holding2
    When method POST
    Then status 201

    # Create item with discoverySuppress set to false
    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item2 = read('classpath:samples/item.json')
    * set item2.id = itemId2
    * set item2.hrid = itemHrid2
    * set item2.holdingsRecordId = holdingId2
    * set item2.materialTypeId = materialTypeId
    * set item2.permanentLoanTypeId = permanentLoanTypeId
    * set item2.effectiveLocationId = permanentLocationId
    * set item2.discoverySuppress = false
    * set item2.barcode = '645398607551'
    And request item2
    When method POST
    Then status 201

    # Wait a moment to ensure records are indexed
    * eval sleep(2000)

    # Verify the non-suppressed record
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response with non-suppressed holdings and items:', response
    
    # The response should contain the non-suppressed record
    * def records2 = get response //record
    * def recordFound2 = karate.filter(records2, function(r){ return r.header.identifier == instanceId2 })
    And match recordFound2 != []
    * print 'Test 9 Passed: Record with non-suppressed holdings and items is present in response'

    # Get the non-suppressed record metadata
    * def recordMetadata2 = recordFound2[0].metadata
    * def xmlString2 = karate.xmlPath(recordMetadata2, '/')
    * print 'Non-suppressed record XML:', xmlString2

    # Verify 852 and 952 fields do not have subfield $t set to 1 for non-suppressed record
    * def field852_subfield_t_2 = karate.xmlPath(recordMetadata2, "//*[local-name()='datafield'][@tag='852']/*[local-name()='subfield'][@code='t']")
    * print 'Non-suppressed 852 field subfield $t value:', field852_subfield_t_2
    
    # Verify that 852 subfield $t is either not present or not set to 1
    * def is852NotSuppressed = field852_subfield_t_2.length == 0 || field852_subfield_t_2[0] != '1'
    And match is852NotSuppressed == true
    * print 'Test 10 Passed: Non-suppressed holdings 852 field does not have subfield $t set to 1'
    
    * def field952_subfield_t_2 = karate.xmlPath(recordMetadata2, "//*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='t']")
    * print 'Non-suppressed 952 field subfield $t value:', field952_subfield_t_2
    
    # Verify that 952 subfield $t is either not present or not set to 1
    * def is952NotSuppressed = field952_subfield_t_2.length == 0 || field952_subfield_t_2[0] != '1'
    And match is952NotSuppressed == true
    * print 'Test 11 Passed: Non-suppressed item 952 field does not have subfield $t set to 1'

    # Cleanup: Delete created records in reverse order (items -> holdings -> instances)
    * url baseUrl
    Given path 'item-storage/items', itemId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', holdingId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', instanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'item-storage/items', itemId2
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', holdingId2
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', instanceId2
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    # Delete reference data
    Given path 'locations', permanentLocationId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'location-units/libraries', libraryId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'location-units/campuses', campusId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'location-units/institutions', institutionId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'holdings-sources', holdingsSourceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'call-number-types', callNumberTypeId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'loan-types', permanentLoanTypeId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'material-types', materialTypeId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-types', instanceTypeId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000