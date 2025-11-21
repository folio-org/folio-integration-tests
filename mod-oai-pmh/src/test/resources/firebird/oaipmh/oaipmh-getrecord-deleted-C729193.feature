@parallel=false
Feature: GetRecord: SRS & Inventory - Verify that set for deletion MARC Instances are harvested

  # TestRail Case ID: C729193
  # JIRA: MODOAIPMH-613
  # Priority: Medium
  # Test Group: Regression

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

    # Test instance from srs_init_data
    * def testInstanceId = '1b74ab75-9f41-4837-8662-a1d99118008d'

    # CRITICAL: Always restore instance to clean state before ANY scenario runs
    # This handles cases where previous test runs failed mid-execution
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def bgCleanupInstance = response
    * def bgCleanupVersion = response._version
    * set bgCleanupInstance._version = bgCleanupVersion
    * set bgCleanupInstance.deleted = false
    * set bgCleanupInstance.discoverySuppress = false
    * set bgCleanupInstance.staffSuppress = false
    Given path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request bgCleanupInstance
    When method PUT
    Then status 204
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 3000

  @Positive @C729193
  Scenario: C729193 - Verify deleted MARC instances are harvested with Transfer suppressed records setting

    # Save original instance state before modification (already clean from Background)
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstance = response
    * def originalVersion = response._version

    # Step 1: Mark instance for deletion (simulates UI: Edit instance => Check "Set for deletion" => Save & close)
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def instanceData = response
    * def instanceVersion = response._version

    * set instanceData.deleted = true
    * set instanceData.discoverySuppress = true
    * set instanceData.staffSuppress = true
    * set instanceData._version = instanceVersion

    Given path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData
    When method PUT
    Then status 204

    # Allow time for changes to propagate
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Step 2: Verify GetRecord with metadataPrefix=marc21 returns deleted record
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    And match response //header[@status='deleted'] == '#present'

    # Step 3: Verify GetRecord with metadataPrefix=marc21_withholdings returns deleted record
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    And match response //header[@status='deleted'] == '#present'

    # Step 4: Verify GetRecord with metadataPrefix=oai_dc returns deleted record
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'oai_dc'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    And match response //header[@status='deleted'] == '#present'

    # Cleanup: Restore instance to original state (unmark deletion) to avoid affecting other tests
    # Get current instance state to get latest version
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion = response._version

    # Restore original state
    * set originalInstance._version = currentVersion
    * set originalInstance.deleted = false
    * set originalInstance.discoverySuppress = false
    * set originalInstance.staffSuppress = false

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstance
    When method PUT
    Then status 204

    # Wait longer for restoration to fully propagate through the system
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000

  @Negative @C729193
  Scenario: C729193 - Verify deleted MARC instances are NOT harvested with Skip suppressed from discovery setting

    # Save original instance state before modification (already clean from Background)
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstanceState = response
    * def originalInstanceVersion = response._version

    # Ensure instance is marked for deletion
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def instanceData = response
    * def instanceVersion = response._version

    * set instanceData.deleted = true
    * set instanceData.discoverySuppress = true
    * set instanceData.staffSuppress = true
    * set instanceData._version = instanceVersion

    Given path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData
    When method PUT
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Step 5: Change "Suppressed records processing" setting to "Skip suppressed from discovery records"
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * def behaviorValue = karate.fromString(behaviorConfig.configValue)
    * def originalSuppressedRecordsProcessing = behaviorValue.suppressedRecordsProcessing

    # Update configuration to skip suppressed from discovery records
    * set behaviorValue.suppressedRecordsProcessing = 'Skip suppressed from discovery records'
    * string updatedBehaviorValue = behaviorValue
    * set behaviorConfig.configValue = updatedBehaviorValue

    Given path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    * call sleep 2000

    # Step 6: Verify GetRecord with metadataPrefix=marc21 does NOT return deleted record
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 404
    And match response //error[@code='idDoesNotExist'] == '#present'

    # Step 7: Verify GetRecord with metadataPrefix=marc21_withholdings does NOT return deleted record
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 404
    And match response //error[@code='idDoesNotExist'] == '#present'

    # Step 8: Verify GetRecord with metadataPrefix=oai_dc does NOT return deleted record
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'oai_dc'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 404
    And match response //error[@code='idDoesNotExist'] == '#present'

    # Cleanup: Restore "Suppressed records processing" setting to original value
    * set behaviorValue.suppressedRecordsProcessing = originalSuppressedRecordsProcessing
    * string restoredBehaviorValue = behaviorValue
    * set behaviorConfig.configValue = restoredBehaviorValue

    Given url baseUrl
    And path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    # Cleanup: Restore instance to original state to avoid affecting other tests
    # Get current instance version
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion = response._version

    # Restore original state
    * set originalInstanceState._version = currentVersion
    * set originalInstanceState.deleted = false
    * set originalInstanceState.discoverySuppress = false
    * set originalInstanceState.staffSuppress = false

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request originalInstanceState
    When method PUT
    Then status 204

    # Wait longer for restoration to fully propagate through the system
    * call sleep 5000

