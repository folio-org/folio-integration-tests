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

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def createPiece = read('classpath:thunderjet/mod-orders/reusable/create-piece.feature')
    * def createInstance = read('classpath:thunderjet/mod-orders/reusable/create-instance.feature')
    * def createHolding = read('classpath:thunderjet/mod-orders/reusable/create-holdings.feature')

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = callonce uuid1
    * def poLineId1 = callonce uuid2
    * def poLineId2 = callonce uuid3
    * def titleId = callonce uuid4

  @Setup
  Scenario: Create Finance, Budget, and Order

    # 1. Create Fund and Budget
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)'}
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}


    # 2. Create an order
    * configure headers = headersUser
    * call createOrder { id: '#(orderId)' }


  @Negative
  Scenario: Verify ERROR cases for Bindary active can be set only for Physical or P/E Mix orders with
  Independant workflow when Create Inventory set to “Instance Holding, Item”

    # 3. Set required fields for order line to verify scenarios for creation of orderLines
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = null
    * set poLine.receiptStatus = null

    # 4.1 Verify ERROR when creating with 'Electronic resources' order format
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

    # 4.2 Verify ERROR when creating with createInventory = 'Instance'
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

    # 4.3 Verify ERROR when creating an order line with createInventory = 'Instance, Holding'
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

    # 4.3 Verify ERROR when creating an order line with receiving workflow to Independent
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

    # 1.1 Verify SUCCESS when creating an order line with correct fields and 'Physical Resource' order format
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

    # 1.2 Verify SUCCESS when creating an order line with correct fields and 'P/E Mix' order format
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
  Scenario: Bind endpoint can bind multiple pieces together with creating new item,
  when pieces don not have items associated
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

    # 1. Creating Title
    * call createTitle { titleId: "#(titleId)", poLineId: "#(poLineId1)" }

    # 2. Create two pieces with pieceId1 and pieceId2 for titleId
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


    # 3. Bind pieces together for poLineId1 with pieceId1 and pieceId2
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
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


    # 3. Check item details with 'bindPieceCollection' details
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


    # 4. Verfy Title 'bindItemIds' field
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match $.bindItemIds[*] contains newItemId


  @Positive
  Scenario: Verify previous item status after bind pieces together with creating new item
  when pieces don not have items associated
    * def pieceWithItemId1 = call uuid
    * def pieceWithItemId2 = call uuid

    # 1.1 Creating Piece with Item to bind in Title with 'titleId'
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

    # 1.2 Creating Piece with Item to bind in Title with 'titleId'
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


    # 2.1 Check previous item1 details of piece before bound
    Given path 'item-storage/items', prevItemId1
    When method GET
    Then status 200
    And match $.status.name == 'On order'

    # 2.2 Check previous item2 details of piece before bound
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
    And match $.poLineId == poLineId1
    And match $.boundPieceIds[*] contains pieceWithItemId1
    And match $.boundPieceIds[*] contains pieceWithItemId2
    And match $.itemId != null

    # 4.1 Check previous item1 details of piece after bound
    Given path 'item-storage/items', prevItemId1
    When method GET
    Then status 200
    And match $.status.name == 'Unavailable'

    # 4.2 Check previous item2 details of piece after bound
    Given path 'item-storage/items', prevItemId2
    When method GET
    Then status 200
    And match $.status.name == 'Unavailable'


  Scenario: When pieces have items that open circulation requests - these requests should be moved to newly created item
    * def pieceWithItemId3 = call uuid
    * def pieceWithItemId4 = call uuid
    * def itemBarcode = '777'
    * def userId = call uuid

    # 1.1 Creating Piece with Item to bind in Title with 'titleId'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId3)",
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

    # 1.2 Creating Piece with Item to bind in Title with 'titleId'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
      """
      {
        id: "#(pieceWithItemId4)",
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


    # 2. Create circulation request
    * configure headers = headersAdmin

    # Create Patron Group & User
    * def patronId = call uuid

    Given path 'groups'
    And request
      """
      {
        "group": "lib",
        "desc": "For Testing",
        "expirationOffsetInDays": "60",
        "id": "#(patronId)"
      }
      """
    When method POST
    Then status 201

    * def userBarcode = '401'
    * def userName = 'sally'
    * def userId = call uuid
    * def externalId = call uuid

    Given path 'users'
    And request
      """
      {
        "active": "true",
        "personal": {
          "firstName": "Elon",
          "preferredContactTypeId": "002",
          "lastName": "Musk",
          "preferredFirstName": "Snap",
          "email": "test@mail.com"
        },
        "patronGroup": "#(patronId)",
        "barcode": "#(userBarcode)",
        "id": "#(userId)",
        "username": "#(userName)",
        "departments": [],
        "externalSystemId": "#(externalId)"
      }
      """
    When method POST
    Then status 201

    * def requestPolicyId = call uuid

    Given path 'request-policy-storage/request-policies'
    And request
      """
      {
        "id": "#(requestPolicyId)",
        "name": "Example Request Policy",
        "description": "Description of request policy",
        "requestTypes": [
          "Hold", "Page", "Recall"
        ]
      }
      """
    When method POST
    Then status 201

    #  Scenario: Create loan policy
    Given path 'loan-policy-storage/loan-policies'
    And request
      """
      {
        "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
        "name": "loanPolicyName",
        "loanable": true,
        "loansPolicy": {
          "profileId": "Rolling",
          "period": {
            "duration": 1,
            "intervalId": "Hours"
          },
          "closedLibraryDueDateManagementId": "CURRENT_DUE_DATE_TIME"
        },
        "renewable": true,
        "renewalsPolicy": {
          "unlimited": false,
          "numberAllowed": 3.0,
          "renewFromId": "SYSTEM_DATE",
          "differentPeriod": false
        }
      }
      """
    When method POST
    Then status 201

    #  @CreateRequestPolicy
    #  Scenario: Create request policy
    Given path 'request-policy-storage/request-policies'
    And request
      """
      {
        "id": "d9cd0bed-1b49-4b5e-a7bd-064b8d177231",
        "name": "requestPolicyName",
        "description": "Allow all request types",
        "requestTypes": [
          "Hold",
          "Page",
          "Recall"
        ]
      }
      """
    When method POST
    Then status 201

    #  @CreateNoticePolicy
    #  Scenario: Create notice policy
    Given path 'patron-notice-policy-storage/patron-notice-policies'
    And request
      """
      {
        "id": "122b3d2b-4788-4f1e-9117-56daa91cb75c",
        "name": "patronNoticePolicyName",
        "description": "A basic notice policy that does not define any notices",
        "active": true,
        "loanNotices": [],
        "feeFineNotices": [],
        "requestNotices": []
      }
      """
    When method POST
    Then status 201

    #  @CreateOverdueFinePolicy
    #  Scenario: Create overdue fine policy
    Given path 'overdue-fines-policies'
    And request
      """
      {
        "name": "overdueFinePolicyName",
        "description": "Test overdue fine policy",
        "countClosed": true,
        "maxOverdueFine": 0.0,
        "forgiveOverdueFine": true,
        "gracePeriodRecall": true,
        "maxOverdueRecallFine": 0.0,
        "id": "cd3f6cac-fa17-4079-9fae-2fb28e521412"
      }
      """
    When method POST
    Then status 201

    #  @CreateLostItemFeesPolicy
    Given path 'lost-item-fees-policies'
    And request
      """
      {
        "name": "lostItemFeesPolicyName",
        "description": "Test lost item fee policy",
        "chargeAmountItem": {
          "chargeType": "actualCost",
          "amount": 0.0
        },
        "lostItemProcessingFee": 0.0,
        "chargeAmountItemPatron": true,
        "chargeAmountItemSystem": true,
        "lostItemChargeFeeFine": {
          "duration": 2,
          "intervalId": "Days"
        },
        "returnedLostItemProcessingFee": true,
        "replacedLostItemProcessingFee": true,
        "replacementProcessingFee": 0.0,
        "replacementAllowed": true,
        "lostItemReturned": "Charge",
        "id": "ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
      }
      """
    When method POST
    Then status 201

    # Update circulation rules
    Given path 'circulation/rules'
    And request
      """
      {
        "id": "1721f01b-e69d-5c4c-5df2-523428a04c55",
        "rulesAsText": "priority: t, s, c, b, a, m, g\nfallback-policy: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709 \nm 1a54b431-2e4f-452d-9cae-9cee66c9a892: l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r d9cd0bed-1b49-4b5e-a7bd-064b8d177231 n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709"
      }
      """
    When method PUT
    Then status 204

    * def requestId1 = call uuid
    * def requestId2 = call uuid

    Given path 'circulation/requests'
    And request
      """
      {
        "id": "#(requestId1)",
        "requestLevel": "Item",
        "requestType": "Hold",
        "requestDate": "2023-03-23T11:04:25.000+00:00",
        "holdingsRecordId": "#(globalHoldingId1)",
        "requesterId": "#(userId)",
        "instanceId": "#(globalInstanceId1)",
        "itemId": "#(prevItemId1)",
        "fulfillmentPreference": "Delivery"
      }
      """
    When method POST
    Then status 201

    Given path 'circulation/requests'
    And request
      """
      {
        "id": "#(requestId2)",
        "requestLevel": "Item",
        "requestType": "Hold",
        "requestDate": "2023-03-23T11:04:25.000+00:00",
        "holdingsRecordId": "#(globalHoldingId1)",
        "requesterId": "#(userId)",
        "instanceId": "#(globalInstanceId1)",
        "itemId": "#(prevItemId2)",
        "fulfillmentPreference": "Delivery"
      }
      """
    When method POST
    Then status 201

    # 2. Verify circulation request with previous item details
    Given path 'circulation', 'requests', requestId1
    When method GET
    Then status 200
    And match $.itemId == prevItemId1

    # 3. Verify circulation request with previous item details
    Given path 'circulation', 'requests', requestId2
    When method GET
    Then status 200
    And match $.itemId == prevItemId2
    * configure headers = headersUser

    # 3. Perpare data for bind piece
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.bindItem.barcode = '22222'
    * set bindPieceCollection.bindItem.holdingId = globalHoldingId1
    * set bindPieceCollection.poLineId = poLineId1
    * set bindPieceCollection.bindPieceIds[0] = pieceWithItemId3
    * set bindPieceCollection.bindPieceIds[1] = pieceWithItemId4

    # 4 Verify ERROR Open Requests for item when Bind pieces together for poLineId1 with pieceId1 and pieceId2
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 422
    And match $.errors[*].code contains 'requestsActionRequired'

    # 4. Verify SUCCESS Open Requests for item when request action is Transfer
    * set bindPieceCollection.requestsAction = "Transfer"

    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    And match $.poLineId == poLineId1
    And match $.boundPieceIds[*] contains pieceWithItemId3
    And match $.boundPieceIds[*] contains pieceWithItemId4
    And match $.itemId != null
    * def newItemId = $.itemId

    # 5. Check both circulation request
    * configure headers = headersAdmin
    Given path 'circulation/requests', requestId1
    When method GET
    Then status 200
    And match $.requestLevel == 'Item'
    And match $.itemId == newItemId

    * configure headers = headersAdmin
    Given path 'circulation/requests', requestId2
    When method GET
    Then status 200
    And match $.requestLevel == 'Item'
    And match $.itemId == newItemId