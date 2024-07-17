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
    And match holding1 == '#present'
    And match holding1[0].id == holdingsId1
    And match holding1[0].instanceId == instanceId

    And def holding2 = karate.jsonPath(holdingsRecords, "$[?(@.id=='" + holdingsId2 + "')]")
    And match holding2 == '#present'
    And match holding2[0].id == holdingsId2
    And match holding2[0].instanceId == instanceId

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

  Scenario: Test disallow changing ownership of holdings with linked boundwith items
    # Create local Instance on University.
    * configure headers = headersUniversity

    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id
    And def instanceTitle = instance.title

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And def instanceHrId = response.hrid

    # Add first Holding for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId1 = holdings.id

    # Add second Holding for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId2 = holdings.id
    And def holdingsHrId2 = holdings.hrid

    # Add third Holding for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId3 = holdings.id

    # Create an Item for the Holding
    Given def itemRequest = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId1)' }
    And def item = itemRequest.response
    And def itemsId = item.id

    # Add bound-with
    Given path 'inventory-storage/bound-withs'
    And request
      """
      {
        itemId: '#(itemsId)',
        boundWithContents: [{ holdingsRecordId : '#(holdingsId2)'}]
      }
      """
    When method PUT
    Then status 204

    * set item.boundWithTitles =
    """
    [
      {
        "briefHoldingsRecord": {
          "hrid": "#(holdingsHrId2)",
          "id": "#(holdingsId2)"
        },
        "briefInstance": {
          "id": "#(instanceId)",
          "hrid": "#(instanceHrId)",
          "title": "#(instanceTitle)"
        }
      }
    ]
    """

    Given path 'inventory/items', itemsId
    And request item
    When method PUT
    Then status 204

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

    * def errorMessage1 = "Ownership of holdings record with linked bound with parts cannot be updated, holdings record id: " + holdingsId1
    * def errorMessage2 = "Ownership of holdings record with linked bound with parts cannot be updated, holdings record id: " + holdingsId2

    Given path 'inventory/holdings/update-ownership'
    And request
      """
      {
        toInstanceId: '#(instanceId)',
        holdingsRecordIds: ['#(holdingsId1)', '#(holdingsId2)', '#(holdingsId3)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 200
    And assert response.notUpdatedEntities.length == 2
    And match response.notUpdatedEntities[0].errorMessage == errorMessage1
    And match response.notUpdatedEntities[1].errorMessage == errorMessage2

    # Verify that that shared Instance has appropriate Holding at the College tenant
    * configure headers = headersCollege

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.holdingsRecords[0].id != holdingsId3
    And match response.holdingsRecords[0].instanceId == instanceId

    # Verify that shared Instance don’t have the moved Holding at the University tenant
    * configure headers = headersUniversity

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 2

  Scenario: Test disallow changing ownership of boundwith items
    # Create local Instance on University.
    * configure headers = headersUniversity

    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id
    And def instanceTitle = instance.title

    Given path 'inventory/instances', instanceId
    When method GET
    Then status 200
    And def instanceHrId = response.hrid

    # Add first Holding for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId1 = holdings.id

    # Add second Holding for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId2 = holdings.id
    And def holdingsHrId2 = holdings.hrid

    # Create first Item for of the Holding
    Given def itemRequest = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId1)' }
    And def item1 = itemRequest.response
    And def itemsId1 = item1.id

    # Create second Item for of the Holding
    Given def itemRequest = call read(utilsPath+'@CreateItems') { holdingsId:'#(holdingsId1)' }
    And def item2 = itemRequest.response
    And def itemsId2 = item2.id

    # Add bound-with
    Given path 'inventory-storage/bound-withs'
    And request
      """
      {
        itemId: '#(itemsId1)',
        boundWithContents: [{ holdingsRecordId : '#(holdingsId2)'}]
      }
      """
    When method PUT
    Then status 204

    * set item1.boundWithTitles =
      """
      [
        {
          "briefHoldingsRecord": {
            "hrid": "#(holdingsHrId2)",
            "id": "#(holdingsId2)"
          },
          "briefInstance": {
            "id": "#(instanceId)",
            "hrid": "#(instanceHrId)",
            "title": "#(instanceTitle)"
          }
        }
      ]
      """

    Given path 'inventory/items', itemsId1
    And request item1
    When method PUT
    Then status 204

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

    * def errorMessage = "Ownership of bound with parts item cannot be updated, item id: " + itemsId1

    Given path 'inventory/items/update-ownership'
    And request
      """
      {
        toHoldingsRecordId: '#(collegeHoldingsId)',
        itemIds: ['#(itemsId1)', '#(itemsId2)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 200
    And assert response.notUpdatedEntities.length == 1
    And match response.notUpdatedEntities[0].errorMessage == errorMessage

    # Verify that that shared Instance has Holdings along with an appropriate Item on the College tenant
    * configure headers = headersCollege

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + collegeHoldingsId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].id != itemsId2
    And match response.items[0].holdingsRecordId == collegeHoldingsId

    # Verify that shared Instance don’t have the moved Holdings and linked Item on the University tenant
    * configure headers = headersUniversity

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingsId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].id == itemsId1
    And match response.items[0].holdingsRecordId == holdingsId1

  Scenario: Test changing holding ownership request with invalid instance id
    * configure headers = headersUniversity

    * def nonExistentInstanceId = uuid()
    * def nonExistentHoldingsId = uuid()

    * def errorMessage = "Instance with id: " + nonExistentInstanceId + " not found at source tenant, tenant: " + universityTenant

    Given path 'inventory/holdings/update-ownership'
    And request
      """
      {
        toInstanceId: '#(nonExistentInstanceId)',
        holdingsRecordIds: ['#(nonExistentHoldingsId)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 404
    And match response == errorMessage

  Scenario: Test changing item ownership request with invalid holdings record id
    * configure headers = headersUniversity

    * def nonExistentHoldingsId = uuid()
    * def nonExistentItemId = uuid()

    * def errorMessage = "HoldingsRecord with id: " + nonExistentHoldingsId + " not found on tenant: " + collegeTenant

    Given path 'inventory/items/update-ownership'
    And request
      """
      {
        toHoldingsRecordId: '#(nonExistentHoldingsId)',
        itemIds: ['#(nonExistentItemId)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 404
    And match response == errorMessage

  Scenario: Test changing holding ownership request with not shared instance
    * configure headers = headersUniversity

    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    # Add 2 Holdings for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId = holdings.id

    * def errorMessage = "Instance with id: " + instanceId + " is not shared"

    Given path 'inventory/holdings/update-ownership'
    And request
      """
      {
        toInstanceId: '#(instanceId)',
        holdingsRecordIds: ['#(holdingsId)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 400
    And match response == errorMessage

  Scenario: Test changing item ownership request with holdingsRecord related to not shared instance
    * configure headers = headersCollege

    Given def instance = call read(utilsPath+'@CreateInstance') { source:'FOLIO', title:'TestInstance' }
    And def instanceId = instance.id

    # Add 2 Holdings for Instance
    Given def holdings = call read(utilsPath+'@CreateHoldings') { instanceId:'#(instanceId)' }
    And def holdingsId = holdings.id

    * def nonExistentItem = uuid()

    * def errorMessage = "Instance with id: " + instanceId + " related to holdings record with id: " + holdingsId + " is not shared"

    # Update ownership of holdings
    * configure headers = headersUniversity

    Given path 'inventory/items/update-ownership'
    And request
      """
      {
        toHoldingsRecordId: '#(holdingsId)',
        itemIds: ['#(nonExistentItem)'],
        targetTenantId:  '#(collegeTenant)'
      }
      """
    When method POST
    Then status 400
    And match response == errorMessage