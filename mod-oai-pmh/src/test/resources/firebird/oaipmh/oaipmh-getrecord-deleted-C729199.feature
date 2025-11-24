@parallel=false
Feature: GetRecord: SRS & Inventory - Verify that set for deletion FOLIO Instances are harvested

  # TestRail Case ID: C729199
  # JIRA: MODOAIPMH-614
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

  @Positive @C729199
  Scenario: C729199 - Verify deleted FOLIO instances are harvested with Transfer suppressed records setting

    # Create a FOLIO instance (not MARC) for testing
    * def testInstanceId = 'c7291990-0001-4f01-a0f0-0f0110f0110a'
    * def folioInstance =
    """
    {
      "id": "#(testInstanceId)",
      "source": "FOLIO",
      "title": "Test FOLIO Instance for Deletion C729199 - Positive",
      "hrid": "instC729199P001",
      "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "contributors": [
        {
          "name": "Test Author",
          "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a"
        }
      ]
    }
    """

    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioInstance
    When method POST
    Then status 201

    # Step 1: Mark instance for deletion via Edit instance (simulates UI: Edit instance => Check "Set for deletion" => Save & close)
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
    * call sleep 3000

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

    # Cleanup: Physically delete the created FOLIO instance to avoid affecting other tests
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000

  @Negative @C729199
  Scenario: C729199 - Verify deleted FOLIO instances are NOT harvested when suppressed records are skipped

    # Create a FOLIO instance (not MARC) for testing
    * def testInstanceId = 'c7291990-0002-4f01-a0f0-0f0110f0110b'
    * def folioInstance =
    """
    {
      "id": "#(testInstanceId)",
      "source": "FOLIO",
      "title": "Test FOLIO Instance for Deletion C729199 - Negative",
      "hrid": "instC729199N001",
      "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "contributors": [
        {
          "name": "Test Author",
          "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a"
        }
      ]
    }
    """

    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioInstance
    When method POST
    Then status 201

    # Mark instance for deletion via Edit instance
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
    * call sleep 3000

    # Step 5: Change "Suppressed records processing" setting to "Skip suppressed from discovery records"
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * def behaviorValue = behaviorConfig.configValue
    * def originalSuppressedRecordsProcessing = behaviorValue.suppressedRecordsProcessing

    # Update configuration to skip suppressed from discovery records
    * set behaviorValue.suppressedRecordsProcessing = 'Skip suppressed from discovery records'
    * def updatedBehaviorValue = behaviorValue
    * set behaviorConfig.configValue = updatedBehaviorValue

    Given path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 200

    * call sleep 3000

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
    * def restoredBehaviorValue = behaviorValue
    * set behaviorConfig.configValue = restoredBehaviorValue

    Given url baseUrl
    And path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 200

    # Cleanup: Physically delete the created FOLIO instance to avoid affecting other tests
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 5000
