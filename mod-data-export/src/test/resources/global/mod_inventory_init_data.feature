Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * configure retry = { interval: 3000, count: 10 }

  Scenario: create base instance
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'b73eccf0-57a6-495e-898d-32b9b2210f2f'}

  Scenario: setup instance with marc record and holding
    * def instanceId = '1762b035-f87b-4b6f-80d8-c02976e03575'
    * def holdingId = 'ace30183-e8a0-41a3-88a2-569b38764db6'
    * def MFHDHoldingRecordId = '3b1437a4-a9b5-4abe-a1ee-db54a7ccf89e'
    * def holdingIdWithoutSrsRecord = '35540ed1-b1d3-4222-ab26-981a20d8f851'
    * def recordId = uuid()
    * def holdingRecordId = uuid()
    * def snapshotId = uuid()

    #create snapshot
    * call read('classpath:global/mod_srs_init_data.feature@PostSnapshot') {snapshotId:'#(snapshotId)'}

    #create instance
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'#(instanceId)'}

    #create holdings
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingId)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(MFHDHoldingRecordId)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingIdWithoutSrsRecord)'}

    #create record
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcBibRecord') {recordId:'#(recordId)', snapshotId:'#(snapshotId)', instanceId:'#(instanceId)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcHoldingRecord') {recordId:'#(holdingRecordId)', snapshotId:'#(snapshotId)', holdingId:'#(MFHDHoldingRecordId)'}

    #create 100 items
    * def fun = function(i){ return { barcode: 1234560 + i, holdingId: holdingId};}
    * def data = karate.repeat(100, fun)
    * call read('classpath:global/inventory_data_setup_util.feature@PostItem') data

    Scenario: reindex data
      Given path '/instance-storage/reindex'
      And def reindexRequest = {"recreateIndex": true, "resourceName": "instance"}
      And request reindexRequest
      When method POST
      Then status 200
      And def reindexJobId = response.id

      Given path '/instance-storage/reindex', reindexJobId
      And retry until response.status == 'Ids published'
      When method GET
      Then status 200