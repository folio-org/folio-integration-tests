@parallel=false
Feature: GetRecord: SRS & Inventory - Verify deleted item data is omitted from marc21_withholdings for MARC and FOLIO instances

  # TestRail Case ID: C375984
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
    * configure retry = { count: 15, interval: 2000 }

  @Positive @C375984
  Scenario: C375984 - Verify deleted item data is omitted from GetRecord marc21_withholdings for SRS and FOLIO instances
    * def srsInstanceId = '356820aa-6f20-4f6d-b84d-3bcab1f6c001'
    * def srsRecordId = '356820aa-6f20-4f6d-b84d-3bcab1f6c002'
    * def srsSnapshotId = '356820aa-6f20-4f6d-b84d-3bcab1f6c003'
    * def srsHoldingsId = '356820aa-6f20-4f6d-b84d-3bcab1f6c004'
    * def srsItemId = '356820aa-6f20-4f6d-b84d-3bcab1f6c005'
    * def srsHrid = 'instC356820S001'
    * def srsBarcode = 'C356820-SRS-ITEM-01'
    * def srsIdentifier = 'oai:folio.org:' + testUser.tenant + '/' + srsInstanceId
    * def holdingsUri = 'http://www.jstor.com'

    * def folioInstanceId = '356820aa-6f20-4f6d-b84d-3bcab1f6c006'
    * def folioHoldingsId = '356820aa-6f20-4f6d-b84d-3bcab1f6c007'
    * def folioItemId = '356820aa-6f20-4f6d-b84d-3bcab1f6c008'
    * def folioHrid = 'instC356820F001'
    * def folioBarcode = 'C356820-FOLIO-ITEM-01'
    * def folioIdentifier = 'oai:folio.org:' + testUser.tenant + '/' + folioInstanceId

    # Create MARC-backed instance (equivalent to MARC Bib import target record).
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def srsInstance = read('classpath:samples/instance.json')
    * set srsInstance.id = srsInstanceId
    * set srsInstance.hrid = srsHrid
    * set srsInstance.source = 'MARC'
    And request srsInstance
    When method POST
    Then status 201

    # Create snapshot and SRS MARC bib linked to MARC instance.
    Given url baseUrl
    And path 'source-storage/snapshots'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "jobExecutionId": "#(srsSnapshotId)",
      "status": "PARSING_IN_PROGRESS"
    }
    """
    When method POST
    Then status 201

    Given url baseUrl
    And path 'source-storage/records'
    * def srsRecord = read('classpath:samples/marc_record.json')
    * set srsRecord.id = srsRecordId
    * set srsRecord.snapshotId = srsSnapshotId
    * set srsRecord.externalIdsHolder.instanceId = srsInstanceId
    * set srsRecord.externalIdsHolder.instanceHrid = srsHrid
    * set srsRecord.matchedId = srsRecordId
    And request srsRecord
    And header Accept = 'application/json'
    When method POST
    Then status 201

    # Create MARC holdings + item for the MARC-backed instance.
    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def srsHolding = read('classpath:samples/holding.json')
    * set srsHolding.id = srsHoldingsId
    * set srsHolding.instanceId = srsInstanceId
    * set srsHolding.hrid = srsHrid + '_h1'
    * set srsHolding.sourceId = '036ee84a-6afd-4c3c-9ad3-4a12ab875f59'
    And request srsHolding
    When method POST
    Then status 201

    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def srsItem = read('classpath:samples/item.json')
    * set srsItem.id = srsItemId
    * set srsItem.holdingsRecordId = srsHoldingsId
    * set srsItem.hrid = srsHrid + '_i1'
    * set srsItem.barcode = srsBarcode
    And request srsItem
    When method POST
    Then status 201

    # Create FOLIO instance with holdings and item.
    Given url baseUrl
    And path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def folioInstance = read('classpath:samples/instance.json')
    * set folioInstance.id = folioInstanceId
    * set folioInstance.hrid = folioHrid
    * set folioInstance.source = 'FOLIO'
    And request folioInstance
    When method POST
    Then status 201

    Given url baseUrl
    And path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def folioHolding = read('classpath:samples/holding.json')
    * set folioHolding.id = folioHoldingsId
    * set folioHolding.instanceId = folioInstanceId
    * set folioHolding.hrid = folioHrid + '_h1'
    * set folioHolding.sourceId = 'f32d531e-df79-46b3-8932-cdd35f7a2264'
    And request folioHolding
    When method POST
    Then status 201

    Given url baseUrl
    And path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    * def folioItem = read('classpath:samples/item.json')
    * set folioItem.id = folioItemId
    * set folioItem.holdingsRecordId = folioHoldingsId
    * set folioItem.hrid = folioHrid + '_i1'
    * set folioItem.barcode = folioBarcode
    And request folioItem
    When method POST
    Then status 201

    # Verify item data is present before deletion in SRS-backed GetRecord.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = srsIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.toString(response).indexOf(srsBarcode) > -1
    When method GET
    Then status 200
    * def srsBeforeDelete = karate.toString(response)
    * match srsBeforeDelete contains srsBarcode
    * match response //datafield[@tag='856']/subfield[@code='u'] contains holdingsUri

    # Delete SRS-backed item.
    Given url baseUrl
    And path 'item-storage/items', srsItemId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Verify SRS-backed item data is omitted, but holdings data remains.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = srsIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.toString(response).indexOf(srsBarcode) == -1
    When method GET
    Then status 200
    * def srsAfterDelete = karate.toString(response)
    * assert srsAfterDelete.indexOf(srsBarcode) == -1
    * match response //datafield[@tag='856']/subfield[@code='u'] contains holdingsUri

    # Verify item data is present before deletion in FOLIO GetRecord.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = folioIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.toString(response).indexOf(folioBarcode) > -1
    When method GET
    Then status 200
    * def folioBeforeDelete = karate.toString(response)
    * match folioBeforeDelete contains folioBarcode
    * match response //datafield[@tag='856']/subfield[@code='u'] contains holdingsUri

    # Delete FOLIO item.
    Given url baseUrl
    And path 'item-storage/items', folioItemId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    # Verify FOLIO item data is omitted, but holdings data remains.
    Given url pmhUrl
    And param verb = 'GetRecord'
    And param metadataPrefix = 'marc21_withholdings'
    And param identifier = folioIdentifier
    And header Accept = 'text/xml'
    And retry until responseStatus == 200 && karate.toString(response).indexOf(folioBarcode) == -1
    When method GET
    Then status 200
    * def folioAfterDelete = karate.toString(response)
    * assert folioAfterDelete.indexOf(folioBarcode) == -1
    * match response //datafield[@tag='856']/subfield[@code='u'] contains holdingsUri

    # Cleanup remaining test records.
    Given url baseUrl
    And path 'holdings-storage/holdings', srsHoldingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'source-storage/records', srsRecordId
    And header Accept = 'text/plain'
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', srsInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'holdings-storage/holdings', folioHoldingsId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

    Given url baseUrl
    And path 'instance-storage/instances', folioInstanceId
    And header Accept = 'text/plain'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204
