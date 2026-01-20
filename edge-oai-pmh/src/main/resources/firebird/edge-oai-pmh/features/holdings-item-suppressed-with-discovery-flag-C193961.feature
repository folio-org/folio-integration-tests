@C193961
Feature: holdings and item suppressed with discovery flag C193961

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed holdings and items are included with discovery flag when configured to transfer suppressed records
    # Set technical config to avoid pagination
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==technical'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def technicalId = get[0] response.configurationSettings[?(@.configName=='technical')].id
    * def technicalPayload = read('classpath:samples/technical.json')
    * set technicalPayload.configValue.maxRecordsPerResponse = '50'

    Given path 'oai-pmh/configuration-settings', technicalId
    And request technicalPayload
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

    # Configure OAI-PMH to transfer suppressed records with discovery flag
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
    * set behaviorPayload.configValue.suppressedRecordsProcessing = 'true'
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

    # Create item for the new holding
    * def newItemId = uuid()
    * def newItemHrid = 'item' + randomMillis()
    * def newBarcode = random_string()
    * call read('init_data/create-item.feature') { holdingId: '#(newHoldingId)', itemId: '#(newItemId)', itemHrid: '#(newItemHrid)', barcode: '#(newBarcode)'}

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

    # Mark the item record as suppressed from discovery
    Given path 'item-storage/items', newItemId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200
    * def item = response
    * set item.discoverySuppress = true

    Given path 'item-storage/items', newItemId
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    And request item
    When method PUT
    Then status 204

    # Wait for the record to be reindexed
    * pause(10000)

    # Verify the suppressed record is in OAI-PMH response
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200

    # Verify that the suppressed record is included in the response
    And match response //identifier contains 'oai:folio.org:' + testTenant + '/' + newInstanceId

    # Verify 856, 952 fields contain subfield $t that is set to 1 (suppression flag)
    * def tValue856 = karate.xmlPath(response, "//record[header/identifier[contains(.,'" + newInstanceId + "')]]//datafield[@tag='856']/subfield[@code='t']/text()")
    * print 'Suppression flag (856$t):', tValue856
    And match tValue856 contains '1'

    * def tValue952 = karate.xmlPath(response, "//record[header/identifier[contains(.,'" + newInstanceId + "')]]//datafield[@tag='952']/subfield[@code='t']/text()")
    * print 'Suppression flag (952$t):', tValue952
    And match tValue952 contains '1'
