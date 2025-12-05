@parallel=false
Feature: GetRecord: Inventory - Verify that set for deletion FOLIO Instances are harvested

  # TestRail Case ID: C729198
  # JIRA: MODOAIPMH-614
  # Priority: Medium
  # Test Group: Regression

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_Inventory_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }


  @Positive @C729198
  Scenario: C729198 - Verify deleted FOLIO instances are harvested with Persistent deleted records support

    # Create a FOLIO instance (not MARC) for testing
    * def testInstanceId = 'f0ebe1e1-5e1e-4c1e-8c1e-5e1e4c1e8c1e'
    * def folioInstance =
    """
    {
      "id": "#(testInstanceId)",
      "source": "FOLIO",
      "title": "Test FOLIO Instance for Deletion - Positive",
      "hrid": "instC729198P001",
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

    # Step 1: Mark instance for deletion (simulates UI action: Actions => Set record for deletion => Confirm)
    Given url baseUrl
    Given path 'inventory/instances', testInstanceId, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
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

    # Cleanup: Physically delete the created FOLIO instance to avoid affecting other tests
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204


  @Negative @C729198
  Scenario: C729198 - Verify deleted FOLIO instances are NOT harvested when deleted records support is No

    # Create a FOLIO instance (not MARC) for testing
    * def testInstanceId = 'a1b2c3d4-5e6f-4a8b-9c0d-1e2f3a4b5c6d'
    * def folioInstance =
    """
    {
      "id": "#(testInstanceId)",
      "source": "FOLIO",
      "title": "Test FOLIO Instance for Deletion - Negative",
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

    # Ensure instance is marked for deletion
    Given url baseUrl
    Given path 'inventory/instances', testInstanceId, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Step 5: Change "Deleted records support" setting to "No"
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * def behaviorValue = behaviorConfig.configValue
    * def originalDeletedRecordsSupport = behaviorValue.deletedRecordsSupport

    # Update configuration to disable deleted records support
    * set behaviorValue.deletedRecordsSupport = 'No'
    * set behaviorValue.enabledDeletedRecordsSupport = false
    * def updatedBehaviorValue = behaviorValue
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

    # Cleanup: Restore "Deleted records support" setting to original value
    * set behaviorValue.deletedRecordsSupport = originalDeletedRecordsSupport
    * set behaviorValue.enabledDeletedRecordsSupport = true
    * def restoredBehaviorValue = behaviorValue
    * set behaviorConfig.configValue = restoredBehaviorValue

    Given url baseUrl
    And path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    # Cleanup: Physically delete the created FOLIO instance to avoid affecting other tests
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

