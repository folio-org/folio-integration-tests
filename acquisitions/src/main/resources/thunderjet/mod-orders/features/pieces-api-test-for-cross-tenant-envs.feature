Feature: Pieces API tests for cross-tenant envs

  Background:
    * url baseUrl
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('../reusable/create-order.feature')
    * def createOrderLine = read('../reusable/create-order-line.feature')
    * def createTitle = read('../reusable/create-title.feature')
    * def minimalPiece = read('classpath:samples/mod-orders/pieces/minimal-piece.json')

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
    Given path 'orders/pieces'
    And param createItem = true
    And request minimalPiece
    When method POST
    Then status 201
    And match $.id == '#(pieceId)'
    And match $.poLineId == '#(poLineId)'
    And match $.titleId == '#(titleId)'
    And match $.itemId == '#present'
    And match $.holdingId == '#present'
    And def holdingId = $.holdingId

    # Check the created holding record
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match $.instanceId == '#present'
    And def instanceId = $.instanceId

    # Check the created shared instance
    Given path '/instance-storage/instances', instanceId
    When method GET
    Then status 200

    # Check the created item
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].holdingsRecordId == '#(holdingId)'
    And match $.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item updated in member tenant when updating piece without itemId and deleteHolding=true
    # Get existing holdingId and itemId
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.itemId == '#present'
    And match $.holdingId == '#present'
    And def oldItemId = $.itemId
    And def oldHoldingId = $.holdingId

    # Delete associated item for holding to be deleted
    Given path '/inventory/items', oldItemId
    When method DELETE
    Then status 204

    # Update existing piece
    * set minimalPiece.id = pieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    Given path 'orders/pieces', pieceId
    And param createItem = true
    And param deleteHolding = true
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.id == '#(pieceId)'
    And match $.poLineId == '#(poLineId)'
    And match $.titleId == '#(titleId)'
    And match $.itemId == '#present'
    And match $.holdingId == '#present'
    And match $.itemId != '#(oldItemId)'
    And match $.holdingId != '#(oldHoldingId)'
    And def holdingId = $.holdingId

    # Check the created holding record
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match $.instanceId == '#present'

    # Check the deleted old holding record
    Given path '/holdings-storage/holdings/', oldHoldingId
    When method GET
    Then status 404

    # Check the created item
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].holdingsRecordId == '#(holdingId)'
    And match $.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item after receiving the piece
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
              locationId: "#(globalLocationsId)"
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
    And match $.receivingResults[0].processedSuccessfully == 1

    # Get existing holdingId
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.itemId == '#present'
    And match $.holdingId == '#present'
    And match $.receivingStatus == 'Received'
    And def holdingId = $.holdingId

    # Check the holding record
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match $.instanceId == '#present'

    # Check the item
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].holdingsRecordId == '#(holdingId)'
    And match $.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item updated in member tenant when updating piece with itemId and deleteHolding=false
    # Get existing holdingId and itemId
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.itemId == '#present'
    And match $.holdingId == '#present'
    And def oldItemId = $.itemId
    And def oldHoldingId = $.holdingId

    # Receive piece
    * set minimalPiece.id = pieceId;
    * set minimalPiece.titleId = titleId;
    * set minimalPiece.poLineId = poLineId;
    * set minimalPiece.itemId = oldItemId;
    * remove minimalPiece.locationId;
    Given path 'orders/pieces', pieceId
    And param createItem = true
    And param deleteHolding = false
    And request minimalPiece
    When method PUT
    Then status 204

    # Get updated holdingId and itemId
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.id == '#(pieceId)'
    And match $.poLineId == '#(poLineId)'
    And match $.titleId == '#(titleId)'
    And match $.itemId == '#(oldItemId)'
    And match $.holdingId == '#present'
    And match $.holdingId != '#(oldHoldingId)'
    And def holdingId = $.holdingId

    # Check the updated holding record
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 200
    And match $.instanceId == '#present'

    # Check the old holding record
    Given path '/holdings-storage/holdings/', oldHoldingId
    When method GET
    Then status 200

    # Check the old item
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].holdingsRecordId == '#(holdingId)'
    And match $.items[0].purchaseOrderLineIdentifier == '#(poLineId)'


  Scenario: Check Holding and Item deleted in member tenant when deleting piece
    # Get existing holdingId
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.itemId == '#present'
    And match $.holdingId == '#present'
    And def holdingId = $.holdingId

    # Delete piece
    Given path 'orders/pieces', pieceId
    And param deleteHolding = true
    And request minimalPiece
    When method DELETE
    Then status 204

    # Check the deleted holding record
    Given path '/holdings-storage/holdings/', holdingId
    When method GET
    Then status 404

    # Check the deleted item
    Given path '/inventory/items'
    And param query = 'holdingsRecordId=' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 0