@C193960
Feature: instance suppressed with discovery flag C193960

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed records are included with discovery flag when configured to transfer suppressed records
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

    # Wait for the record to be reindexed
    * pause(10000)

    # Verify the suppressed record is in OAI-PMH response
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200

    # Verify that the suppressed record is included in the response
    And match response //identifier contains 'oai:folio.org:' + testTenant + '/' + newInstanceId
    
    # Verify 999 field contains subfield $t that is set to 1 (suppression flag)
    * def tValue = karate.xmlPath(response, "//record[header/identifier[contains(.,'" + newInstanceId + "')]]//datafield[@tag='999']/subfield[@code='t']/text()")
    * print 'Suppression flag (999$t):', tValue
    And match tValue contains '1'

