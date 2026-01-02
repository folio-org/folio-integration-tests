@parallel=false
Feature: ListRecords: Inventory - Verify that set for deletion FOLIO Instances are harvested

  # TestRail Case ID: C729200
  # JIRA: MODOAIPMH-614, MODOAIPMH-624, MODOAIPMH-638
  # Priority: High
  # Test Group: Regression
  # Description: Verify that FOLIO instances marked for deletion are harvested via ListRecords with persistent and no deleted records support

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_set_source_Inventory_only.feature')
    #=========================SETUP=================================================
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

    # Current date function for date range filtering
    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    * def currentDate = currentOnlyDate()

    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }


  @Positive @C729200
  Scenario: C729200 - Verify set for deletion FOLIO instances are harvested with Persistent deleted records support

    # Preconditions verification: Ensure "Record source" is set to "Inventory"
    # Preconditions verification: Ensure "Suppressed records processing" is set to "Transfer suppressed records with discovery flag value"
    # Preconditions verification: Ensure "Deleted records support" is set to "Persistent"

    # Verify OAI-PMH configuration before proceeding
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * def behaviorValue = behaviorConfig.configValue
    * print 'Current OAI-PMH Behavior Config:', behaviorValue
    * print 'Deleted records support:', behaviorValue.deletedRecordsSupport
    * print 'Record source:', behaviorValue.enabledRecordsSource
    * assert behaviorValue.deletedRecordsSupport == 'persistent'

    # Create two FOLIO instances for testing (not MARC)
    * def testInstanceId1 = '312aeb36-defb-4327-a710-604852612a8b'
    * def testInstanceId2 = 'b275fed1-4a65-4ce8-98e5-f5e256d9b72c'

    * def folioInstance1 =
    """
    {
      "id": "#(testInstanceId1)",
      "source": "FOLIO",
      "title": "Test FOLIO Instance 1 for C729200 Deletion",
      "hrid": "instC729200P001",
      "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "contributors": [
        {
          "name": "Test Author C729200-1",
          "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a"
        }
      ]
    }
    """

    * def folioInstance2 =
    """
    {
      "id": "#(testInstanceId2)",
      "source": "FOLIO",
      "title": "Test FOLIO Instance 2 for C729200 Deletion",
      "hrid": "instC729200P002",
      "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
      "contributors": [
        {
          "name": "Test Author C729200-2",
          "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a"
        }
      ]
    }
    """

    # Create 1st FOLIO instance
    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioInstance1
    When method POST
    Then status 201

    # Create 2nd FOLIO instance
    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioInstance2
    When method POST
    Then status 201

    * call sleep 2000

    # Step 1: Mark 1st instance for deletion via "Actions => Set record for deletion => Confirm"
    Given url baseUrl
    And path 'inventory/instances', testInstanceId1, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Step 2: Mark 2nd instance for deletion via "Edit instance => Check 'Set for deletion' => Save & close"
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def instance2Data = response
    * def instance2Version = response._version

    * set instance2Data.deleted = true
    * set instance2Data.discoverySuppress = true
    * set instance2Data.staffSuppress = true
    * set instance2Data._version = instance2Version

    Given path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instance2Data
    When method PUT
    Then status 204

    # Wait longer for OAI-PMH to index the deleted instances
    * call sleep 10000

    # Verify instances are actually marked as deleted
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * print 'Instance 1 deleted flag:', response.deleted
    * assert response.deleted == true

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * print 'Instance 2 deleted flag:', response.deleted
    * assert response.deleted == true

    # Step 3: Verify ListRecords with metadataPrefix=marc21 returns both deleted records
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200

    * def identifier1 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId1
    * def identifier2 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId2

    # Extract all identifiers for debugging
    * def responseText = karate.toString(response)
    * print 'Response contains testInstanceId1:', responseText.contains(testInstanceId1)
    * print 'Response contains testInstanceId2:', responseText.contains(testInstanceId2)

    * def identifierList = karate.xmlPath(response, '//record/header/identifier/text()')
    * print 'All identifiers in response:', identifierList

    # Check that our test instances are in the list
    * def checkDeletedInstances =
    """
    function(identifiers, id1, id2) {
      var found1 = false;
      var found2 = false;
      for (var i = 0; i < identifiers.length; i++) {
        if (identifiers[i].indexOf(id1) > -1) {
          found1 = true;
        }
        if (identifiers[i].indexOf(id2) > -1) {
          found2 = true;
        }
      }
      return { found1: found1, found2: found2 };
    }
    """
    * def foundResult = checkDeletedInstances(identifierList, testInstanceId1, testInstanceId2)
    * print 'Instance 1 found:', foundResult.found1
    * print 'Instance 2 found:', foundResult.found2

    # Assert that both deleted instances appear in the response
    * assert foundResult.found1 == true
    * assert foundResult.found2 == true

    # Verify both instances appear with deleted status
    * match response /OAI-PMH/ListRecords/record/header[@status='deleted'] == '#present'

    # Step 4: Verify ListRecords with metadataPrefix=marc21_withholdings returns both deleted records
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response /OAI-PMH/ListRecords/record/header[@status='deleted'] == '#present'

    # Step 5: Verify ListRecords with metadataPrefix=oai_dc returns both deleted records
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'oai_dc'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response /OAI-PMH/ListRecords/record/header[@status='deleted'] == '#present'

    # Step 6: Change "Deleted records support" setting to "No"
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

    * set behaviorValue.deletedRecordsSupport = 'No'
    * set behaviorConfig.configValue = behaviorValue

    Given path '/oai-pmh/configuration-settings', behaviorConfig.id
    And header x-okapi-token = okapitoken
    And request behaviorConfig
    When method PUT
    Then status 204

    * call sleep 2000

    # Step 7: Verify ListRecords with metadataPrefix=marc21 does NOT return deleted records
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # Deleted records should not be present
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

    # Step 8: Verify ListRecords with metadataPrefix=marc21_withholdings does NOT return deleted records
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

    # Step 9: Verify ListRecords with metadataPrefix=oai_dc does NOT return deleted records
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'oai_dc'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

    # Cleanup: Restore "Deleted records support" setting to original value
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def restoreBehaviorConfig = response.configurationSettings[0]
    * def restoreBehaviorValue = restoreBehaviorConfig.configValue
    * set restoreBehaviorValue.deletedRecordsSupport = originalDeletedRecordsSupport
    * set restoreBehaviorConfig.configValue = restoreBehaviorValue

    Given path '/oai-pmh/configuration-settings', restoreBehaviorConfig.id
    And header x-okapi-token = okapitoken
    And request restoreBehaviorConfig
    When method PUT
    Then status 204

    # Cleanup: Physically delete both created FOLIO instances to avoid affecting other tests
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId1
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId2
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    # Wait for deletion to fully propagate
    * call sleep 5000

