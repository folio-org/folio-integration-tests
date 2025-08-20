# For FAT-21349, https://foliotest.testrail.io/index.php?/cases/view/358972
Feature: Create Order Check Items

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Create Order And Check Item Statuses
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)", name: "Test Fund For Items" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 1000, fundId: "#(fundId)", status: "Active" }

    # 2. Create Order And Order Line
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)" }

    # 3. Verify Order Line Is Physical Resource
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.orderFormat == 'Physical Resource'
    And match response.cost.quantityPhysical == 1

    # 4. Open Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Get The Order Line To Retrieve Instance And Holdings Information
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    # 6. Get Items For This Holding
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def itemId = response.items[0].id

    # 7. Verify Item Status
    Given path 'inventory/items', itemId
    When method GET
    Then status 200
    And match response.status.name == 'On order'
    And match response.holdingsRecordId == holdingId

    # 8. Get Piece And Verify It Is Created With Expected Status
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def pieces = response.pieces
    And match pieces == '#[1]'
    And match each pieces[*].receivingStatus == 'Expected'
    * def pieceId = pieces[0].id
    * def pieceResponse = pieces[0]

    # 9. Update Piece To Set CreateItem To True
    Given path 'orders/pieces', pieceId
    And param createItem = true
    And request pieceResponse
    When method PUT
    Then status 204
    * call pause 10000

    # 10. Receive The Item To Change Status
    * def v = call receivePieceWithHolding { pieceId: "#(pieceId)", poLineId: "#(poLineId)", holdingId: "#(holdingId)", createItem: false }

    # 11. Verify Piece Status Is Set To Received
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.pieces != null && response.pieces.length > 0 && response.pieces[0].receivingStatus == 'Received'
    When method GET
    Then status 200

    # 12. Verify Item Status Changed To In Process After Receiving
    * configure headers = headersAdmin
    Given path 'inventory/items', itemId
    And retry until response.status.name == 'In process' && response.holdingsRecordId == holdingId
    When method GET
    Then status 200
