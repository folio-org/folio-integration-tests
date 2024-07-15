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
    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def createPieceWithHolding = read('classpath:thunderjet/mod-orders/reusable/create-piece-with-holding.feature')
    * def createCirculationPolicy = read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature')
    * def createCirculationRequest = read('classpath:thunderjet/mod-orders/reusable/create-circulation-request.feature')
    * def createUserGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateGroup')
    * def createUser = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateUser')
    * def receivePiece = read('classpath:thunderjet/mod-orders/reusable/receive-piece.feature')

    * callonce variables

    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid1
    * def budgetId = call uuid2
    * def fundId = callonce uuid3
    * def userId = callonce uuid4
    * def patronId = callonce uuid5
    * def orderId = callonce uuid6
    * def poLineId1 = callonce uuid7
    * def poLineId2 = callonce uuid8
    * def titleId = callonce uuid9

  @Setup
  Scenario: Create Finance, Budget, and Order, User, and Patron, and Circulation Policy
    * configure headers = headersAdmin

    # 1. Create Fund and Budget
    * def periodStart = fromYear + '-01-01T00:00:00Z'
    * def periodEnd = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'TESTFY0369', periodStart: '#(periodStart)', periodEnd: '#(periodEnd)', series: 'TESTFY' }
    * def v = call createLedger { 'id': '#(ledgerId)'}
    * def v = call createFund { 'id': '#(fundId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

    # 2. Create an order
    * call createOrder { id: '#(orderId)' }

    # 3. Create patron and user
    * def v = call createUserGroup { id: '#(patronId)' }
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


    # 6. Check 'isBound=true' and 'bindItemId' fields after pieces are bound
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == '#present'
    And match $.bindItemId == newItemId

    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == '#present'
    And match $.bindItemId == newItemId


    # 7. Check item details with 'bindPieceCollection' details after pieces are bound
    Given path 'item-storage/items', newItemId
    When method GET
    Then status 200
    And match $.holdingsRecordId == globalHoldingId1
    And match $.status.name == 'In process'
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


    # 3. Receive both pieceId1 and pieceId2
    * def v = call receivePiece { pieceId: "#(pieceWithItemId1)", poLineId: "#(poLineId1)" }
    * def v = call receivePiece { pieceId: "#(pieceWithItemId2)", poLineId: "#(poLineId1)" }


    # 4. Bind pieces together for poLineId1 with pieceId1 and pieceId2
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

    # 5. Check 'isBound=true' and 'bindItemId' fields after pieces are bound
    Given path 'orders/pieces', pieceWithItemId1
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == '#present'
    And match $.bindItemId == newItemId

    Given path 'orders/pieces', pieceWithItemId2
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.itemId == '#present'
    And match $.bindItemId == newItemId


    # 6. Check previous item1, item2 status of piece after bound
    # Status of item1 and item2 should changed from "On order" to "Unavailable"
    Given path 'item-storage/items', prevItemId1
    When method GET
    Then status 200
    And match $.status.name == 'Unavailable'

    Given path 'item-storage/items', prevItemId2
    When method GET
    Then status 200
    And match $.status.name == 'Unavailable'


    # 7. Update bounded piece
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
    And match $.barcode == '1111110'


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


    # 3. Receive both pieceId1 and pieceId2
    * def v = call receivePiece { pieceId: "#(pieceWithItemId1)", poLineId: "#(poLineId1)" }
    * def v = call receivePiece { pieceId: "#(pieceWithItemId2)", poLineId: "#(poLineId1)" }


    # 4.1 Prepare data for binding pieces
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '33333'
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindPieceIds[0] = pieceWithItemId1
    * set bindPieceCollection.bindPieceIds[1] = pieceWithItemId2

    # 4.2 Verify ERROR Open Requests for item when Bind pieces together for poLineId1 with pieceId1 and pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 422
    And match $.errors[*].code contains 'requestsActionRequired'

    # 4.3 Verify SUCCESS Open Requests for item when request action is 'Transfer'
    * set bindPieceCollection.requestsAction = "Transfer"

    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    * def newItemId = response.itemId


    # 5. Verify circulation requests details after transferAction='Transfer'
    # 5.1 First (oldest) request should be moved to 'newItemId'
    * configure headers = headersAdmin
    Given path 'circulation/requests', requestId1
    And retry until response.itemId == newItemId
    When method GET
    Then status 200
    And match response.itemId == newItemId

    # 5.2 Second (other requests) should be changed 'Closed - Cancelled' status
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


    # 3. Receive both pieceId1 and pieceId2
    * def v = call receivePiece { pieceId: "#(pieceWithItemId1)", poLineId: "#(poLineId1)" }
    * def v = call receivePiece { pieceId: "#(pieceWithItemId2)", poLineId: "#(poLineId1)" }


    # 4. Verify SUCCESS Open Requests for item when request action is 'Do Nothing'
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


    # 5. Check both circulation request have not been moved
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


  @Positive
  Scenario: Bind pieces and remove binding one by one, verify piece bindItemId and isBound attributes, verify title bindItemIds
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def titleId2 = call uuid


    # 1. Creating Title
    * table titleDetails
      | titleId  | poLineId  |
      | titleId2 | poLineId1 |
    * call createTitle titleDetails


    # 2. Create two pieces with 'pieceId1' and 'pieceId2'
    * table pieces
      | id       | format     | poLineId  | titleId  | holdingId        |
      | pieceId1 | "Physical" | poLineId1 | titleId2 | globalHoldingId1 |
      | pieceId2 | "Physical" | poLineId1 | titleId2 | globalHoldingId2 |
    * def v = call createPieceWithHolding pieces


    # 3 Receive both pieceId1 and pieceId2
    * table receivePiece1
      | pieceId  | poLineId  |
      | pieceId1 | poLineId1 |
    * def v = call receivePiece receivePiece1
    * table receivePiece2
      | pieceId  | poLineId  |
      | pieceId2 | poLineId1 |
    * def v = call receivePiece receivePiece2


    # 4. Binding received pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
    * set bindPieceCollection.bindItem.barcode = "123321"
    * set bindPieceCollection.bindPieceIds[0] = pieceId1
    * set bindPieceCollection.bindPieceIds[1] = pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    And match response.poLineId == poLineId1
    And match response.boundPieceIds[*] contains pieceId1
    And match response.boundPieceIds[*] contains pieceId2
    And match response.itemId != null
    * def newItemId = response.itemId


    # 5. Check 'isBound=true' and 'bindItemId' fields after pieces are bound
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId

    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId


    # 6. Check item details with 'bindPieceCollection' details after pieces are bound
    Given path 'item-storage/items', newItemId
    When method GET
    Then status 200
    And match response.holdingsRecordId == globalHoldingId1
    And match response.status.name == 'In process'
    And match response.barcode == bindPieceCollection.bindItem.barcode
    And match response.itemLevelCallNumber == bindPieceCollection.bindItem.callNumber
    And match response.permanentLoanTypeId == bindPieceCollection.bindItem.permanentLoanTypeId
    And match response.materialTypeId == bindPieceCollection.bindItem.materialTypeId
    And match response.purchaseOrderLineIdentifier == bindPieceCollection.poLineId
    And match response.chronology == '#notpresent'


    # 7. Verify Title 'bindItemIds' field
    Given path 'orders/titles', titleId2
    When method GET
    Then status 200
    And match response.bindItemIds[*] contains newItemId


    # 8.1 Remove binding for piece1
    Given path 'orders/bind-pieces', pieceId1
    When method DELETE
    Then status 204

    # 8.2 Verify Piece 1 is not bound
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match response.isBound == false
    And match response.itemId == '#present'
    And match response.bindItemId == '#notpresent'


    # 9. Verify Title bindItemIds it not empty as piece2 is still bound
    Given path 'orders/titles', titleId2
    When method GET
    Then status 200
    And match response.bindItemIds == '#[1]'
    And match response.bindItemIds[*] contains newItemId


    # 10.1 Remove binding for piece1
    Given path 'orders/bind-pieces', pieceId2
    When method DELETE
    Then status 204

    # 10.2 Verify Piece 1 is not bound
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match response.isBound == false
    And match response.itemId == '#present'
    And match response.bindItemId == '#notpresent'


    # 11. Verify Title bindItemIds it empty as no piece is bound
    Given path 'orders/titles', titleId2
    When method GET
    Then status 200
    And match response.bindItemIds == '#[0]'