Feature: Skip suppressed from discovery records C193912

  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  @C193912  
  Scenario: Verify suppressed records are skipped when configured to skip suppressed records
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

    # Create a new instance and mark it as suppressed
    * def newInstanceId = uuid()
    * def newInstanceHrid = 'inst' + randomMillis()
    * call read('init_data/create-instance.feature') { instanceId: '#(newInstanceId)', instanceTypeId: '#(instanceTypeId)', instanceHrid :'#(newInstanceHrid)', instanceSource: 'MARC'}

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

    # Create SRS record for the new instance
    * def newRecordId = uuid()
    * def newMatchedId = uuid()
    * def newJobExecutionId = uuid()
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(newJobExecutionId)', instanceId: '#(newInstanceId)', recordId: '#(newRecordId)', matchedId: '#(newMatchedId)'}

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

    # Verify the suppressed record is NOT in OAI-PMH response
    * url edgeUrl
    * def yesterday = function(){ return java.time.LocalDate.now().minusDays(1).toString() }
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = yesterday()
    When method GET
    Then status 200
    # Verify that the suppressed record is NOT included in the response
    And match response //identifier !contains 'oai:folio.org:' + testTenant + '/' + newInstanceId
