Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }
    * def recordId = uuid()
    * def snapshotId = uuid()
    * def holdingId = uuid()
    * def instanceId = '1762b035-f87b-4b6f-80d8-c02976e03575'

  Scenario: create base instance
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'b73eccf0-57a6-495e-898d-32b9b2210f2f'}

  Scenario: setup instance with marc record and holding
    * def instanceId = '1762b035-f87b-4b6f-80d8-c02976e03575'
    * def holdingId = 'ace30183-e8a0-41a3-88a2-569b38764db6'
    * def MFHDHoldingRecordId = '3b1437a4-a9b5-4abe-a1ee-db54a7ccf89e'

    #create uuids
    * def recordId = uuid()
    * def snapshotId = uuid()

    #create snapshot
    * call read('classpath:global/mod_srs_init_data.feature@PostSnapshot') {snapshotId:'#(snapshotId)'}

    #create record
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcBibRecord') {recordId:'#(recordId)', snapshotId:'#(snapshotId)', instanceId:'#(instanceId)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcHoldingRecord') {recordId:'#(recordId)', snapshotId:'#(snapshotId)', holdingId:'#(MFHDHoldingRecordId)'}

    #create instance
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'#(instanceId)'}

    #create holding
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingId)'}

    #create 100 items
    * def fun = function(i){ return { barcode: 1234560 + i, holdingId: holdingId};}
    * def data = karate.repeat(100, fun)
    * call read('classpath:global/inventory_data_setup_util.feature@PostItem') data








