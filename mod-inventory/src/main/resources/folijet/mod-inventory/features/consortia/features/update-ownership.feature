Feature: Updating ownership of holdings and item api tests

  Background:
    * url baseUrl
    * def login = read('classpath:common-consortia/initData.feature@Login')

    * call login consortiaAdmin
    * def headersConsortia = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login universityUser1
    * def headersUniversity = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * call login collegeUser1
    * def headersCollege = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(collegeTenant)', 'Accept': 'application/json', 'Authtoken-Refresh-Cache': 'true' }

    * configure headers = headersConsortia
    * def utilsPath = 'classpath:folijet/mod-inventory/features/utils.feature'

  Scenario: Test for changing ownership of Holdings on a shared Instance
    # Create local Instance on University.
    * configure headers = headersUniversity

    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    # Add 2 Holdings for Instance
    Given def holdings1 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId1 = holdings1.id

    Given def holdings2 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId2 = holdings2.id

    # Create an Item for each of the Holdings
    Given def item1 = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId1)' }
    And def itemsId1 = item1.id

    Given def item2 = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId2)' }
    And def itemsId2 = item2.id

    # Sharing instance
    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant
    And def sharingInstanceId = response.id

    # Verify status is 'COMPLETE'
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR'
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId
    And match sharingInstance.sourceTenantId == universityTenant
    And match sharingInstance.targetTenantId == centralTenant
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is update in source tenant with source = 'CONSORTIUM-FOLIO'
    * configure headers = headersUniversity

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'

    # Update ownership of holdings
    * configure headers = headersUniversity

    Given path 'inventory/holdings/update-ownership'
    And request
      """
      {
        toInstanceId: '#(instanceId)',
        holdingsRecordIds: ['#(holdingsId2)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 200
    And assert response.notUpdatedEntities.length == 0

    # Verify that that shared Instance has Holdings along with an appropriate Item on the College tenant
    * configure headers = headersCollege

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.holdingsRecords[0].id != holdingsId2
    And match response.holdingsRecords[0].instanceId == instanceId
    And def sharedHoldingsId = response.holdingsRecords[0].id

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + sharedHoldingsId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].id != itemsId2
    And match response.items[0].holdingsRecordId == sharedHoldingsId

    # Verify that shared Instance don’t have the moved Holdings and linked Item on the University tenant
    * configure headers = headersUniversity

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.holdingsRecords[0].id == holdingsId1
    And match response.holdingsRecords[0].instanceId == instanceId

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingsId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].id == itemsId1
    And match response.items[0].holdingsRecordId == holdingsId1

  Scenario: Test for changing ownership of Item on a shared Instance
    # Create local Instance on University.
    * configure headers = headersUniversity

    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    # Add 2 Holdings for Instance
    Given def holdings1 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId1 = holdings1.id

    Given def holdings2 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId2 = holdings2.id

    # Create an Item for each of the Holdings
    Given def item1 = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId1)' }
    And def itemsId1 = item1.id

    Given def item2 = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId2)' }
    And def itemsId2 = item2.id

    # Sharing instance
    * def sharingId = uuid()
    Given path 'consortia', consortiumId, 'sharing/instances'
    And request
      """
      {
        id: '#(sharingId)',
        instanceIdentifier: '#(instanceId)',
        sourceTenantId:  '#(universityTenant)',
        targetTenantId:  '#(centralTenant)'
      }
      """
    When method POST
    Then status 201
    And match response.instanceIdentifier == instanceId
    And match response.sourceTenantId == universityTenant
    And match response.targetTenantId == centralTenant
    And def sharingInstanceId = response.id

    # Verify status is 'COMPLETE'
    Given path 'consortia', consortiumId, 'sharing/instances'
    And param instanceIdentifier = instanceId
    And param sourceTenantId = universityTenant
    And retry until response.sharingInstances[0].status == 'COMPLETE' || response.sharingInstances[0].status == 'ERROR'
    When method GET
    Then status 200
    And def sharingInstance = response.sharingInstances[0]
    And match sharingInstance.id == sharingInstanceId
    And match sharingInstance.instanceIdentifier == instanceId
    And match sharingInstance.sourceTenantId == universityTenant
    And match sharingInstance.targetTenantId == centralTenant
    And match sharingInstance.status == 'COMPLETE'

    # Verify shared instance is update in source tenant with source = 'CONSORTIUM-FOLIO'
    * configure headers = headersUniversity

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'

    # Create Holding for shared instance on Colleage tenant
    * configure headers = headersCollege

    Given def holdings2 = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def collegeHoldingsId = holdings2.id

    # Verify shadow instance is created in college tenant with source = 'CONSORTIUM-FOLIO'
    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And match response.id == instanceId
    And match response.source == 'CONSORTIUM-FOLIO'

    # Update ownership of holdings
    * configure headers = headersUniversity

    Given path 'inventory/items/update-ownership'
    And request
      """
      {
        toHoldingsRecordId: '#(collegeHoldingsId)',
        itemIds: ['#(itemsId2)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 200
    And assert response.notUpdatedEntities.length == 0

    # Verify that that shared Instance has Holdings along with an appropriate Item on the College tenant
    * configure headers = headersCollege

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.holdingsRecords[0].id == collegeHoldingsId
    And match response.holdingsRecords[0].instanceId == instanceId

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + collegeHoldingsId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].id != itemsId2
    And match response.items[0].holdingsRecordId == collegeHoldingsId

    # Verify that shared Instance don’t have the moved Holdings and linked Item on the University tenant
    * configure headers = headersUniversity

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And def holdingsRecords = response.holdingsRecords

    And def holding1 = karate.jsonPath(holdingsRecords, "$[?(@.id=='" + holdingsId1 + "')]")
    And match holding1.id == holdingsId1
    And match holding1.instanceId == instanceId

    And def holding2 = karate.jsonPath(holdingsRecords, "$[?(@.id=='" + holdingsId2 + "')]")
    And match holding2.id == holdingsId2
    And match holding2.instanceId == instanceId

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingsId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].id == itemsId1
    And match response.items[0].holdingsRecordId == holdingsId1

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingsId2
    When method GET
    Then status 200
    And match response.totalRecords == 0