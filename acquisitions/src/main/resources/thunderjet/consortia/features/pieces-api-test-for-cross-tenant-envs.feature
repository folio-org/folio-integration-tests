@parallel=false
Feature: Pieces API tests for cross-tenant envs

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def resultAdmin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def okapitoken = resultAdmin.okapitoken
    * def resultUniAdmin = call eurekaLogin { username: '#(universityUser.username)', password: '#(universityUser.password)', tenant: '#(universityTenantName)'}
    * def okapitokenUni = resultUniAdmin.okapitoken
    * def resultUser = call eurekaLogin { username: '#(centralUser.username)', password: '#(centralUser.password)', tenant: '#(centralTenantName)'}
    * def okapitokenUser = resultUser.okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * def headersUniAdmin = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitokenUni)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json, text/plain' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json, text/plain' }
    * configure headers = headersCentral

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def minimalPiece = read('classpath:samples/consortia/pieces/minimal-piece.json')
    * def createCirculationRequest = read('classpath:thunderjet/mod-orders/reusable/create-circulation-request.feature')
    * def createUserGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateGroup')
    * def setUserPatronGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@SetUserPatronGroup')

    * def fundId = callonce uuid
    * def orderId = callonce uuid
    * def poLineId = callonce uuid
    * def titleId = callonce uuid
    * def pieceId = callonce uuid

    * callonce createOrder { id: '#(orderId)' }
    * callonce createOrderLine { 'id': '#(poLineId)', 'orderId': '#(orderId)', 'checkinItems': true, isPackage: True }
    * callonce createTitle { titleId: '#(titleId)', poLineId: '#(poLineId)' }


  Scenario: Check ShadowInstance, Holding and Item created in member tenant when creating piece
    # Create a new piece
    * set minimalPiece.id = pieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.locationId = universityLocationsId
    * set minimalPiece.receivingTenantId = universityTenantName
    Given path 'orders/pieces'
    And param createItem = true
    And request minimalPiece
    When method POST
    Then status 201
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.receivingTenantId == '#(universityTenantName)'
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # Check the created holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'
    And def instanceId = response.instanceId

    # Check the created shared instance in specified tenant
    Given path '/instance-storage/instances', instanceId
    When method GET
    Then status 200

    # Check the created item in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'

  Scenario: Check receivingTenantId populated when openining order with 'Instance, Holding'
    * def orderId = call uuid
    * def poLineId = call uuid

    ## 1. Create Order
    * def v = call createOrder { id: '#(orderId)' }

    ## 2. Create OrderLine
    ## Set 'universityTenant' and 'centralTenant' tenantId for third location
    ## to verify this tenant in piece receivingTenatId field
    * def poLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.locations[1].tenantId = centralTenantName
    * set poLine.locations[1].locationId = centralLocationsId
    * set poLine.locations[2].tenantId = universityTenantName
    * set poLine.locations[2].locationId = universityLocationsId
    * set poLine.physical.createInventory = "Instance, Holding"

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    ## 3. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def title = $.titles[0]
    * def titleId = title.id

    ## 4. Verify pieces that 'universityTenant' and 'centralTenant' contains in receivingTenantId field
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' and poLineId==' + poLineId + ' and receivingStatus==("Expected" or "Late" or "Claim delayed" or "Claim sent")'
    When method GET
    Then status 200
    And match $.pieces[*].receivingTenantId contains universityTenantName
    And match $.pieces[*].receivingTenantId contains universityTenantName

  Scenario: Check receivingTenantId populated when openining order with 'Instance, Holding, Item'
  `
    * def orderId = call uuid
    * def poLineId = call uuid

    ## 1. Create Order
    * def v = call createOrder { id: '#(orderId)' }

    ## 2. Create OrderLine
    ## Set 'universityTenant' and 'centralTenant' tenantId for third location
    ## to verify this tenant in piece receivingTenatId field
    * def poLine = read('classpath:samples/consortia/orderLines/multi-tenant-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.locations[1].tenantId = centralTenantName
    * set poLine.locations[1].locationId = centralLocationsId
    * set poLine.locations[2].tenantId = universityTenantName
    * set poLine.locations[2].locationId = universityLocationsId
    * set poLine.physical.createInventory = "Instance, Holding, Item"

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    ## 3. Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def title = $.titles[0]
    * def titleId = title.id

    ## 4. Verify pieces that 'universityTenant' and 'centralTenant' contains in receivingTenantId field
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' and poLineId==' + poLineId + ' and receivingStatus==("Expected" or "Late" or "Claim delayed" or "Claim sent")'
    When method GET
    Then status 200
    And match $.pieces[*].receivingTenantId contains universityTenantName
    And match $.pieces[*].receivingTenantId contains centralTenantName

  Scenario: Check Holding and Item updated in member tenant when updating piece without itemId and deleteHolding=true
    # Get existing holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def oldItemId = response.itemId
    And def oldHoldingId = response.holdingId

    * configure headers = headersUni
    # Delete associated item for holding to be deleted in specified tenant
    Given path '/inventory/items', oldItemId
    When method DELETE
    Then status 204

    * configure headers = headersCentral
    # Update existing piece
    * set minimalPiece.id = pieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.locationId = universityLocationsId
    * set minimalPiece.receivingTenantId = universityTenantName
    Given path 'orders/pieces', pieceId
    And param createItem = true
    And param deleteHolding = true
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.itemId != '#(oldItemId)'
    And match response.holdingId != '#(oldHoldingId)'
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # Check the created holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the deleted old holding record in specified tenant
    Given path '/holdings-storage/holdings/', oldHoldingId
    When method GET
    Then status 404

    # Check the created item in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item after receiving the piece
    # Receive piece
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId)",
              itemStatus: "In process",
              locationId: "#(universityLocationsId)",
              receivingTenantId: "#(universityTenantName)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match response.receivingResults[0].processedSuccessfully == 1

    # Get existing holdingId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.receivingStatus == 'Received'
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # Check the holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the item in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'
    And match response.items[0].status.name == 'In process'


  Scenario: Check Holding and Item after unreceiving the piece
    # Unreceive piece
    Given path 'orders/receive'
    And request
    """
    {
      toBeReceived: [
        {
          received: 1,
          receivedItems: [
            {
              pieceId: "#(pieceId)",
              itemStatus: "On order"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match response.receivingResults[0].processedSuccessfully == 1

    # Get existing holdingId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.receivingStatus == 'Expected'
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # Check the holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the item in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'
    And match response.items[0].status.name == 'On order'


  Scenario: Check Holding and Item updated in member tenant when updating piece with itemId and deleteHolding=false
    # Get existing holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def oldItemId = response.itemId
    And def oldHoldingId = response.holdingId

    # Update piece
    * set minimalPiece.id = pieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.itemId = oldItemId
    * set minimalPiece.locationId = universityLocationsId
    * set minimalPiece.receivingTenantId = universityTenantName
    Given path 'orders/pieces', pieceId
    And param createItem = true
    And param deleteHolding = false
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#(oldItemId)'
    And match response.holdingId == '#present'
    And match response.holdingId != '#(oldHoldingId)'
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # Check the updated holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the old holding record as it should not be deleted in specified tenant
    Given path '/holdings-storage/holdings/', oldHoldingId
    When method GET
    Then status 200

    # Check the old item as it should not be deleted in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item updated in member tenant when updating piece with itemId and deleteHolding=true
    # Get existing holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def oldItemId = response.itemId
    And def oldHoldingId = response.holdingId

    # Update piece
    * set minimalPiece.id = pieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.itemId = oldItemId
    * set minimalPiece.locationId = universityLocationsId
    * set minimalPiece.receivingTenantId = universityTenantName
    Given path 'orders/pieces', pieceId
    And param createItem = true
    And param deleteHolding = true
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#(oldItemId)'
    And match response.holdingId == '#present'
    And match response.holdingId != '#(oldHoldingId)'
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # Check the updated holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the deleted holding record in specified tenant
    Given path '/holdings-storage/holdings/', oldHoldingId
    When method GET
    Then status 404

    # Check no items exist for deleted holding in the specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + oldHoldingId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Check new item in the specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item deleted in member tenant when deleting piece
    # Get existing holdingId in specified tenant
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def holdingId = response.holdingId

    # Delete piece
    Given path 'orders/pieces', pieceId
    And param deleteHolding = true
    When method DELETE
    Then status 204

    * configure headers = headersUni
    # Check the deleted holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 404

    # Check the deleted item in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 0


  Scenario: Fetch circulation requests by Piece ids
    * def patronGroupId = call uuid

    # 1.1 Create and set patron group for central tenant user

    * table groupDetails
      | id            | group   | tenant            |
      | patronGroupId | 'staff' | centralTenantName |
    * def v = call createUserGroup groupDetails

    * table userGroupDetails
      | userId         | groupId       | tenant            |
      | centralAdminId | patronGroupId | centralTenantName |
    * def v = call setUserPatronGroup userGroupDetails

    Given path 'users', centralAdminId
    And retry until response.patronGroup == patronGroupId
    When method GET
    Then status 200

    # 1.2 Create and set patron group for target tenant user

    * configure headers = headersUniAdmin
    * def patronGroupId2 = call uuid
    * table groupDetails
      | id             | group      | tenant               |
      | patronGroupId2 | 'staffUni' | universityTenantName |
    * def v = call createUserGroup groupDetails

    * table userGroupDetails
      | userId            | groupId       | tenant               |
      | universityUserId | patronGroupId2 | universityTenantName |
    * def v = call setUserPatronGroup userGroupDetails

    Given path 'users', universityUserId
    And retry until response.patronGroup == patronGroupId2
    When method GET
    Then status 200

    # 2. Setup Circulation Policy
    * configure headers = headersCentral
    * table tenant
      | tenant            |
      | centralTenantName |
    * def v = call read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature') tenant
    * configure headers = headersUni
    * table tenant
      | tenant               |
      | universityTenantName |
    * def v = call read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature') tenant

    * configure headers = headersCentral
    # 3.1 Create piece for central
    * def centralPieceId = call uuid
    * set minimalPiece.id = centralPieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.locationId = centralLocationsId
    Given path 'orders/pieces'
    And param createItem = true
    And request minimalPiece
    When method POST
    Then status 201
    And match response.id == '#(centralPieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def itemId1 = response.itemId

    # 3.2 Create piece for university
    * def universityPieceId = call uuid
    * set minimalPiece.id = universityPieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.locationId = universityLocationsId
    * set minimalPiece.receivingTenantId = universityTenantName
    Given path 'orders/pieces'
    And param createItem = true
    And request minimalPiece
    When method POST
    Then status 201
    And match response.id == '#(universityPieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def itemId2 = response.itemId

    # 4.1 Create Circulation Requests
    * def requestId1 = call uuid
    * def requestId2 = call uuid

    * table request1
      | id         | userId         | itemId  | holdingId         | instanceId        | tenant            |
      | requestId1 | centralAdminId | itemId1 | centralHoldingId1 | centralInstanceId | centralTenantName |
    * def v = call createCirculationRequest request1

    * configure headers = headersUni
    * table request2
      | id         | userId            | itemId  | holdingId            | instanceId           | tenant               |
      | requestId2 | universityUserId | itemId2 | universityHoldingId1 | universityInstanceId | universityTenantName |
    * def v = call createCirculationRequest request2

    # 4.2 Verify circulation request 2
    Given path 'circulation', 'requests', requestId2
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.itemId == itemId2

    * configure headers = headersCentral
    # 4.3 Verify circulation request 1
    Given path 'circulation', 'requests', requestId1
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.itemId == itemId1

    # 5 Get requests by Piece Ids
    Given path '/orders/pieces-requests'
    And param status = 'Open - Not yet filled'
    And params { "pieceIds": [ '#(centralPieceId)', '#(universityPieceId)' ] }
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.circulationRequests[*].id contains requestId1
    And match response.circulationRequests[*].id contains requestId2


  Scenario: Change affiliation in Piece and check that item and holding was re-created in correct tenant
    # 1. Create piece for central
    * set minimalPiece.id = pieceId
    * set minimalPiece.titleId = titleId
    * set minimalPiece.poLineId = poLineId
    * set minimalPiece.locationId = universityLocationsId
    * set minimalPiece.receivingTenantId = universityTenantName

    Given path 'orders/pieces'
    And param createItem = true
    And request minimalPiece
    When method POST
    Then status 201
    And match response.id == '#(pieceId)'
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def itemId1 = response.itemId
    And def holdingId = response.holdingId

    * configure headers = headersUni
    # 2.1 Check the created holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'
    And def instanceId = response.instanceId

    # 2.2 Check the created shared instance in specified tenant
    Given path '/instance-storage/instances', instanceId
    When method GET
    Then status 200

    # 2.3 Check the created item in specified tenant
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'

    * configure headers = headersCentral
    # 3. Change affliation in the piece
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And def pieceResponse = response

    * set pieceResponse.receivingTenantId = centralTenantName
    * set pieceResponse.locationId = centralLocationsId
    * set pieceResponse.holdingId = null

    Given path 'orders/pieces', pieceId
    And request pieceResponse
    When method PUT
    Then status 204

    # 4.1 Verify changing of holding
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match holdingId != response.holdingId
    And def centralHoldingId = response.holdingId

    # 4.2 Check the created holding record in 'centralTenant'
    Given path '/holdings-storage/holdings/', centralHoldingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # 4.3 Check the created shared instance in 'centralTenant'
    Given path '/instance-storage/instances', instanceId
    When method GET
    Then status 200

    # 4.4 Check the created item in 'centralTenant'
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + centralHoldingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(centralHoldingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'

    * configure headers = headersUni
    # 5.1 Verify that existing shared holding and item, and deletion of items in 'univeristyTenant'
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match response.instanceId == '#present'
    And def instanceId = response.instanceId

    # 5.2 Check the existing shared instance in 'univeristyTenant'
    Given path '/instance-storage/instances', instanceId
    When method GET
    Then status 200

    # 5.3 Verify no item in 'univeristyTenant'
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 0


  Scenario: Get all pieces filtered by user tenants
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def pieceId3 = call uuid
    * def titleId2 = call uuid

    # 1. Create a title for pieces
    * table titleDetails
      | titleId  | poLineId |
      | titleId2 | poLineId |
    * def v = call createTitle titleDetails

    # 2. Create three pieces with IDs 'pieceId1' and 'pieceId2'
    # One with associated tenant, one with no receiving tenant and one with unassociated tenant for user
    * table pieces
      | id       | format     | poLineId | titleId  | holdingId            | receivingTenantId     |
      | pieceId1 | "Physical" | poLineId | titleId2 | centralHoldingId1    | null                  |
      | pieceId2 | "Physical" | poLineId | titleId2 | centralHoldingId1    | centralTenantName     |
      | pieceId3 | "Physical" | poLineId | titleId2 | universityHoldingId1 | universityTenantName  |
    * def v = call createPieceWithHolding pieces

    # 3. Fetch all pieces
    * configure headers = headersUser
    Given path '/orders/pieces'
    And param query = 'titleId==' + titleId2
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.pieces == '#[2]'
    And match response.pieces[*].id contains pieceId1
    And match response.pieces[*].id contains pieceId2