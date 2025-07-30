@parallel=false
Feature: Verify Bind Piece feature

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

    * def tenantId1 = karate.get('tenantId1', testTenant)
    * def tenantId2 = karate.get('tenantId2', testTenant)

    * configure retry = { count: 5, interval: 1000 }

    * def createCirculationPolicy = read('classpath:thunderjet/mod-orders/reusable/create-circulation-policy.feature')
    * def createCirculationRequest = read('classpath:thunderjet/mod-orders/reusable/create-circulation-request.feature')
    * def createUserGroup = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateGroup')
    * def createUser = read('classpath:thunderjet/mod-orders/reusable/user-init-data.feature@CreateUser')
    * def receivePieceWithHolding = read('classpath:thunderjet/mod-orders/reusable/receive-piece-with-holding.feature')

    * callonce variables

    * def holdingId1 = karate.get('holdingId1', globalHoldingId1)
    * def holdingId2 = karate.get('holdingId2', globalHoldingId2)
    * def holdingId3 = karate.get('holdingId3', globalHoldingId3)

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
    * configure headers = headersUser
    * call createOrder { id: '#(orderId)' }

    # 3. Create patron and user
    * configure headers = headersAdmin
    * def v = call createUserGroup { id: '#(patronId)', group: 'patron', tenantId: '#(tenantId1)' }
    * def v = call createUser { id: '#(userId)', patronId: '#(patronId)'}

    # 4. Setup Circulation Policy
    * call createCirculationPolicy { tenant: '#(tenantId1)' }

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
        holdingId: "#(holdingId1)",
        receivingTenantId: "#(tenantId1)",
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
        holdingId: "#(holdingId2)",
        receivingTenantId: "#(tenantId2)",
        chronology: "222"
      }
      """
    When method POST
    Then status 201


    # 3. Try Binding expected pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindItem.holdingId = holdingId1
    * set bindPieceCollection.bindItem.tenantId = tenantId1
    * set bindPieceCollection.bindPieceIds[0] = pieceId1
    * set bindPieceCollection.bindPieceIds[1] = pieceId2

    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 422
    And match $.errors[*].code contains 'piecesMustHaveReceivedStatus'
    And match $.errors[*].message contains 'All pieces must have received status in order to be bound'


    # 4. Receive both pieceId1 and pieceId2
    * table receivePieceDetails
      | pieceId  | poLineId  | holdingId  | tenantId  |
      | pieceId1 | poLineId1 | holdingId1 | tenantId1 |
      | pieceId2 | poLineId1 | holdingId2 | tenantId2 |
    * def v = call receivePieceWithHolding receivePieceDetails


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
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId
    And match response.bindItemTenantId == tenantId1

    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId
    And match response.bindItemTenantId == tenantId1


    # 7. Check item details with 'bindPieceCollection' details after pieces are bound
    * configure headers = headersAdmin
    Given path 'inventory/tenant-items'
    And request { tenantItemPairs: [ { tenantId: "#(tenantId1)", itemId: "#(newItemId)" } ] }
    When method POST
    Then status 200
    And match response.tenantItems[*].item.holdingsRecordId contains holdingId1
    And match response.tenantItems[*].item.status.name contains 'In process'
    And match response.tenantItems[*].item.barcode contains bindPieceCollection.bindItem.barcode
    And match response.tenantItems[*].item.itemLevelCallNumber contains bindPieceCollection.bindItem.callNumber
    And match response.tenantItems[*].item.permanentLoanTypeId contains bindPieceCollection.bindItem.permanentLoanTypeId
    And match response.tenantItems[*].item.materialTypeId contains bindPieceCollection.bindItem.materialTypeId
    And match response.tenantItems[*].item.purchaseOrderLineIdentifier contains bindPieceCollection.poLineId
    And match response.tenantItems[*].tenantId contains tenantId1


    # 8. Verify Title 'bindItemIds' field
    * configure headers = headersUser
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match response.bindItemIds[*] contains newItemId


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
        holdingId: "#(holdingId1)",
        receivingTenantId: "#(tenantId1)",
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
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(holdingId2)",
        receivingTenantId: "#(tenantId2)",
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
    * configure headers = headersAdmin
    Given path 'inventory/tenant-items'
    And request { tenantItemPairs: [ { tenantId: "#(tenantId1)", itemId: "#(prevItemId1)" }, { tenantId: "#(tenantId2)", itemId: "#(prevItemId2)" } ] }
    When method POST
    Then status 200
    And match response.tenantItems[*].item.status.name contains 'On order'
    And match response.tenantItems[*].tenantId contains any ['#(tenantId1)', '#(tenantId2)']


    # 3. Receive both pieceId1 and pieceId2
    * configure headers = headersUser
    * table receivePieceDetails
      | pieceId          | poLineId  | holdingId  | tenantId  |
      | pieceWithItemId1 | poLineId1 | holdingId1 | tenantId1 |
      | pieceWithItemId2 | poLineId1 | holdingId2 | tenantId2 |
    * def v = call receivePieceWithHolding receivePieceDetails


    # 4. Bind pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '1111110'
    * set bindPieceCollection.bindItem.holdingId = holdingId2
    * set bindPieceCollection.bindItem.tenantId = tenantId2
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
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId
    And match response.bindItemTenantId == tenantId2

    Given path 'orders/pieces', pieceWithItemId2
    When method GET
    Then status 200
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId
    And match response.bindItemTenantId == tenantId2


    # 6. Check previous item1, item2 status of piece after bound
    # Status of item1 and item2 should changed from "On order" to "Unavailable"
    * configure headers = headersAdmin
    Given path 'inventory/tenant-items'
    And request { tenantItemPairs: [ { tenantId: "#(tenantId1)", itemId: "#(prevItemId1)" }, { tenantId: "#(tenantId2)", itemId: "#(prevItemId2)" } ] }
    When method POST
    Then status 200
    And match response.tenantItems[*].item.status.name !contains 'On order'
    And match response.tenantItems[*].item.status.name contains 'Unavailable'
    And match response.tenantItems[*].tenantId contains any ['#(tenantId1)', '#(tenantId2)']


    # 7. Update bounded piece
    # New item fields should not be affected
    * configure headers = headersUser
    Given path 'orders/pieces', pieceWithItemId2
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        poLineId: "#(poLineId1)",
        titleId: "#(titleId)",
        holdingId: "#(holdingId2)",
        receivingTenantId: "#(tenantId2)",
        displayOnHolding: false,
        enumeration: "420",
        chronology: "420",
        supplement: true,
        barcode: "123123123"
      }
      """
    When method PUT
    Then status 204

    * configure headers = headersAdmin
    Given path 'inventory/tenant-items'
    And request { tenantItemPairs: [ { tenantId: "#(tenantId2)", itemId: "#(newItemId)" } ] }
    When method POST
    Then status 200
    And match response.tenantItems[*].item.barcode contains '1111110'
    And match response.tenantItems[*].tenantId contains tenantId2


  Scenario: When pieces have items with open circulation requests, these requests should be moved
  to newly created item when 'Transfer' request action is used
    * def pieceWithItemId1 = call uuid
    * def pieceWithItemId2 = call uuid

    # 1.1 Creating piece with item to bind in Title with 'titleId'
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceWithItemId1)",
        format: "Physical",
        holdingId: "#(holdingId1)",
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

    # 1.2 Creating second piece with item to bind in Title with 'titleId' with different holding 'holdingId3'
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        holdingId: "#(holdingId3)",
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

    * table circulationRequestData
      | id         | requesterId | itemId      | tenantId  |
      | requestId1 | userId      | prevItemId1 | tenantId1 |
      | requestId2 | userId      | prevItemId2 | tenantId1 |
    * def v = call createCirculationRequest circulationRequestData

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


    # 3. Receive both pieceId1 and pieceId2
    * configure headers = headersUser
    * table receivePieceDetails
      | pieceId          | poLineId  | holdingId  |
      | pieceWithItemId1 | poLineId1 | holdingId1 |
      | pieceWithItemId2 | poLineId1 | holdingId3 |
    * def v = call receivePieceWithHolding receivePieceDetails


    # 4.1 Prepare data for binding pieces
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '33333'
    * set bindPieceCollection.bindItem.holdingId = holdingId1
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
        holdingId: "#(holdingId1)",
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

    # 1.2 Creating second piece with item to bind in Title with 'titleId' with different holding 'holdingId3'
    Given path 'orders/pieces'
    And request
      """
      {
        id: "#(pieceWithItemId2)",
        format: "Physical",
        holdingId: "#(holdingId3)",
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

    * table circulationRequestData
      | id         | requesterId | itemId      | tenantId  |
      | requestId1 | userId      | prevItemId1 | tenantId1 |
      | requestId2 | userId      | prevItemId2 | tenantId1 |
    * def v = call createCirculationRequest circulationRequestData

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

    # 3. Receive both pieceId1 and pieceId2
    * configure headers = headersUser
    * table receivePieceDetails
      | pieceId          | poLineId  | holdingId  |
      | pieceWithItemId1 | poLineId1 | holdingId1 |
      | pieceWithItemId2 | poLineId1 | holdingId3 |
    * def v = call receivePieceWithHolding receivePieceDetails


    # 4. Verify SUCCESS Open Requests for item when request action is 'Do Nothing'
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '444444'
    * set bindPieceCollection.bindItem.holdingId = holdingId1
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
      | titleId2 | poLineId2 |
    * def v = call createTitle titleDetails


    # 2. Create two pieces with 'pieceId1' and 'pieceId2'
    * table pieces
      | id       | format     | poLineId  | titleId  | holdingId  | receivingTenantId |
      | pieceId1 | "Physical" | poLineId2 | titleId2 | holdingId1 | tenantId1         |
      | pieceId2 | "Physical" | poLineId2 | titleId2 | holdingId2 | tenantId2         |
    * def v = call createPieceWithHolding pieces


    # 3 Receive both pieceId1 and pieceId2
    * table receivePieceDetails
      | pieceId  | poLineId  | holdingId  | tenantId  |
      | pieceId1 | poLineId2 | holdingId1 | tenantId1 |
      | pieceId2 | poLineId2 | holdingId2 | tenantId2 |
    * def v = call receivePieceWithHolding receivePieceDetails


    # 4. Binding received pieces together for poLineId2 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId2
    * set bindPieceCollection.bindItem.holdingId = holdingId1
    * set bindPieceCollection.bindItem.tenantId = tenantId1
    * set bindPieceCollection.bindItem.barcode = "123321"
    * set bindPieceCollection.bindPieceIds[0] = pieceId1
    * set bindPieceCollection.bindPieceIds[1] = pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    And match response.poLineId == poLineId2
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
    And match response.bindItemTenantId == tenantId1

    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match response.isBound == true
    And match response.itemId == '#present'
    And match response.bindItemId == newItemId
    And match response.bindItemTenantId == tenantId1


    # 6. Check item details with 'bindPieceCollection' details after pieces are bound
    * configure headers = headersAdmin
    Given path 'inventory/tenant-items'
    And request { tenantItemPairs: [ { tenantId: "#(tenantId1)", itemId: "#(newItemId)" } ] }
    When method POST
    Then status 200
    And match response.tenantItems[*].item.holdingsRecordId contains holdingId1
    And match response.tenantItems[*].item.status.name contains 'In process'
    And match response.tenantItems[*].item.barcode contains bindPieceCollection.bindItem.barcode
    And match response.tenantItems[*].tenantId contains tenantId1


    # 7. Verify Title 'bindItemIds' field
    * configure headers = headersUser
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
    And match response.bindItemTenantId == '#notpresent'


    # 9. Verify Title bindItemIds is not empty as piece2 is still bound
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
    And match response.bindItemTenantId == '#notpresent'


    # 11. Verify Title bindItemIds is empty as no piece is bound
    Given path 'orders/titles', titleId2
    When method GET
    Then status 200
    And match response.bindItemIds == '#[0]'