Feature: Verify Bind Piece feature

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser
    * configure retry = { count: 5, interval: 1000 }

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def createPiece = read('classpath:thunderjet/mod-orders/reusable/create-piece.feature')
    * def createCirculationPolicy = read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature')
    * def createCirculationRequest = read('classpath:thunderjet/mod-orders/reusable/create-circulation-request.feature')
    * def createUserGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateGroup')
    * def createUser = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateUser')

    * callonce variables

    * def budgetId = call uuid
    * def fundId = callonce uuid1
    * def userId = callonce uuid2
    * def patronId = callonce uuid3
    * def orderId = callonce uuid4
    * def poLineId1 = callonce uuid5
    * def poLineId2 = callonce uuid6
    * def titleId = callonce uuid7

  @Setup
  Scenario: Create Finance, Budget, and Order, User, and Patron, and Circulation Policy
    * configure headers = headersAdmin

    # 1. Create Fund and Budget
    * def v = call createFund { 'id': '#(fundId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

    # 2. Create an order
    * call createOrder { id: '#(orderId)' }

    # 3. Create patron and user
    * def v = call createUserGroup {id: '#(patronId)'}
    * def v = call createUser { id: '#(userId)', patronId: '#(patronId)'}

    # 4. Setup Circulation Policy
    * call createCirculationPolicy

    * configure headers = headersUser

  @Negative
  Scenario: Verify ERROR cases for Bindary active can be set only for Physical or P/E Mix orders with
  Independant workflow when Create Inventory set to “Instance Holding, Item”

    # 1. Set required fields for order line to verify scenarios for creation of orderLines
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = null
    * set poLine.receiptStatus = null


    # 2. Verify ERROR when creating with 'Electronic resources' order format
    * set poLine.cost.quantityPhysical = 0
    * set poLine.cost.quantityElectronic = 1
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.checkinItems = true
    * set poLine.details.isBinderyActive = true
    * set poLine.orderFormat = 'Electronic Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match $.errors[*].code contains 'orderFormatIncorrectForBindaryActive'
    And match $.errors[*].message contains "When PoLine is bindery active, its format must be 'P/E Mix' or 'Physical Resource'"


    # 3. Verify ERROR when creating with createInventory = 'Instance'
    * set poLine.cost.quantityPhysical = 1
    * set poLine.cost.quantityElectronic = 0
    * set poLine.physical.createInventory = 'Instance'
    * set poLine.checkinItems = true
    * set poLine.details.isBinderyActive = true
    * set poLine.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match $.errors[*].code contains 'createInventoryIncorrectForBindaryActive'
    And match $.errors[*].message contains "When PoLine is bindery active, Create Inventory must be 'Instance, Holding, Item'"


    # 4. Verify ERROR when creating an order line with createInventory = 'Instance, Holding'
    * set poLine.cost.quantityPhysical = 1
    * set poLine.cost.quantityElectronic = 0
    * set poLine.physical.createInventory = 'Instance, Holding'
    * set poLine.checkinItems = true
    * set poLine.details.isBinderyActive = true
    * set poLine.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match $.errors[*].code contains 'createInventoryIncorrectForBindaryActive'
    And match $.errors[*].message contains "When PoLine is bindery active, Create Inventory must be 'Instance, Holding, Item'"


    # 5. Verify ERROR when creating an order line without 'Independent order and receipt quantity' receiving status workflow
    * set poLine.cost.quantityPhysical = 1
    * set poLine.cost.quantityElectronic = 0
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.checkinItems = false
    * set poLine.details.isBinderyActive = true
    * set poLine.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match $.errors[*].code contains 'receivingWorkflowIncorrectForBindaryActive'
    And match $.errors[*].message contains "When PoLine is bindery active, its receiving workflow must be set to 'Independent order and receipt quantity'"

  @Positive
  Scenario: Verify SUCCESS case for Bindary active can be set only for Physical or P/E Mix orders with
  Independant workflow when Create Inventory set to “Instance Holding, Item”

    # 1. Verify SUCCESS when creating an order line with correct fields and 'Physical Resource' order format
    * def poLine1 = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine1.id = poLineId1
    * set poLine1.purchaseOrderId = orderId
    * set poLine1.fundDistribution[0].fundId = fundId
    * set poLine1.fundDistribution[0].code = fundId
    * set poLine1.cost.listUnitPrice = 1.0
    * set poLine1.cost.poLineEstimatedPrice = 1.0
    * set poLine1.cost.quantityPhysical = 1
    * set poLine1.isPackage = true
    * set poLine1.physical.createInventory = 'Instance, Holding, Item'
    * set poLine1.checkinItems = true
    * set poLine1.details.isBinderyActive = true
    * set poLine1.orderFormat = 'Physical Resource'

    Given path 'orders/order-lines'
    And request poLine1
    When method POST
    Then status 201


    # 2. Verify SUCCESS when creating an order line with correct fields and 'P/E Mix' order format
    * def poLine2 = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine2.id = poLineId2
    * set poLine2.purchaseOrderId = orderId
    * set poLine2.fundDistribution[0].fundId = fundId
    * set poLine2.fundDistribution[0].code = fundId
    * set poLine2.isPackage = true
    * set poLine2.physical.createInventory = 'Instance, Holding, Item'
    * set poLine2.checkinItems = true
    * set poLine2.details.isBinderyActive = true
    * set poLine2.orderFormat = 'P/E Mix'

    Given path 'orders/order-lines'
    And request poLine2
    When method POST
    Then status 201


  @Positive
  Scenario: Verify piece, title and new item details after bind endpoint bind multiple valid pieces together with creating new items

    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

    # 1. Creating Title
    * call createTitle { titleId: "#(titleId)", poLineId: "#(poLineId1)" }


    # 2. Create two pieces with 'pieceId1' and 'pieceId2' for titleId
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceId1)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(globalHoldingId1)",
        chronology: "111"
      }
      """
    When method POST
    Then status 201

    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceId2)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(globalHoldingId2)",
        chronology: "222"
      }
      """
    When method POST
    Then status 201


    # 3. Try Binding expected pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
    * set bindPieceCollection.bindPieceIds[0] = pieceId1
    * set bindPieceCollection.bindPieceIds[1] = pieceId2

    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 422
    And match $.errors[*].code contains 'piecesMustHaveReceivedStatus'
    And match $.errors[*].message contains 'All pieces must have received status in order to be bound'


    # 4. Receive both pieceId1 and pieceId2
    * def receivePiece = read('classpath:thunderjet/mod-orders/reusable/receive-piece.feature')
    * def v = call receivePiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId1)" }
    * def v = call receivePiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId1)" }


    # 5. Binding received pieces together for poLineId1 with pieceId1 and pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    And match response.poLineId == poLineId1
    And match response.boundPieceIds[*] contains pieceId1
    And match response.boundPieceIds[*] contains pieceId2
    And match response.itemId != null
    * def newItemId = response.itemId


    # 6. Check 'isBound=true' and 'itemId' flags after pieces are bound
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == newItemId

    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == newItemId


    # 7. Check item details with 'bindPieceCollection' details after pieces are bound
    Given path 'item-storage/items', newItemId
    When method GET
    Then status 200
    And match $.holdingsRecordId == globalHoldingId1
    And match $.status.name == 'On order'
    And match $.barcode == bindPieceCollection.bindItem.barcode
    And match $.itemLevelCallNumber == bindPieceCollection.bindItem.callNumber
    And match $.permanentLoanTypeId == bindPieceCollection.bindItem.permanentLoanTypeId
    And match $.materialTypeId == bindPieceCollection.bindItem.materialTypeId
    And match $.purchaseOrderLineIdentifier == bindPieceCollection.poLineId
    And match $.chronology == '#notpresent'


    # 8. Verify Title 'bindItemIds' field
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match $.bindItemIds[*] contains newItemId


  @Positive
  Scenario: Verify Bind endpoint can bind multiple pieces together when pieces has related items associated,
  in this case pieces should be assigned to newly created item,
  statuses of all previously associated items become "Unavailable",
  updating bounded piece should not affect the new item

    * def pieceWithItemId1 = call uuid
    * def pieceWithItemId2 = call uuid

    # 1.1 Creating Piece with Item to bind in Title with 'titleId'"
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceWithItemId1)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(globalHoldingId1)",
        displayOnHolding: false,
        enumeration: "111",
        chronology: "111",
        supplement: true,
      }
      """
    And param createItem = true
    When method POST
    Then status 201
    * def prevItemId1 = response.itemId

    # 1.2 Creating Second Piece with Item to bind in Title with 'titleId'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(globalHoldingId1)",
        displayOnHolding: false,
        enumeration: "420",
        chronology: "420",
        supplement: true,
      }
      """
    And param createItem = true
    When method POST
    Then status 201
    * def prevItemId2 = response.itemId


    # 2. Check previous item details of piece before bound
    Given path 'item-storage/items', prevItemId1
    When method GET
    Then status 200
    And match $.status.name == 'On order'

    Given path 'item-storage/items', prevItemId2
    When method GET
    Then status 200
    And match $.status.name == 'On order'


    # 3. Bind pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '1111110'
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId2
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindPieceIds[0] = pieceWithItemId1
    * set bindPieceCollection.bindPieceIds[1] = pieceWithItemId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    * def newItemId = response.itemId

    # 4. Check 'isBound=true' and 'itemId' flags after pieces are bound
    Given path 'orders/pieces', pieceWithItemId1
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == newItemId

    Given path 'orders/pieces', pieceWithItemId2
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == newItemId


    # 5. Check previous item1, item2 status of piece after bound
    # Status of item1 and item2 should changed from "On order" to "Unavailable"
    Given path 'item-storage/items', prevItemId1
    When method GET
    Then status 200
    And match $.status.name == 'Unavailable'

    Given path 'item-storage/items', prevItemId2
    When method GET
    Then status 200
    And match $.status.name == 'Unavailable'


    # 6. Update bounded piece
    # New item fields should not be affected
    Given path 'orders/pieces', pieceWithItemId2
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(globalHoldingId1)",
        displayOnHolding: false,
        enumeration: "420",
        chronology: "420",
        supplement: true,
        barcode: "123123123"
      }
      """
    When method PUT
    Then status 204

    Given path 'item-storage/items', newItemId
    When method GET
    Then status 200
    And match $.status.barcode == '1111110'


  Scenario: When pieces have items with open circulation requests, these requests should be moved
  to newly created item when 'Transfer' request action is used
    * def pieceWithItemId1 = call uuid
    * def pieceWithItemId2 = call uuid

    # 1.1 Creating piece with item to bind in Title with 'titleId'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId1)",
        format: "Physical",
        holdingId: "#(globalHoldingId1)",
        poLineId: "#(poLineId1)",
        displayOnHolding: false,
        enumeration: "333",
        chronology: "333",
        supplement: true,
        titleId: "#(titleId)"
      }
      """
    And param createItem = true
    When method POST
    Then status 201
    * def prevItemId1 = response.itemId

    # 1.2 Creating second piece with item to bind in Title with 'titleId' with different holding 'globalHoldingId2'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        holdingId: "#(globalHoldingId2)",
        poLineId: "#(poLineId1)",
        displayOnHolding: false,
        enumeration: "444",
        chronology: "444",
        supplement: true,
        titleId: "#(titleId)"
      }
      """
    And param createItem = true
    When method POST
    Then status 201
    * def prevItemId2 = response.itemId


    # 2.1 Configure headersAdmin for circulation requests
    * configure headers = headersAdmin

    # 2.2 Create Circulation Requests
    * def requestId1 = call uuid
    * def requestId2 = call uuid

    * call createCirculationRequest {id: "#(requestId1)", requesterId: "#(userId)", itemId: "#(prevItemId1)"}
    * call pause 1000
    * call createCirculationRequest {id: "#(requestId2)", requesterId: "#(userId)", itemId: "#(prevItemId2)"}

    # 2.3 Verify circulation request with previous item details
    Given path 'circulation', 'requests', requestId1
    When method GET
    Then status 200
    And match $.itemId == prevItemId1

    # 2.4 Verify circulation request with previous item details
    Given path 'circulation', 'requests', requestId2
    When method GET
    Then status 200
    And match $.itemId == prevItemId2

    * configure headers = headersUser


    # 3.1 Prepare data for binding pieces
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '33333'
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindPieceIds[0] = pieceWithItemId1
    * set bindPieceCollection.bindPieceIds[1] = pieceWithItemId2

    # 3.2 Verify ERROR Open Requests for item when Bind pieces together for poLineId1 with pieceId1 and pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 422
    And match $.errors[*].code contains 'requestsActionRequired'

    # 3.3 Verify SUCCESS Open Requests for item when request action is 'Transfer'
    * set bindPieceCollection.requestsAction = "Transfer"

    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    * def newItemId = response.itemId


    # 4.1 Check oldest circulation request with 'newItemId' details
    * configure headers = headersAdmin
    Given path 'circulation/requests', requestId1
    And retry until response.itemId == newItemId
    When method GET
    Then status 200
    And match response.itemId == newItemId

    # 4.2 Check newer circulation request with 'Closed - Cancelled' status
    Given path 'circulation/requests', requestId2
    And retry until response.status == 'Closed - Cancelled'
    When method GET
    Then status 200
    And match response.status == 'Closed - Cancelled'
    * configure headers = headersUser

  @Positive
  Scenario: When pieces have items with open circulation requests, these requests should not be moved
  to newly created item when 'Do Nothing' request action is used
    * def pieceWithItemId1 = call uuid
    * def pieceWithItemId2 = call uuid

    # 1.1 Creating piece with item to bind in Title with 'titleId'
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceWithItemId1)",
        format: "Physical",
        holdingId: "#(globalHoldingId1)",
        poLineId: "#(poLineId1)",
        displayOnHolding: false,
        enumeration: "333",
        chronology: "333",
        supplement: true,
        titleId: "#(titleId)"
      }
      """
    And param createItem = true
    When method POST
    Then status 201
    * def prevItemId1 = response.itemId

    # 1.2 Creating second piece with item to bind in Title with 'titleId' with different holding 'globalHoldingId2'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        holdingId: "#(globalHoldingId2)",
        poLineId: "#(poLineId1)",
        displayOnHolding: false,
        enumeration: "444",
        chronology: "444",
        supplement: true,
        titleId: "#(titleId)"
      }
      """
    And param createItem = true
    When method POST
    Then status 201
    * def prevItemId2 = response.itemId


    # 2. Configure headersAdmin for circulation requests
    * configure headers = headersAdmin

    # 2.1 Create Circulation Requests
    * def requestId1 = call uuid
    * def requestId2 = call uuid

    * call createCirculationRequest {id: "#(requestId1)", requesterId: "#(userId)", itemId: "#(prevItemId1)"}
    * call createCirculationRequest {id: "#(requestId2)", requesterId: "#(userId)", itemId: "#(prevItemId2)"}

    # 2.2 Verify circulation request with previous item details
    Given path 'circulation', 'requests', requestId1
    When method GET
    Then status 200
    And match $.itemId == prevItemId1

    # 2.3 Verify circulation request with previous item details
    Given path 'circulation', 'requests', requestId2
    When method GET
    Then status 200
    And match $.itemId == prevItemId2

    * configure headers = headersUser


    # 3. Verify SUCCESS Open Requests for item when request action is 'Do Nothing'
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '444444'
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindPieceIds[0] = pieceWithItemId1
    * set bindPieceCollection.bindPieceIds[1] = pieceWithItemId2

    * set bindPieceCollection.requestsAction = "Do Nothing"

    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200


    # 4. Check both circulation request have not been moved
    * configure headers = headersAdmin
    * call pause 1000
    Given path 'circulation/requests', requestId1
    When method GET
    Then status 200
    And match response.itemId == prevItemId1

    Given path 'circulation/requests', requestId2
    When method GET
    Then status 200
    And match response.itemId == prevItemId2
