@parallel=false
Feature: ListRecords: SRS & Inventory - Verify edited deleted MARC and FOLIO instances are returned with deleted status and updated datestamps

  # TestRail Case ID: TBD
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
    * configure retry = { count: 20, interval: 2000 }
    * def sleep = function(ms){ java.lang.Thread.sleep(ms) }
    * def currentOnlyDate = function(){ return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern('yyyy-MM-dd')) }
    * def currentDate = currentOnlyDate()

  @Positive @C926147
  Scenario: Verify edited deleted MARC and FOLIO instances are returned in ListRecords marc21_withholdings with status deleted
    * def marcInstanceId = java.util.UUID.randomUUID() + ''
    * def folioInstanceId = java.util.UUID.randomUUID() + ''
    * def srsRecordId = java.util.UUID.randomUUID() + ''
    * def snapshotId = java.util.UUID.randomUUID() + ''
    * def hridSeed = java.lang.System.currentTimeMillis() + ''
    * def marcHrid = 'instC375984M' + hridSeed
    * def folioHrid = 'instC375984F' + hridSeed
    * def marcIdentifier = 'oai:folio.org:' + testUser.tenant + '/' + marcInstanceId
    * def folioIdentifier = 'oai:folio.org:' + testUser.tenant + '/' + folioInstanceId

    # Verify OAI-PMH behavior config matches preconditions.
    Given url baseUrl
    And path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def behaviorConfig = response.configurationSettings[0]
    * def behaviorValue = behaviorConfig.configValue
    * match behaviorValue.recordsSource == 'Source record storage and Inventory'
    * match behaviorValue.suppressedRecordsProcessing == 'true'
    * match behaviorValue.deletedRecordsSupport == 'persistent'

    # Create MARC instance.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    * def marcInstance = read('classpath:samples/instance.json')
    * set marcInstance.id = marcInstanceId
    * set marcInstance.source = 'MARC'
    * set marcInstance.hrid = marcHrid
    * set marcInstance.title = 'C375984 MARC before delete/edit'
    And request marcInstance
    When method POST
    Then status 201

    # Create snapshot + SRS MARC record linked to MARC instance.
    Given url baseUrl
    And path 'source-storage/snapshots'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "jobExecutionId": "#(snapshotId)",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    Given url baseUrl
    And path 'source-storage/records'
    * def srsRecord = read('classpath:samples/marc_record.json')
    * set srsRecord.id = srsRecordId
    * set srsRecord.snapshotId = snapshotId
    * set srsRecord.externalIdsHolder.instanceId = marcInstanceId
    * set srsRecord.externalIdsHolder.instanceHrid = marcHrid
    * set srsRecord.matchedId = srsRecordId
    And request srsRecord
    And header Accept = 'application/json'
    When method POST
    Then status 201

    # Create FOLIO instance.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    * def folioInstance = read('classpath:samples/instance.json')
    * set folioInstance.id = folioInstanceId
    * set folioInstance.source = 'FOLIO'
    * set folioInstance.hrid = folioHrid
    * set folioInstance.title = 'C375984 FOLIO before delete/edit'
    And request folioInstance
    When method POST
    Then status 201

    # Mark MARC instance as deleted (equivalent to "Set record for deletion" action).
    Given url baseUrl
    And path 'inventory/instances', marcInstanceId, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Mark FOLIO instance as deleted (equivalent to "Set record for deletion" action).
    Given url baseUrl
    And path 'inventory/instances', folioInstanceId, 'mark-deleted'
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Avoid second-level datestamp collisions between "before edit" and "after edit" snapshots.
    * call sleep 3000

    # Capture deleted-record datestamps before edit.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = marcIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)") == 'deleted'
    When method GET
    Then status 200
    * def marcDatestampBeforeEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/*[local-name()='datestamp'])")
    * def marcStatusBeforeEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)")
    * match marcStatusBeforeEdit == 'deleted'

    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = folioIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)") == 'deleted'
    When method GET
    Then status 200
    * def folioDatestampBeforeEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/*[local-name()='datestamp'])")
    * def folioStatusBeforeEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)")
    * match folioStatusBeforeEdit == 'deleted'

    * call sleep 1500

    # Edit deleted MARC instance (equivalent to UI Edit instance + Save & close).
    Given url baseUrl
    And path 'instance-storage/instances', marcInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def marcAfterEdit = response
    * set marcAfterEdit.title = 'C375984 MARC edited after deletion'
    * set marcAfterEdit.deleted = true
    * set marcAfterEdit.discoverySuppress = true
    * set marcAfterEdit.staffSuppress = true
    * set marcAfterEdit._version = response._version

    Given path 'instance-storage/instances', marcInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request marcAfterEdit
    When method PUT
    Then status 204

    # Edit deleted FOLIO instance (equivalent to UI Edit instance + Save & close).
    Given url baseUrl
    And path 'instance-storage/instances', folioInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'application/json'
    When method GET
    Then status 200
    * def folioAfterEdit = response
    * set folioAfterEdit.title = 'C375984 FOLIO edited after deletion'
    * set folioAfterEdit.deleted = true
    * set folioAfterEdit.discoverySuppress = true
    * set folioAfterEdit.staffSuppress = true
    * set folioAfterEdit._version = response._version

    Given path 'instance-storage/instances', folioInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    And request folioAfterEdit
    When method PUT
    Then status 204

    * call sleep 3000

    # Capture datestamps after edit and verify they changed.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = marcIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)") == 'deleted'
    When method GET
    Then status 200
    * def marcDatestampAfterEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/*[local-name()='datestamp'])")
    * def marcStatusAfterEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)")
    * match marcStatusAfterEdit == 'deleted'
    * match marcDatestampAfterEdit == '#string'

    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = folioIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)") == 'deleted'
    When method GET
    Then status 200
    * def folioDatestampAfterEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/*[local-name()='datestamp'])")
    * def folioStatusAfterEdit = karate.xmlPath(response, "string(//*[local-name()='GetRecord']/*[local-name()='record']/*[local-name()='header']/@status)")
    * match folioStatusAfterEdit == 'deleted'
    * match folioDatestampAfterEdit == '#string'

    # Use a tight UTC datetime window around actual edited datestamps to avoid pagination noise.
    * def fromDateTime = marcDatestampAfterEdit < folioDatestampAfterEdit ? marcDatestampAfterEdit : folioDatestampAfterEdit
    * def untilDateTime = marcDatestampAfterEdit > folioDatestampAfterEdit ? marcDatestampAfterEdit : folioDatestampAfterEdit

    # ListRecords and verify both deleted records are returned with expected datestamps.
    Given url pmhUrl
    And param verb = 'ListRecords'
    And param metadataPrefix = 'marc21_withholdings'
    And param from = fromDateTime
    And param until = untilDateTime
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.toString(response).indexOf(marcInstanceId) > -1 && karate.toString(response).indexOf(folioInstanceId) > -1
    When method GET
    Then status 200

    * def marcListStatus = karate.xmlPath(response, "string(//*[local-name()='record'][*[local-name()='header']/*[local-name()='identifier']='" + marcIdentifier + "']/*[local-name()='header']/@status)")
    * def folioListStatus = karate.xmlPath(response, "string(//*[local-name()='record'][*[local-name()='header']/*[local-name()='identifier']='" + folioIdentifier + "']/*[local-name()='header']/@status)")
    * def marcListDatestamp = karate.xmlPath(response, "string(//*[local-name()='record'][*[local-name()='header']/*[local-name()='identifier']='" + marcIdentifier + "']/*[local-name()='header']/*[local-name()='datestamp'])")
    * def folioListDatestamp = karate.xmlPath(response, "string(//*[local-name()='record'][*[local-name()='header']/*[local-name()='identifier']='" + folioIdentifier + "']/*[local-name()='header']/*[local-name()='datestamp'])")

    * match marcListStatus == 'deleted'
    * match folioListStatus == 'deleted'
    * match marcListDatestamp == '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'
    * match folioListDatestamp == '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'
    * assert marcListDatestamp >= marcDatestampBeforeEdit
    * assert folioListDatestamp >= folioDatestampBeforeEdit

    # Cleanup test records.
    Given url baseUrl
    And path 'source-storage/records', srsRecordId
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', marcInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', folioInstanceId
    And header x-okapi-token = okapitoken
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204
