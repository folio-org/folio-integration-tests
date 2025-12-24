@parallel=false
Feature: ListRecords: Harvest suppressed from discovery instance records with discovery flag

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  Scenario: Verify suppressed records are included with discovery flag when configured to transfer suppressed records
    # Create unique instance type for this test
    * def instanceTypeId = '11113333-c4e5-4e4c-8e4d-1f4b45678c93'
    Given path 'instance-types'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    And request { id: '#(instanceTypeId)', name: 'Test Type C193960', code: 'ttc193960', source: 'local' }
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

    # Create a new instance with discoverySuppress set to true
    * def suppressedInstanceId = 'ffff6666-9f41-4837-8662-a1d99118005a'
    * def suppressedInstanceHrid = 'inst000000001006'
    * def suppressedJobExecutionId = 'ffff6666-1caf-4470-9ad1-d533f6360bc5'
    * def suppressedRecordId = 'ffff6666-1caf-4470-9ad1-d533f6360bc5'
    * def suppressedMatchedId = 'ffff6666-e1d4-11e8-9f32-f2801f1b9fd5'

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

    # Wait a moment to ensure records are indexed
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * eval sleep(2000)

    # Verify the suppressed record IS in the response with discovery flag
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response for suppressed record with discovery flag:', response
    
    # The response should contain the suppressed record
    * def records = get response //record
    * def suppressedFound = karate.filter(records, function(r){ return r.header.identifier.indexOf(suppressedInstanceId) > -1 })
    And match suppressedFound != []
    * print 'Test 1 Passed: Suppressed record is present in response'

    # Verify that the record contains the 999 field with subfield $t set to 1
    * def recordMetadata = suppressedFound[0].metadata
    * def xmlString = karate.xmlPath(recordMetadata, '/')
    * print 'Record XML:', xmlString
    
    # Get the 999 field
    * def field999 = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='999']")
    * print '999 field:', field999
    And match field999 != []
    * print 'Test 2 Passed: 999 field is present'
    
    # Get subfield $t from 999 field
    * def subfield_t = karate.xmlPath(recordMetadata, "//*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t']")
    * print 'Subfield $t value:', subfield_t
    And match subfield_t != []
    
    # Verify that subfield $t is set to 1 (indicating suppressed from discovery)
    * def subfieldValue = subfield_t[0]
    * print 'Subfield $t content:', subfieldValue
    And match subfieldValue == '1'
    * print 'Test 3 Passed: Subfield $t in 999 field is set to 1 (discovery suppressed flag)'

    # Create a non-suppressed instance for comparison
    * def nonSuppressedInstanceId = 'ffff6666-9f41-4837-8662-a1d99118006a'
    * def nonSuppressedInstanceHrid = 'inst000000001007'
    * def nonSuppressedJobExecutionId = 'ffff6666-1caf-4470-9ad1-d533f6360bc6'
    * def nonSuppressedRecordId = 'ffff6666-1caf-4470-9ad1-d533f6360bc6'
    * def nonSuppressedMatchedId = 'ffff6666-e1d4-11e8-9f32-f2801f1b9fd6'

    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def instance2 = read('classpath:samples/instance.json')
    * set instance2.id = nonSuppressedInstanceId
    * set instance2.instanceTypeId = instanceTypeId
    * set instance2.hrid = nonSuppressedInstanceHrid
    * set instance2.source = 'MARC'
    * set instance2.discoverySuppress = false
    And request instance2
    When method POST
    Then status 201

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Create SRS record for the non-suppressed instance
    * call read('init_data/create-srs-record.feature') { jobExecutionId: '#(nonSuppressedJobExecutionId)', instanceId: '#(nonSuppressedInstanceId)', recordId: '#(nonSuppressedRecordId)', matchedId: '#(nonSuppressedMatchedId)'}

    # Wait a moment to ensure records are indexed
    * eval sleep(2000)

    # Verify the non-suppressed record is also in the response
    * url edgeUrl
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21'
    And param verb = 'ListRecords'
    And param from = currentDate
    When method GET
    Then status 200
    * print 'Response with both suppressed and non-suppressed records:', response
    
    # The response should contain the non-suppressed record
    * def records2 = get response //record
    * def nonSuppressedFound = karate.filter(records2, function(r){ return r.header.identifier.indexOf(nonSuppressedInstanceId) > -1 })
    And match nonSuppressedFound != []
    * print 'Test 4 Passed: Non-suppressed record is present in response'

    # Verify that the non-suppressed record does not have subfield $t set to 1 (or $t doesn't exist)
    * def nonSuppressedMetadata = nonSuppressedFound[0].metadata
    * def nonSuppressedXmlString = karate.xmlPath(nonSuppressedMetadata, '/')
    * print 'Non-suppressed record XML:', nonSuppressedXmlString
    
    # Get subfield $t from 999 field for non-suppressed record
    * def nonSuppressedSubfield_t = karate.xmlPath(nonSuppressedMetadata, "//*[local-name()='datafield'][@tag='999']/*[local-name()='subfield'][@code='t']")
    * print 'Non-suppressed subfield $t value:', nonSuppressedSubfield_t
    
    # Verify that subfield $t is either not present or not set to 1
    * def isNotSuppressed = nonSuppressedSubfield_t.length == 0 || nonSuppressedSubfield_t[0] != '1'
    And match isNotSuppressed == true
    * print 'Test 5 Passed: Non-suppressed record does not have subfield $t set to 1'

    # Cleanup: Delete created records
    * url baseUrl
    Given path 'instance-storage/instances', suppressedInstanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    Given path 'instance-storage/instances', nonSuppressedInstanceId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    # Delete instance type
    Given path 'instance-types', instanceTypeId
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method DELETE
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000
