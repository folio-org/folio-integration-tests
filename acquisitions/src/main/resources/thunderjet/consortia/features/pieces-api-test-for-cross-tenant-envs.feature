Feature: Pieces API tests for cross-tenant envs

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def minimalPiece = read('classpath:samples/consortia/pieces/minimal-piece.json')
    * def createCirculationRequest = read('classpath:thunderjet/mod-orders/reusable/create-circulation-request.feature')
    * def createUserGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateGroup')
    * def setUserPatronGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@SetUserPatronGroup')

    * def fundId = callonce uuid
    * def orderId = callonce uuid
    * def poLineId = callonce uuid
    * def titleId = callonce uuid
    * def pieceId = callonce uuid

    * callonce createOrder { id: #(orderId) }
    * callonce createOrderLine { id: #(poLineId), orderId: #(orderId), isPackage: True }
    * callonce createTitle { titleId: #(titleId), poLineId: #(poLineId) }


  Scenario: Check ShadowInstance, Holding and Item created in member tenant when creating piece
    # Create a new piece
    * set minimalPiece.id = pieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.locationId = universityLocationsId;
    * set minimalPiece.receivingTenantId = universityTenant;
    Given path 'orders/pieces'
    And header x-okapi-tenant = centralTenant
    And param createItem = true
    And request minimalPiece
    When method POST
    Then status 201
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.receivingTenantId == '#(universityTenant)'
    And def holdingId = response.holdingId

    # Check the created holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'
    And def instanceId = response.instanceId

    # Check the created shared instance in specified tenant
    Given path '/instance-storage/instances', instanceId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check the created item in specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item updated in member tenant when updating piece without itemId and deleteHolding=true
    # Get existing holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def oldItemId = response.itemId
    And def oldHoldingId = response.holdingId

    # Delete associated item for holding to be deleted in specified tenant
    Given path '/inventory/items', oldItemId
    And header x-okapi-tenant = universityTenant
    When method DELETE
    Then status 204

    # Update existing piece
    * set minimalPiece.id = pieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.locationId = universityLocationsId;
    * set minimalPiece.receivingTenantId = universityTenant;
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    And param createItem = true
    And param deleteHolding = true
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
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

    # Check the created holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the deleted old holding record in specified tenant
    Given path '/holdings-storage/holdings/', oldHoldingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # Check the created item in specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item after receiving the piece
    # Receive piece
    Given path 'orders/check-in'
    And header x-okapi-tenant = centralTenant
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
              receivingTenantId: "#(universityTenant)"
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
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.receivingStatus == 'Received'
    And def holdingId = response.holdingId

    # Check the holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the item in specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
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
    And header x-okapi-tenant = centralTenant
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
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And match response.receivingStatus == 'Expected'
    And def holdingId = response.holdingId

    # Check the holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the item in specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
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
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def oldItemId = response.itemId
    And def oldHoldingId = response.holdingId

    # Update piece
    * set minimalPiece.id = pieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.itemId = oldItemId;
    * set minimalPiece.locationId = universityLocationsId;
    * set minimalPiece.receivingTenantId = universityTenant;
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    And param createItem = true
    And param deleteHolding = false
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#(oldItemId)'
    And match response.holdingId == '#present'
    And match response.holdingId != '#(oldHoldingId)'
    And def holdingId = response.holdingId

    # Check the updated holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the old holding record as it should not be deleted in specified tenant
    Given path '/holdings-storage/holdings/', oldHoldingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200

    # Check the old item as it should not be deleted in specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item updated in member tenant when updating piece with itemId and deleteHolding=true
    # Get existing holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def oldItemId = response.itemId
    And def oldHoldingId = response.holdingId

    # Update piece
    * set minimalPiece.id = pieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.itemId = oldItemId;
    * set minimalPiece.locationId = universityLocationsId;
    * set minimalPiece.receivingTenantId = universityTenant;
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    And param createItem = true
    And param deleteHolding = true
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId in specified tenant
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.id == '#(pieceId)'
    And match response.poLineId == '#(poLineId)'
    And match response.titleId == '#(titleId)'
    And match response.itemId == '#(oldItemId)'
    And match response.holdingId == '#present'
    And match response.holdingId != '#(oldHoldingId)'
    And def holdingId = response.holdingId

    # Check the updated holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 200
    And match response.instanceId == '#present'

    # Check the deleted holding record in specified tenant
    Given path '/holdings-storage/holdings/', oldHoldingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # Check no items exist for deleted holding in the specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'holdingsRecordId=' + oldHoldingId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # Check new item in the specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[0].holdingsRecordId == '#(holdingId)'
    And match response.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item deleted in member tenant when deleting piece
    # Get existing holdingId in specified tenant
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    When method GET
    Then status 200
    And match response.itemId == '#present'
    And match response.holdingId == '#present'
    And def holdingId = response.holdingId

    # Delete piece
    Given path 'orders/pieces', pieceId
    And header x-okapi-tenant = centralTenant
    And param deleteHolding = true
    When method DELETE
    Then status 204

    # Check the deleted holding record in specified tenant
    Given path '/holdings-storage/holdings/', holdingId
    And header x-okapi-tenant = universityTenant
    When method GET
    Then status 404

    # Check the deleted item in specified tenant
    Given path '/inventory/items'
    And header x-okapi-tenant = universityTenant
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 0


  Scenario: Fetch circulation requests by Piece ids
    * def patronGroupId = call uuid

    # 1.1 Create and set patron group for central tenant user
    * def v = call login consortiaAdmin

    * table groupDetails
      | id            | group   | tenant        |
      | patronGroupId | 'staff' | centralTenant |
    * def v = call createUserGroup groupDetails

    * table userGroupDetails
      | userId         | groupId       | tenant        |
      | centralAdminId | patronGroupId | centralTenant |
    * def v = call setUserPatronGroup userGroupDetails

    Given path 'users', centralAdminId
    And header x-okapi-tenant = centralTenant
    And retry until response.patronGroup == patronGroupId
    When method GET
    Then status 200

    # 1.2 Create and set patron group for target tenant user
    * table uniUserDetails
      | username           | password                    | tenant           |
      | universityUser1.username | universityUser1.password | universityTenant |
    * def v = call login uniUserDetails

    * table groupDetails
      | id            | group   | tenant           |
      | patronGroupId | 'staff' | universityTenant |
    * def v = call createUserGroup groupDetails

    * table userGroupDetails
      | userId            | groupId       | tenant           |
      | universityUser1Id | patronGroupId | universityTenant |
    * def v = call setUserPatronGroup userGroupDetails

    Given path 'users', universityUser1Id
    And header x-okapi-tenant = universityTenant
    And retry until response.patronGroup == patronGroupId
    When method GET
    Then status 200

    # 2. Setup Circulation Policy
    * def v = call login consortiaAdmin
    * table tenant
      | tenant        |
      | centralTenant |
    * def v = call read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature') tenant
    * table tenant
      | tenant           |
      | universityTenant |
    * def v = call read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature') tenant

    # 3.1 Create piece for central
    * def centralPieceId = call uuid
    * set minimalPiece.id = centralPieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.locationId = centralLocationsId;
    Given path 'orders/pieces'
    And header x-okapi-tenant = centralTenant
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
    * set minimalPiece.id = universityPieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.locationId = universityLocationsId;
    * set minimalPiece.receivingTenantId = universityTenant;
    Given path 'orders/pieces'
    And header x-okapi-tenant = centralTenant
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
      | id         | userId         | itemId  | holdingId         | instanceId        | tenant        |
      | requestId1 | centralAdminId | itemId1 | centralHoldingId1 | centralInstanceId | centralTenant |
    * def v = call createCirculationRequest request1

    * table request2
      | id         | userId            | itemId  | holdingId            | instanceId           | tenant           |
      | requestId2 | universityUser1Id | itemId2 | universityHoldingId1 | universityInstanceId | universityTenant |
    * def v = call createCirculationRequest request2

    # 4.2 Verify circulation request 2
    Given path 'circulation', 'requests', requestId2
    And header x-okapi-tenant = universityTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.itemId == itemId2

    # 4.3 Verify circulation request 1
    Given path 'circulation', 'requests', requestId1
    And header x-okapi-tenant = centralTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response.itemId == itemId1

    # 5 Get requests by Piece Ids
    Given path '/orders/pieces-requests'
    And header x-okapi-tenant = centralTenant
    And param status = 'Open - Not yet filled'
    And params { "pieceIds": [ '#(centralPieceId)', '#(universityPieceId)' ] }
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.circulationRequests[*].id contains requestId1
    And match response.circulationRequests[*].id contains requestId2