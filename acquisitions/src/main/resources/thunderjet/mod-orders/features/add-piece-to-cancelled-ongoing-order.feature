# For FAT-20930, TestRail https://foliotest.testrail.io/index.php?/cases/view/543756
Feature: Add piece to cancelled ongoing order

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

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId)",
      format: "Electronic",
      locationId: "#(globalLocationsId2)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    And param createItem = true
    When method POST
    Then status 201

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
