# For FAT-20930, FAT-20931
# https://foliotest.testrail.io/index.php?/cases/view/543756
# https://foliotest.testrail.io/index.php?/cases/view/553012
Feature: Add piece to cancelled order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  @C543756
  @Positive
  # TestRail: https://foliotest.testrail.io/index.php?/cases/view/543756
  Scenario: Add piece to cancelled ongoing order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    # 2. Create an ongoing order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { 'interval': 123, 'isSubscription': false } }

    # 3. Add an electronic line, independent receiving workflow, createInventory: Instance, Holding, Item
    * table locations
      | locationId         | quantity | quantityElectronic |
      | globalLocationsId  | 1        | 1                  |
    * def v = call createElectronicOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', checkinItems: true, createInventory: 'Instance, Holding, Item', locations: '#(locations)' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Cancel the order
    * def v = call cancelOrder { orderId: '#(orderId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Check order is canceled and there is no related piece
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'
    And match $.closeReason.reason == 'Cancelled'

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 7. Add a piece with a different location
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    * def v = call createPieceWithHoldingOrLocation { id: '#(pieceId)', poLineId: '#(poLineId)', titleId: '#(titleId)', format: 'Electronic', useLocationId: true, locationId: '#(globalLocationsId2)', createItem: true }

    # 8. Check expected pieces
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].titleId == titleId
    And match $.pieces[0].receivingStatus == 'Expected'

    # 9. Check inventory
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.holdingsRecords[*].permanentLocationId contains only ['#(globalLocationsId)', '#(globalLocationsId2)']
    * def holdingsForGlobalLocationsId = karate.jsonPath(response, '$.holdingsRecords[?(@.permanentLocationId=="' + globalLocationsId + '")]')[0]

    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def item = $.items[0]
    * match item.status.name == 'Order closed'

    # 10. Check po line
    * configure headers = headersUser
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    And match $.receiptStatus == 'Cancelled'
    And match $.cost.quantityElectronic == 1
    And match $.locations[0].quantityElectronic == 1
    And match $.locations[0].holdingId == holdingsForGlobalLocationsId.id


  @C553012
  @Positive
  # TestRail: https://foliotest.testrail.io/index.php?/cases/view/553012
  Scenario: Receive and unreceive piece for cancelled order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId2 = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    # 2. Create a one-time order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Add an order line, Synchronized order and receipt quantity, createInventory: Instance, Holding, Item
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Cancel the order
    * def v = call cancelOrder { orderId: '#(orderId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Check the title and piece
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].titleId == titleId
    And match $.pieces[0].receivingStatus == 'Expected'
    * def pieceId1 = $.pieces[0].id

    # 7. Get holdings id
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.holdingsRecords[0].permanentLocationId == globalLocationsId
    * def holdingsId1 = $.holdingsRecords[0].id

    # 8. Receive the piece
    * configure headers = headersUser
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId1)",
              itemStatus: "In process",
              holdingId: "#(holdingsId1)",
              displayOnHolding: false,
              displayToPublic: false,
              sequenceNumber: 1
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

    # 9. Add a piece with a different location
    * def v = call createPieceWithHoldingOrLocation { id: '#(pieceId2)', poLineId: '#(poLineId)', titleId: '#(titleId)', useLocationId: true, locationId: '#(globalLocationsId2)', sequenceNumber: 2, createItem: true }

    # 10. Check the number of received and expected pieces
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.pieces[?(@.receivingStatus=='Received')] == '#[1]'
    And match $.pieces[?(@.receivingStatus=='Expected')] == '#[1]'

    # 11. Check the holdings and get their ids
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.holdingsRecords[*].permanentLocationId contains only ['#(globalLocationsId)', '#(globalLocationsId2)']
    * def holdingsId2 = karate.jsonPath(response, '$.holdingsRecords[?(@.permanentLocationId=="' + globalLocationsId2 + '")]')[0].id

    # 12. Check the items statuses
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def firstItem = karate.jsonPath(response, '$.items[?(@.holdingsRecordId=="' + holdingsId1 + '")]')[0]
    * def secondItem = karate.jsonPath(response, '$.items[?(@.holdingsRecordId=="' + holdingsId2 + '")]')[0]
    * match firstItem.status.name == 'In process'
    * match secondItem.status.name == 'Order closed'

    # 13. Check the po line quantity and locations
    * configure headers = headersUser
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    And match $.receiptStatus == 'Cancelled'
    And match $.cost.quantityPhysical == 2
    And match $.locations == '#[2]'
    And match $.locations[*].quantityPhysical == [1, 1]
    And match $.locations[*].holdingId contains only ['#(holdingsId1)', '#(holdingsId2)']

    # 14. Make the expected piece unreceivable
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    * def piece1 = $
    * set piece1.receivingStatus = 'Unreceivable'
    Given path 'orders/pieces', pieceId2
    And request piece1
    When method PUT
    Then status 204

    # 15. Unreceive the first piece
    Given path 'orders/receive'
    And request
    """
    {
      toBeReceived: [
        {
          poLineId: "#(poLineId)",
          received: 1,
          receivedItems: [
            {
              itemStatus: "On order",
              pieceId: "#(pieceId1)",
              displayOnHolding: false,
              displayToPublic: false,
              sequenceNumber: 1
            }
          ]
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200

    # 16. Check the po line quantity and locations
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    And match $.receiptStatus == 'Cancelled'
    And match $.cost.quantityPhysical == 2
    And match $.locations[*].quantityPhysical == [1, 1]
    And match $.locations[*].holdingId contains only ['#(holdingsId1)', '#(holdingsId2)']

    # 17. Check both items have the status "Order closed"
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match each $.items[*].status.name == 'Order closed'

    # 18. Check the order is still closed
    * configure headers = headersUser
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'
