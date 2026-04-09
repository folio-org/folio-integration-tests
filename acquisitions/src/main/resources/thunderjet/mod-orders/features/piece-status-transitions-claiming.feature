# For MODORDSTOR-354,
# https://foliotest.testrail.io/index.php?/cases/view/436738,
# https://foliotest.testrail.io/index.php?/cases/view/436793,
# https://foliotest.testrail.io/index.php?/cases/view/436794
Feature: Piece status transitions claiming

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

    * configure retry = { count: 10, interval: 10000 }

    * callonce variables
    * def previousDate = '2024-01-23T12:50:03.156+00:00'
    * def fundId = call uuid
    * def budgetId = call uuid

    # Create finances
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }
    * configure headers = headersUser

  @C436738
  @Positive
  # TestRail: https://foliotest.testrail.io/index.php?/cases/view/436738
  Scenario: Verify Piece Status Not Changed Without Expected Receipt Date
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Ongoing order in Open status with claiming active
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false } }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Run pieces claiming batch job
    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200
    * call pause 3000

    # 3. Check piece in Expected accordion - piece should be in Expected status
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.pieces[0].receivingStatus == 'Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receiptDate == '#notpresent'

    # 4. Verify PO line receipt status is Ongoing
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }

    # 5. Verify item status is On order
    * def getPoLineResult = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = getPoLineResult.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'

  @C436793
  @Positive
  # TestRail: https://foliotest.testrail.io/index.php?/cases/view/436793
  Scenario: Verify Piece Status Changed To Late After Claim Sent Date Passed
    * def orderId = call uuid
    * def poLineId = call uuid
    * def uniqueBarcode = call uuid

    # 1. Create Ongoing order in Open status with claiming active
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false } }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Set barcode, set piece status to Claim sent, send claim date to tomorrow
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Claim sent'
    * set piece.claimingInterval = 1
    * set piece.barcode = uniqueBarcode
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    # 3. Check piece in Expected accordion - piece should be in Claim sent status
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId)', _receivingStatus: 'Claim sent' }

    # 4. Change statusUpdatedDate to past, claimingInterval to 1, and run batch job
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    * def piece = $
    * set piece.statusUpdatedDate = previousDate
    * set piece.claimingInterval = 1
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200
    * call pause 3000

    # 5. Verify piece status changed to Late
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId)', _receivingStatus: 'Late' }

    # 6. Verify PO line receipt status is Ongoing
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }

    # 7. Verify item status is On order
    * def getPoLineResult = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = getPoLineResult.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'

  @C436794
  @Positive
  # TestRail: https://foliotest.testrail.io/index.php?/cases/view/436794
  Scenario: Verify Piece Status Changed To Late After Delay Claim Date Passed
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create One-time order in Open status with claiming active, claiming interval = 3
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 3 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Set piece status to Claim delayed with claimingInterval = 1 (delay claim set to tomorrow)
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Claim delayed'
    * set piece.claimingInterval = 1
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    # 3. Change statusUpdatedDate to past and claimingInterval to 1 to simulate delay claim date passed
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    * def piece = $
    * set piece.statusUpdatedDate = previousDate
    * set piece.claimingInterval = 1
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    # 4. Run pieces claiming batch job
    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200
    * call pause 3000

    # 5. Verify piece status changed to Late
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId)', _receivingStatus: 'Late' }

    # 6. Verify PO line receipt status is Awaiting Receipt
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Awaiting Receipt' }

    # 7. Verify item status is On order
    * def getPoLineResult = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = getPoLineResult.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'
