@parallel=false
Feature: GetRecord: SRS & Inventory - Verify SRS LDR/05=d records are harvested as deleted

  # JIRA: MODOAIPMH-613, MODOAIPMH-614
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
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }

    # SRS record from seeded init data
    * def testSrsId = 'be1b25ae-4a9d-4077-93e6-7f8e59efd609'
    * def testInstanceId = '6eee8eb9-db1a-46e2-a8ad-780f19974efa'

  @Positive @C375977
  Scenario: Verify GetRecord returns deleted header for SRS record with LDR/05=d

    # Preconditions: Record source is SRS + Inventory, deleted records processing is Persistent
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorValue = response.configurationSettings[0].configValue
    * match behaviorValue.recordsSource == 'Source record storage and Inventory'
    * match behaviorValue.deletedRecordsSupport == 'persistent'

    # Get SRS MARC record and verify it is historical (MARC 005 date is not today)
    Given url baseUrl
    And path 'source-storage/records', testSrsId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def record = response
    * match record.recordType == 'MARC_BIB'
    * def originalLeader = record.parsedRecord.content.leader
    * assert originalLeader.substring(5, 6) != 'd'
    * def todayCompact = java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"))
    * def getFieldValue =
      """
      function(fields, tag) {
        for (var i = 0; i < fields.length; i++) {
          if (fields[i][tag]) return fields[i][tag];
        }
        return null;
      }
      """
    * def marc005 = getFieldValue(record.parsedRecord.content.fields, '005')
    * match marc005 == '#string'
    * assert marc005.substring(0, 8) != todayCompact

    # Update LDR/05 to 'd' (deleted) via SRS edit
    * def deletedLeader = originalLeader.substring(0, 5) + 'd' + originalLeader.substring(6)
    * set record.parsedRecord.content.leader = deletedLeader

    Given path 'source-storage/records', testSrsId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request record
    When method PUT
    Then status 200

    * call sleep 2000

    # Note: Inventory does not support instance-record deletion. Ensure inventory instance isn't deleted.
    Given url baseUrl
    And path 'instance-storage/instances', testInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * match response.deleted == false

    # GetRecord with metadataPrefix=marc21_withholdings returns deleted header
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    And match response //header[@status='deleted'] == '#present'

    # GetRecord with metadataPrefix=marc21 returns deleted header
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/' + testInstanceId
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    And match response //header[@status='deleted'] == '#present'

    # Cleanup: restore original leader value
    Given url baseUrl
    And path 'source-storage/records', testSrsId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def cleanupRecord = response
    * set cleanupRecord.parsedRecord.content.leader = originalLeader

    Given path 'source-storage/records', testSrsId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    And request cleanupRecord
    When method PUT
    Then status 200

    * call sleep 2000
