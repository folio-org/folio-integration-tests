Feature: init data for mod-inventory-storage

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenAdmin = okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * configure retry = { interval: 3000, count: 10 }

  Scenario: setup locations
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstitution')
    * json campuses = read('classpath:samples/location/campus.json')
    * call read('classpath:global/inventory_data_setup_util.feature@PostCampus') {campus: #(campuses[0])}
    * call read('classpath:global/inventory_data_setup_util.feature@PostCampus') {campus: #(campuses[1])}
    * json libraries = read('classpath:samples/location/library.json')
    * call read('classpath:global/inventory_data_setup_util.feature@PostLibrary') {library: #(libraries[0])}
    * call read('classpath:global/inventory_data_setup_util.feature@PostLibrary') {library: #(libraries[1])}
    * json locations = read('classpath:samples/location/locations.json')
    * call read('classpath:global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[0])}
    * call read('classpath:global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[1])}
    * call read('classpath:global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[2])}
    * call read('classpath:global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[3])}
    * call read('classpath:global/inventory_data_setup_util.feature@PostLocation') {location: #(locations[4])}

  Scenario: create base instance
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'b73eccf0-57a6-495e-898d-32b9b2210f2f'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance2') {instanceId:'54cfd483-95d5-433a-940a-f3a80a0cd80c'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance3') {instanceId:'baba4ffb-af1b-4ab9-930b-5141e955dc0b'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance4') {instanceId:'da50346c-15d7-42b7-a60e-fae13046bc7e'}

  Scenario: setup instance with marc record and holding
    * def instanceId = '1762b035-f87b-4b6f-80d8-c02976e03575'
    * def instanceIdForHoldingWithRecord = '5b1eb450-ff9f-412d-a9e7-887f6eaeb5b4'
    * def instanceWith100Item = '993ccbaf-903e-470c-8eca-02d3b4f8ac54'
    * def holdingId = 'ace30183-e8a0-41a3-88a2-569b38764db6'
    * def MFHDHoldingRecordId = '3b1437a4-a9b5-4abe-a1ee-db54a7ccf89e'
    * def holdingIdWithoutSrsRecord = '35540ed1-b1d3-4222-ab26-981a20d8f851'
    * def holdingIdWithoutSrsRecord2 = 'd72f3bb1-ca88-454b-aad7-d0c8ea36f467'
    * def holdingIdWithoutSrsRecord3 = '378c97da-4ab8-4df4-beae-849eebfe5140'
    * def holdingIdWithoutSrsRecord4 = '13190781-967d-4a5e-a0dd-0bf10a4c35db'
    * def authorityId1 = 'c32a3b93-b459-4bd4-a09b-ac1f24c7b999'
    * def authorityId2 = '261b8e33-cf1f-48b3-85e2-b55b1dc360e6'
    * def authorityId3 = '7964b834-9766-45e6-b6e0-cb2b86f0a19f'
    * def authorityId4 = '8bcbc604-604b-4ffa-ab08-bf787dbb11e1'
    * def authorityRecordId1 = '432d6568-159a-4b20-962c-63fd59ddc07c'
    * def authorityRecordId2 = 'da365a57-2751-4ad9-ad9e-55f770f0a8f2'
    * def authorityRecordId3 = '845f26ba-f171-4af2-8361-74bab1b22c92'
    * def authorityRecordId4 = '61a73463-3d74-4ebf-bc74-d1e168df4186'
    * def recordId = uuid()
    * def holdingRecordId = uuid()
    * def snapshotId = uuid()
    * def defaultHoldingId = '1aafaeef-4928-477b-86f5-9431ba754692'
    * def holdingsSourceFolio = 'f32d531e-df79-46b3-8932-cdd35f7a2264'

    #create snapshot  993ccbaf-903e-470c-8eca-02d3b4f8ac54
    * call read('classpath:global/mod_srs_init_data.feature@PostSnapshot') {snapshotId:'#(snapshotId)'}

    #create instance
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'#(instanceId)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'#(instanceIdForHoldingWithRecord)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostInstance') {instanceId:'#(instanceWith100Item)'}

    #create holdings source
    * def holdingsSource = karate.read('classpath:samples/holdings_source.json');
    * call read('classpath:global/inventory_data_setup_util.feature@PostHoldingsRecordsSource') {holdingsSource:'#(holdingsSource)'}

    #create holdings
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingId)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostDefaultHolding') {instanceId:'#(instanceId)', defaultHoldingId:'#(defaultHoldingId)'}

    #create authority records using different templates to avoid conflicts
    * call read('classpath:global/inventory_data_setup_util.feature@PostAuthority1') {authorityId:'#(authorityId1)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostAuthority2') {authorityId:'#(authorityId2)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostAuthority3') {authorityId:'#(authorityId3)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostAuthority4') {authorityId:'#(authorityId4)'}

    #create 100 items for above holding
    * def fun = function(i){ return { barcode: 1234560 + i, holdingId: holdingId};}
    * def data = karate.repeat(100, fun)
    * call read('classpath:global/inventory_data_setup_util.feature@PostItem') data

    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceIdForHoldingWithRecord)', holdingId:'#(MFHDHoldingRecordId)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingIdWithoutSrsRecord)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingIdWithoutSrsRecord2)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingIdWithoutSrsRecord3)'}
    * call read('classpath:global/inventory_data_setup_util.feature@PostHolding') {instanceId:'#(instanceId)', holdingId:'#(holdingIdWithoutSrsRecord4)'}

    #create bib and holding records
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcBibRecord') {recordId:'#(recordId)', snapshotId:'#(snapshotId)', instanceId:'#(instanceIdForHoldingWithRecord)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcHoldingRecord') {recordId:'#(holdingRecordId)', snapshotId:'#(snapshotId)', holdingId:'#(MFHDHoldingRecordId)'}

    #create MARC authority records using different templates to avoid conflicts
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord1') {recordId:'#(authorityRecordId1)', snapshotId:'#(snapshotId)', authorityId:'#(authorityId1)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord2') {recordId:'#(authorityRecordId2)', snapshotId:'#(snapshotId)', authorityId:'#(authorityId2)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord3') {recordId:'#(authorityRecordId3)', snapshotId:'#(snapshotId)', authorityId:'#(authorityId3)'}
    * call read('classpath:global/mod_srs_init_data.feature@PostMarcAuthorityRecord4') {recordId:'#(authorityRecordId4)', snapshotId:'#(snapshotId)', authorityId:'#(authorityId4)'}

    #wait for authority records to be indexed and available
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * eval sleep(3000)

  Scenario: reindex data
      Given path '/instance-storage/reindex'
      When method POST
      Then status 200
      And def reindexJobId = response.id

      Given path '/instance-storage/reindex', reindexJobId
      And retry until response.jobStatus == 'Ids published'
      When method GET
      Then status 200