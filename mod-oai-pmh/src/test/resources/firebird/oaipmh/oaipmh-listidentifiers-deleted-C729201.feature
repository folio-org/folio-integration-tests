@parallel=false
Feature: ListIdentifiers: SRS & Inventory - Verify that set for deletion FOLIO Instances are harvested

  # TestRail Case ID: C729201
  # JIRA: MODOAIPMH-614, MODOAIPMH-624
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

    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    * def currentDate = currentOnlyDate()

  @Positive @C729201
  Scenario: C729201 - Verify deleted FOLIO instances are harvested with Transfer suppressed records setting

    # Step 1: Create first FOLIO instance (not MARC) for testing
    * def testInstanceId = 'c7291990-0001-4f01-a0f0-0f0110f0110a'
    * def folioInstance =
      """
      {
        "id": "#(testInstanceId)",
        "source": "FOLIO",
        "title": "Test FOLIO Instance 1 for Deletion C729201 - Positive",
        "hrid": "instC729199P001",
        "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "contributors": [
          {
            "name": "Test Author 1",
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

    # Step 2: Create second FOLIO instance (not MARC) for testing
    * def testInstanceId2 = 'c7291990-0003-4f01-a0f0-0f0110f0110c'
    * def folioInstance2 =
      """
      {
        "id": "#(testInstanceId2)",
        "source": "FOLIO",
        "title": "Test FOLIO Instance 2 for Deletion C729201 - Positive",
        "hrid": "instC729199P002",
        "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "contributors": [
          {
            "name": "Test Author 2",
            "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a"
          }
        ]
      }
      """

    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioInstance2
    When method POST
    Then status 201

    # Step 3: Mark both instances for deletion (simulates UI Edit instance => Set for deletion)
    # Instance 1
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

    # Instance 2
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

    Given path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData2
    When method PUT
    Then status 204

    # Step 4: Allow time for changes to propagate
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * call sleep 2000

    # Step 5: Verify ListIdentifiers with metadataPrefix=marc21 returns deleted records
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21'
    And param from = currentDate
    And param until = currentDate
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * print response
    * def identifier1 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    * def identifier2 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId2
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

    # Step 6: Verify ListIdentifiers with metadataPrefix=marc21_withholdings returns deleted records
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

    # Step 7: Verify ListIdentifiers with metadataPrefix=oai_dc returns deleted records
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

    # Step 8: Cleanup - Physically delete both created FOLIO instances
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
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

  @Negative @C729201
  Scenario: C729201 - Verify deleted FOLIO instances are NOT harvested when suppressed records are skipped

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

    # Step 2: Create second FOLIO instance (not MARC) for testing
    * def testInstanceId2 = 'c7291990-0003-4f01-a0f0-0f0110f0110c'
    * def folioInstance2 =
      """
      {
        "id": "#(testInstanceId2)",
        "source": "FOLIO",
        "title": "Test FOLIO Instance 2 for Deletion C729201 - Positive",
        "hrid": "instC729199P002",
        "instanceTypeId": "6312d172-f0cf-40f6-b27d-9fa8feaf332f",
        "contributors": [
          {
            "name": "Test Author 2",
            "contributorNameTypeId": "2b94c631-fca9-4892-a730-03ee529ffe2a"
          }
        ]
      }
      """

    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request folioInstance2
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

    Given path 'instance-storage/instances', testInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData
    When method PUT
    Then status 204

    Given path 'instance-storage/instances', testInstanceId2
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request instanceData2
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
    Then status 204

    * call sleep 3000

    # Step 6: Verify ListIdentifiers with metadataPrefix=marc21 does NOT return deleted record
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21'
    And header Accept = 'text/xml'
    When method GET
    Then status 200

    * def identifier1 = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId

    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

    # Step 7: Verify ListIdentifiers with metadataPrefix=marc21_withholdings does NOT return deleted record
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'marc21_withholdings'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # Verify that the test instances do NOT appear in the response
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

    # Step 8: Verify ListIdentifiers with metadataPrefix=oai_dc does NOT return deleted record
    Given url pmhUrl
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = 'oai_dc'
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    # Verify that the test instances do NOT appear in the response
    * match response //identifier[text()=identifier1] == '#notpresent'
    * match response //identifier[text()=identifier2] == '#notpresent'

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
    Then status 204

    # Cleanup: Physically delete the created FOLIO instance to avoid affecting other tests
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
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
