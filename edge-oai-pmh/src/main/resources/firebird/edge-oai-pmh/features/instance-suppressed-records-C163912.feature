@parallel=false
Feature: ListRecords: Harvest suppressed from discovery instance records - skip suppressed C163912
  Background:
    * url baseUrl
    * callonce variables
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed records are not included when configured to skip suppressed from discovery
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

    # Create a new instance with discoverySuppress set to true
    * def suppressedInstanceId = 'aaaa1111-9f41-4837-8662-a1d99118008d'
    * def suppressedInstanceHrid = 'inst000000000999'
    * def suppressedJobExecutionId = 'aaaa1111-1caf-4470-9ad1-d533f6360bc8'
    * def suppressedRecordId = 'aaaa1111-1caf-4470-9ad1-d533f6360bc8'
    * def suppressedMatchedId = 'aaaa1111-e1d4-11e8-9f32-f2801f1b9fd1'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = suppressedInstanceId
    * set instance.instanceTypeId = instanceTypeId
    * set instance.hrid = suppressedInstanceHrid
    * set instance.source = 'MARC'
    * set instance.discoverySuppress = true
    And request instance
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Create SRS record for the suppressed instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(suppressedJobExecutionId)', instanceId: '#(suppressedInstanceId)', recordId: '#(suppressedRecordId)', matchedId: '#(suppressedMatchedId)'}

    # Get today's date in yyyy-MM-dd format
    * def currentDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())

    # Verify the suppressed record is NOT in the response
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print response
    # The response should not contain the suppressed record
    * def records = get response //record
    * def suppressedFound = karate.filter(records, function(r){ return r.header.identifier.indexOf(suppressedInstanceId) > -1 })
    And match suppressedFound == []

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000
