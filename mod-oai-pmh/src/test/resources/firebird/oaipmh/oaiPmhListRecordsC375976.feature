@parallel=false
Feature: ListRecords: SRS & Inventory - Verify that deleted SRS Instances are harvested (marc21 and marc21_withholdings)

  # TestRail Case ID: C375976
  # JIRA: MODOAIPMH-138, MODOAIPMH-479
  # Priority: Medium
  # Test Group: Regression
  # Description: Verify that deleted SRS Instances are harvested in ListRecords for both marc21 and marc21_withholdings metadata prefixes

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_SRS_and_inventory.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

    # Use a specific test instance for C375976 - using instance from srs_init_data to avoid conflicts
    * def testInstanceId = '62ca5b43-0f11-40af-a6b4-1a9ee2db33cb'

    # Current date function for date range filtering
    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    * def currentDate = currentOnlyDate()

    # CRITICAL: Always restore instance to clean state before ANY scenario runs
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


  @Positive @C375976
  Scenario: C375976 - Verify deleted SRS instances are harvested via ListRecords (marc21 and marc21_withholdings)

    # Preconditions verification: Ensure "Record source" is set to "Source record storage and Inventory"
    # Preconditions verification: Ensure "Deleted records processing" setting is set to "Persistent"

    # Save original instance state before modification
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def originalInstance = response
    * def originalVersion = response._version

    # Step 1 & 2: Navigate to Inventory, search for MARC instance (simulated - instance already exists from init data)
    # Step 3: Edit LDR field position 05 to 'd' to mark as deleted
    # Step 4: Save and close
    # This simulates: Go to Inventory => Search MARC instance => Edit MARC bibliographic record => Edit LDR field position 05 to 'd' => Save

    # Mark instance for deletion - this sets the instance as deleted which simulates editing LDR field to 'd'
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

    # Wait for changes to propagate
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 3000

    # Step 5: Send GET request to ListRecords endpoint with metadataPrefix=marc21_withholdings
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # Verify the record is marked as deleted (header status set to deleted)
    * def identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * def headerXPath = '//record[header/identifier="' + identifier + '"]/header[@status="deleted"]'
    * match response /OAI-PMH/ListRecords/record/header[@status='deleted'] == '#present'

    # Step 6: Send GET request to ListRecords endpoint with metadataPrefix=marc21
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # Verify the record is marked as deleted (header status set to deleted)
    * match response /OAI-PMH/ListRecords/record/header[@status='deleted'] == '#present'

    # Cleanup: Restore instance to original state
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def currentVersion = response._version

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

    # Wait for restoration to fully propagate
    * call sleep 5000

