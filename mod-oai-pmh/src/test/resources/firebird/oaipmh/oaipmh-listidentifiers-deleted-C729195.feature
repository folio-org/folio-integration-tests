@parallel=false
Feature: ListIdentifiers: SRS - Verify that set for deletion MARC Instances are harvested with date range

  # Based on C729195 but modified for ListIdentifiers with date range and multiple records
  # JIRA: MODOAIPMH-613
  # Priority: Medium
  # Test Group: Regression

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }


    # Test instances from srs_init_data - using different instances for testing
    * def testInstanceId1 = '1b74ab75-9f41-4837-8662-a1d99118008d'
    * def testInstanceId2 = '6b4ae089-e1ee-431f-af83-e1133f8e3da0'
    * def testInstanceId3 = 'ce00bca2-9270-4c6b-b096-b83a2e56e8e9'

    # Current date function for date range filtering
    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    * def currentDate = currentOnlyDate()

    # CRITICAL: Always restore instance to clean state before ANY scenario runs
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def bgCleanupInstance1 = response
    * def bgCleanupVersion1 = response._version
    * set bgCleanupInstance1._version = bgCleanupVersion1
    * set bgCleanupInstance1.deleted = false
    * set bgCleanupInstance1.discoverySuppress = false
    * set bgCleanupInstance1.staffSuppress = false
    Given path 'instance-storage/instances', testInstanceId1
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request bgCleanupInstance1
    When method PUT
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def bgCleanupInstance2 = response
    * def bgCleanupVersion2 = response._version
    * set bgCleanupInstance2._version = bgCleanupVersion2
    * set bgCleanupInstance2.deleted = false
    * set bgCleanupInstance2.discoverySuppress = false
    * set bgCleanupInstance2.staffSuppress = false
    Given path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request bgCleanupInstance2
    When method PUT
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def bgCleanupInstance3 = response
    * def bgCleanupVersion3 = response._version
    * set bgCleanupInstance3._version = bgCleanupVersion3
    * set bgCleanupInstance3.deleted = false
    * set bgCleanupInstance3.discoverySuppress = false
    * set bgCleanupInstance3.staffSuppress = false
    Given path 'instance-storage/instances', testInstanceId3
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request bgCleanupInstance3
    When method PUT
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 3000


  @Positive @C729195
  Scenario: Verify deleted MARC instances are harvested via ListIdentifiers with date range

    # Save original instance states before modification
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstance1 = response
    * def originalVersion1 = response._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstance2 = response
    * def originalVersion2 = response._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstance3 = response
    * def originalVersion3 = response._version


    # Step 1: Mark both instances for deletion
    Given url baseUrl
    Given path 'inventory/instances', testInstanceId1, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    Given path 'inventory/instances', testInstanceId2, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    Given path 'inventory/instances', testInstanceId3, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Allow time for changes to propagate
    * call sleep 3000

    # Step 2: Verify ListIdentifiers with metadataPrefix=marc21 returns deleted records within date range
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    * def identifier1 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId1
    * def identifier2 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId2
    Then status 200
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'
    * match response //identifier[text()=identifier3] == '#notpresent'

    # Step 3: Verify ListIdentifiers with metadataPrefix=marc21_withholdings returns deleted records
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'
    * match response //identifier[text()=identifier3] == '#notpresent'


    # Step 4: Verify ListIdentifiers with metadataPrefix=oai_dc returns deleted records
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'oai_dc'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'
    * match response //identifier[text()=identifier3] == '#notpresent'

    # Cleanup: Restore both instances to original state
    # Get latest versions before restore
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion1 = response._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion2 = response._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion3 = response._version


    * set originalInstance1._version = currentVersion1
    * set originalInstance1.deleted = false
    * set originalInstance1.discoverySuppress = false
    * set originalInstance1.staffSuppress = false

    * set originalInstance2._version = currentVersion2
    * set originalInstance2.deleted = false
    * set originalInstance2.discoverySuppress = false
    * set originalInstance2.staffSuppress = false

    * set originalInstance3._version = currentVersion3
    * set originalInstance3.deleted = false
    * set originalInstance3.discoverySuppress = false
    * set originalInstance3.staffSuppress = false

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstance1
    When method PUT
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstance2
    When method PUT
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstance3
    When method PUT
    Then status 204


    * call sleep 5000

  @Negative @C729195
  Scenario: Verify deleted MARC instances are NOT harvested when suppressed records processing is set to skip

    # Save original instance states before modification
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstanceState1 = response
    * def originalInstanceVersion1 = response._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstanceState2 = response
    * def originalInstanceVersion2 = response._version

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstanceState3 = response
    * def originalInstanceVersion3 = response._version


    # Mark all instances for deletion and set as suppressed
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def instanceData1 = response
    * def instanceVersion1 = response._version
    * set instanceData1.deleted = true
    * set instanceData1.discoverySuppress = true
    * set instanceData1.staffSuppress = true
    * set instanceData1._version = instanceVersion1

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def instanceData2 = response
    * def instanceVersion2 = response._version
    * set instanceData2.deleted = true
    * set instanceData2.discoverySuppress = true
    * set instanceData2.staffSuppress = true
    * set instanceData2._version = instanceVersion2

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def instanceData3 = response
    * def instanceVersion3 = response._version
    * set instanceData3.deleted = true
    * set instanceData3.discoverySuppress = true
    * set instanceData3.staffSuppress = true
    * set instanceData3._version = instanceVersion3


    Given path 'instance-storage/instances', testInstanceId1
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData1
    When method PUT
    Then status 204

    Given path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData2
    When method PUT
    Then status 204

    Given path 'instance-storage/instances', testInstanceId3
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData3
    When method PUT
    Then status 204


    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 3000

    # Step 5: Change "Suppressed records processing" setting to "Skip suppressed from discovery records"
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'configName==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configs[0]
    * def behaviorValue = karate.fromString(behaviorConfig.value)
    * def originalSuppressedRecordsProcessing = behaviorValue.suppressedRecordsProcessing

    # Update configuration to skip suppressed records
    * set behaviorValue.suppressedRecordsProcessing = 'Skip suppressed from discovery records'
    * string updatedBehaviorValue = behaviorValue
    * set behaviorConfig.value = updatedBehaviorValue

    Given path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    * call sleep 3000

    # Step 3: Verify ListIdentifiers with metadataPrefix=marc21 does NOT return suppressed deleted records
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200

    # Verify that the test instances do NOT appear in the response
    * def identifier1 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId1

    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'
    * match response //identifier[text()=identifier3] == '#notpresent'


    # Step 4: Verify ListIdentifiers with metadataPrefix=marc21_withholdings does NOT return suppressed deleted records
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200

    # Verify that the test instances do NOT appear in the response
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'
    * match response //identifier[text()=identifier3] == '#notpresent'


    # Step 5: Verify ListIdentifiers with metadataPrefix=oai_dc does NOT return suppressed deleted records
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'oai_dc'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200

    # Verify that the 3 test instances do NOT appear in the response
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'
    * match response //identifier[text()=identifier3] == '#notpresent'

    # Cleanup: Restore "Suppressed records processing" setting to original value
    * set behaviorValue.suppressedRecordsProcessing = originalSuppressedRecordsProcessing
    * string restoredBehaviorValue = behaviorValue
    * set behaviorConfig.value = restoredBehaviorValue

    Given url baseUrl
    And path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    # Cleanup: Restore all instances to original state
    # Get current versions

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion = response._version

    # Restore original state
    * set originalInstanceState1._version = currentVersion
    * set originalInstanceState1.deleted = false
    * set originalInstanceState1.discoverySuppress = false
    * set originalInstanceState1.staffSuppress = false

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstanceState1
    When method PUT
    Then status 204

    * call sleep 5000

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion = response._version


    # Restore original state
    * set originalInstanceState2._version = currentVersion
    * set originalInstanceState2.deleted = false
    * set originalInstanceState2.discoverySuppress = false
    * set originalInstanceState2.staffSuppress = false


    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstanceState2
    When method PUT
    Then status 204

    * call sleep 5000
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion = response._version


    # Restore original state
    * set originalInstanceState3._version = currentVersion
    * set originalInstanceState3.deleted = false
    * set originalInstanceState3.discoverySuppress = false
    * set originalInstanceState3.staffSuppress = false


    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId3
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstanceState3
    When method PUT
    Then status 204

    # Wait longer for restoration to fully propagate through the system
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000
