Feature: Skip suppressed holdings and items for C193958, C193959

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken
  
  @C193958  
  Scenario: Verify record skipped if both instance and holdings are suppressed
    # Configure OAI-PMH to skip suppressed records
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'false'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

    # Create a new instance
    * def newInstanceId = uuid()
    * def newInstanceHrid = 'inst' + randomMillis()
    * call read('init_data/create-instance.feature') { instanceId: '#(newInstanceId)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(newInstanceHrid)', instanceSource: 'MARC'}

    # Create SRS record for the new instance
    * def newRecordId = uuid()
    * def newMatchedId = uuid()
    * def newJobExecutionId = uuid()
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(newJobExecutionId)', instanceId: '#(newInstanceId)', recordId: '#(newRecordId)', matchedId: '#(newMatchedId)'}

    # Create holding for the new instance
    * def newHoldingId = uuid()
    * def newHoldingHrid = 'hold' + randomMillis()
    * call read('init_data/create-holding.feature') { holdingId: '#(newHoldingId)', instanceId: '#(newInstanceId)', permanentLocationId: '#(permanentLocationId)', holdingHrid: '#(newHoldingHrid)'}

    # Mark the instance record as suppressed from discovery
    Given path 'instance-storage/instances', newInstanceId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def instance = response
    * set instance.discoverySuppress = true

    Given path 'instance-storage/instances', newInstanceId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request instance
    When method PUT
    Then status 204

    # Update the source record with suppression flag
    Given path 'source-storage/records', newRecordId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def sourceRecord = response
    * set sourceRecord.additionalInfo.suppressDiscovery = true

    Given path 'source-storage/records', newRecordId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request sourceRecord
    When method PUT
    Then status 200

    # Mark the holdings record as suppressed from discovery
    Given path 'holdings-storage/holdings', newHoldingId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def holding = response
    * set holding.discoverySuppress = true

    Given path 'holdings-storage/holdings', newHoldingId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request holding
    When method PUT
    Then status 204

    # Wait for the record to be reindexed
    * pause(10000)

    # Verify the suppressed record is NOT in OAI-PMH response
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200
    # Verify that the suppressed record is NOT included in the response
    And match response //identifier !contains 'oai:folio.org:' + testTenant + '/' + newInstanceId

  Scenario: Verify instance included but suppressed holdings skipped when configured to skip suppressed records
    # Configure OAI-PMH to skip suppressed records (ensure config is set)
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'false'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

    # Create a new instance (not suppressed)
    * def newInstanceId2 = uuid()
    * def newInstanceHrid2 = 'inst' + randomMillis()
    * call read('init_data/create-instance.feature') { instanceId: '#(newInstanceId2)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(newInstanceHrid2)', instanceSource: 'MARC'}

    # Create SRS record for the new instance
    * def newRecordId2 = uuid()
    * def newMatchedId2 = uuid()
    * def newJobExecutionId2 = uuid()
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(newJobExecutionId2)', instanceId: '#(newInstanceId2)', recordId: '#(newRecordId2)', matchedId: '#(newMatchedId2)'}

    # Create holding for the new instance
    * def newHoldingId2 = uuid()
    * def newHoldingHrid2 = 'hold' + randomMillis()
    * call read('init_data/create-holding.feature') { holdingId: '#(newHoldingId2)', instanceId: '#(newInstanceId2)', permanentLocationId: '#(permanentLocationId)', holdingHrid: '#(newHoldingHrid2)'}

    # Create item for the new holding
    * def newItemId2 = uuid()
    * def newItemHrid2 = 'item' + randomMillis()
    * def newBarcode2 = random_string()
    * call read('init_data/create-item.feature') { holdingId: '#(newHoldingId2)', itemId: '#(newItemId2)', itemHrid: '#(newItemHrid2)', barcode: '#(newBarcode2)'}

    # Mark the holdings record as suppressed from discovery
    Given path 'holdings-storage/holdings', newHoldingId2
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def holding = response
    * set holding.discoverySuppress = true

    Given path 'holdings-storage/holdings', newHoldingId2
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request holding
    When method PUT
    Then status 204

    # Wait for the record to be reindexed
    * pause(10000)

    # Verify the instance is in OAI-PMH response but holdings data is skipped
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200
    
    # Verify that the instance record IS included in the response
    And match response //identifier contains 'oai:folio.org:' + testTenant + '/' + newInstanceId2

    # Verify that the suppressed holding is NOT included (check for absence of item barcode in 952)
    * def barcodeInResponse = karate.xmlPath(response, "//record[header/identifier[contains(.,'" + newInstanceId2 + "')]]//datafield[@tag='952']/subfield[@code='m']/text()")
    * print 'Barcode in response:', barcodeInResponse
    # If no 952 fields are found, barcodeInResponse will be '#notpresent' or an empty list
    # If 952 fields exist, verify that our suppressed barcode is not among them
    * def isBarcodeAbsent = barcodeInResponse == '#notpresent' || (karate.typeOf(barcodeInResponse) == 'list' && !barcodeInResponse.contains(newBarcode2)) || (karate.typeOf(barcodeInResponse) == 'string' && barcodeInResponse != newBarcode2)
    And match isBarcodeAbsent == true

  @C193959
  Scenario: Verify instance included but suppressed item skipped when configured to skip suppressed records
    # Configure OAI-PMH to skip suppressed records
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'false'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

    # Create a new instance (not suppressed)
    * def newInstanceId3 = uuid()
    * def newInstanceHrid3 = 'inst' + randomMillis()
    * call read('init_data/create-instance.feature') { instanceId: '#(newInstanceId3)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(newInstanceHrid3)', instanceSource: 'MARC'}

    # Create SRS record for the new instance
    * def newRecordId3 = uuid()
    * def newMatchedId3 = uuid()
    * def newJobExecutionId3 = uuid()
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(newJobExecutionId3)', instanceId: '#(newInstanceId3)', recordId: '#(newRecordId3)', matchedId: '#(newMatchedId3)'}

    # Create holding for the new instance
    * def newHoldingId3 = uuid()
    * def newHoldingHrid3 = 'hold' + randomMillis()
    * call read('init_data/create-holding.feature') { holdingId: '#(newHoldingId3)', instanceId: '#(newInstanceId3)', permanentLocationId: '#(permanentLocationId)', holdingHrid: '#(newHoldingHrid3)'}

    # Create item for the new holding
    * def newItemId3 = uuid()
    * def newItemHrid3 = 'item' + randomMillis()
    * def newBarcode3 = random_string()
    * call read('init_data/create-item.feature') { holdingId: '#(newHoldingId3)', itemId: '#(newItemId3)', itemHrid: '#(newItemHrid3)', barcode: '#(newBarcode3)'}

    # Mark the item record as suppressed from discovery
    Given path 'item-storage/items', newItemId3
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def item = response
    * set item.discoverySuppress = true

    Given path 'item-storage/items', newItemId3
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request item
    When method PUT
    Then status 204

    # Wait for the record to be reindexed
    * pause(10000)

    # Verify the instance is in OAI-PMH response but item data is skipped
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200
    
    # Verify that the instance record IS included in the response
    And match response //identifier contains 'oai:folio.org:' + testTenant + '/' + newInstanceId3

    # Verify that the suppressed item is NOT included (check for absence of item barcode in 952)
    * def barcodeInResponse = karate.xmlPath(response, "//record[header/identifier[contains(.,'" + newInstanceId3 + "')]]//datafield[@tag='952']/subfield[@code='m']/text()")
    * print 'Barcode in response:', barcodeInResponse
    # If no 952 fields are found, barcodeInResponse will be '#notpresent' or an empty list
    # If 952 fields exist, verify that our suppressed barcode is not among them
    * def isBarcodeAbsent = barcodeInResponse == '#notpresent' || (karate.typeOf(barcodeInResponse) == 'list' && !barcodeInResponse.contains(newBarcode3)) || (karate.typeOf(barcodeInResponse) == 'string' && barcodeInResponse != newBarcode3)
    And match isBarcodeAbsent == true

  Scenario: Verify record skipped if instance and item are suppressed
    # Configure OAI-PMH to skip suppressed records
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def behaviorId = get[0] response.configurationSettings[?(@.configName=='behavior')].id
    * def behaviorPayload = read('classpath:samples/behavior.json')
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'false'
    * set behaviorPayload.configValue.deletedRecordsSupport = 'persistent'
    * set behaviorPayload.configValue.errorsProcessing = '200'

    Given path 'oai-pmh/configuration-settings', behaviorId
    And request behaviorPayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

    # Create a new instance
    * def newInstanceId4 = uuid()
    * def newInstanceHrid4 = 'inst' + randomMillis()
    * call read('init_data/create-instance.feature') { instanceId: '#(newInstanceId4)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(newInstanceHrid4)', instanceSource: 'MARC'}

    # Create SRS record for the new instance
    * def newRecordId4 = uuid()
    * def newMatchedId4 = uuid()
    * def newJobExecutionId4 = uuid()
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(newJobExecutionId4)', instanceId: '#(newInstanceId4)', recordId: '#(newRecordId4)', matchedId: '#(newMatchedId4)'}

    # Create holding for the new instance
    * def newHoldingId4 = uuid()
    * def newHoldingHrid4 = 'hold' + randomMillis()
    * call read('init_data/create-holding.feature') { holdingId: '#(newHoldingId4)', instanceId: '#(newInstanceId4)', permanentLocationId: '#(permanentLocationId)', holdingHrid: '#(newHoldingHrid4)'}

    # Create item for the new holding
    * def newItemId4 = uuid()
    * def newItemHrid4 = 'item' + randomMillis()
    * def newBarcode4 = random_string()
    * call read('init_data/create-item.feature') { holdingId: '#(newHoldingId4)', itemId: '#(newItemId4)', itemHrid: '#(newItemHrid4)', barcode: '#(newBarcode4)'}

    # Mark the instance record as suppressed from discovery
    Given path 'instance-storage/instances', newInstanceId4
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def instance = response
    * set instance.discoverySuppress = true

    Given path 'instance-storage/instances', newInstanceId4
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request instance
    When method PUT
    Then status 204

    # Update the source record with suppression flag
    Given path 'source-storage/records', newRecordId4
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def sourceRecord = response
    * set sourceRecord.additionalInfo.suppressDiscovery = true

    Given path 'source-storage/records', newRecordId4
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request sourceRecord
    When method PUT
    Then status 200

    # Mark the item record as suppressed from discovery
    Given path 'item-storage/items', newItemId4
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def item = response
    * set item.discoverySuppress = true

    Given path 'item-storage/items', newItemId4
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request item
    When method PUT
    Then status 204

    # Wait for the record to be reindexed
    * pause(10000)

    # Verify the suppressed record is NOT in OAI-PMH response
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200
    # Verify that the suppressed record is NOT included in the response
    And match response //identifier !contains 'oai:folio.org:' + testTenant + '/' + newInstanceId4
