Feature: Verify Bind Piece feature
  1. Bindary active can be set only for Physical or P/E Mix orders with
     Independant workflow when Create Inventory set to “Instance Holding, Item”
  2. Bind endpoint can bind multiple pieces together with creating new item,
     when pieces don not have items associated
  3. Bind endpoint can bind multiple pieces together when pieces has related items associated,
     in this case pieces should be assigned to newly created item,
     statuses of all previously associated items become “Unavailable”,
  4. When pieces have items that open circulation requests -
     these requests should be moved to newly created item
  5. Item can be created in any member tenant

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def createPiece = read('classpath:thunderjet/mod-orders/reusable/create-piece.feature')

    * callonce variables

    * def fundId = call uuid1
    * def budgetId = call uuid2
    * def orderId = call uuid3
    * def poLineId1 = call uuid4
    * def poLineId2 = call uuid5
    * def titleId1 = call uuid6
    * def pieceId1 = callonce uuid7
    * def pieceId2 = callonce uuid8



  Scenario: Bindary active can be set only for Physical or P/E Mix orders with
  Independant workflow when Create Inventory set to “Instance Holding, Item”

    # 1. Create Fund and Budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

    # 2. Create an order
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
      """
      {
        id: '#(orderId)',
        vendor: '#(globalVendorId)',
        orderType: 'One-Time'
      }
      """
    When method POST
    Then status 201

    # 3. Verify error when creating with 'Electronic resources' order format"
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.isBinderActive = true
    * set poLine.orderFormat = 'Electronic Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 401

    # 3. Verify error when creating with 'Electronic resources' order format"
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance'
    * set poLine.isBinderActive = true
    * set poLine.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 401

    # 3. Verify error when creating an order line with createInventory = 'Instance'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance, Holding'
    * set poLine.isBinderActive = true
    * set poLine.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 401

    # 3. Verify success when creating an order line with correct fields and 'Physical Resource' order format
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.isBinderActive = true
    * set poLine.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 200

    # 3. Verify succuess when creating an order line with correct fields and 'P/E Mix' order format
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.isBinderActive = true
    * set poLine.orderFormat = 'P/E Mix'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 200


  Scenario: Bind endpoint can bind multiple pieces together with creating new item,
    when pieces don not have items associated
    # 1. Creating Title and Piece to bind.
    * def v = call createTitle { titleId: "#(titleId1)", poLineId: "#(poLineId)" }
    * def v = call createPiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId1)", titleId: "#(titleId1)" }
    * def v = call createPiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId1)", titleId: "#(titleId1)" }

    # 2. Bind pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.pieceIds[0] = pieceId1
    * set bindPieceCollection.pieceIds[1] = pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    And match response.poLineId == poLineId1
    And match response.pieceIds[*] contains pieceId1
    And match response.pieceIds[*] contains pieceId2
    And match response.itemId != null
    * def bindPieceresult = response

    # 3. Check item details with 'bindPieceCollection' details
    Given path 'item-storage/items', response.itemId
    When method GET
    Then status 200
#    And match response.item.holdingId ==
    And match $.item.status.name == 'On order'
    And match $.item.barcode  == bindPieceCollection.bindItem.barcode
    And match $.item.itemLevelCallNumber == bindPieceCollection.bindItem.callNumber
    And match $.item.permanentLoanTypeId == bindPieceCollection.bindItem.permanentLoanTypeId
    And match $.item.materialTypeId == bindPieceCollection.bindItem.materialTypeId
    And match $.item.purchaseOrderLineIdentifier == bindPieceCollection.bindItem.purchaseOrderLineIdentifier
    And match $.item.chronology == null

    # 4. Title 'bindItemIds' details
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match $.title.bindItemIds[*] contains bindPieceResult.itemId



