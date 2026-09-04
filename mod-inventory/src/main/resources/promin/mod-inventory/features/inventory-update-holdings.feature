Feature: Update holdings

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testTenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def utilsPath = 'classpath:promin/mod-inventory/features/utils.feature'

  @C491304
  Scenario: Update holdings discoverySuppress and verify source record is updated
    Given def instance = call read(utilsPath + '@CreateInstance') { source:'MARC', title:'HoldingsForUpdate' }
    And def instanceId = instance.id

    Given path 'inventory/instances/' + instanceId
    When method GET
    Then status 200
    And def instanceHrid = response.hrid

    Given def snapshot = call read(utilsPath + '@CreateSnapshot')
    And def snapshotId = snapshot.id

    Given def holdingsRecord = call read(utilsPath + '@CreateHoldingsRecord')
    And def holdingsId = holdingsRecord.id
    And def holdingsSourceRecordId = holdingsRecord.holdingsSourceRecordId

    Given path 'holdings-storage/holdings/' + holdingsId
    When method GET
    Then status 200
    And def holdings = response
    * eval holdings['discoverySuppress'] = true

    * call read(utilsPath + '@UpdateHoldings') { holdingsId: '#(holdingsId)', holdings: '#(holdings)' }

    Given path 'source-storage/source-records/' + holdingsSourceRecordId
    And retry until response.additionalInfo && response.additionalInfo.suppressDiscovery == true
    When method GET
    Then status 200
    And match response.additionalInfo.suppressDiscovery == true
