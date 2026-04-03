# For MODORDSTOR-354
@parallel=false
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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def previousDate = '2024-01-23T12:50:03.156+00:00'

    # Create Finances
    * configure headers = headersAdmin
    * def v = callonce createFund { 'id': '#(fundId)' }
    * def v = callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)', 'status': 'Active' }
    * configure headers = headersUser


  # ============================================================
  # C436738: Piece status has not been changed if "Expected receipt date" wasn't specified
  # https://foliotest.testrail.io/index.php?/cases/view/436738
  # ============================================================
  @C436738
  @Positive
  Scenario: Verify Piece Status Not Changed Without Expected Receipt Date
    * def orderId = call uuid
    * def poLineId = call uuid

    # Precondition 1: Create Ongoing Order In Open Status With Claiming Active
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false } }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # Precondition 2: Run Pieces Claiming Batch Job
    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200
    * call pause 3000

    # Step 1: Check Piece In Expected Accordion - Piece Should Be In Expected Status
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.pieces[0].receivingStatus == 'Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receiptDate == '#notpresent'

    # Step 2: Verify PO Line Receipt Status Is Ongoing
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }

    # Step 3-4: Verify Item Status Is On Order
    * def poLine = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = poLine.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'


  # ============================================================
  # C436793: Piece status is set to "Late" after "Claim sent" date passed
  # https://foliotest.testrail.io/index.php?/cases/view/436793
  # ============================================================
  @C436793
  @Positive
  Scenario: Verify Piece Status Changed To Late After Claim Sent Date Passed
    * def orderId = call uuid
    * def poLineId = call uuid
    * def uniqueBarcode = call uuid

    # Precondition 1: Create Ongoing Order In Open Status With Claiming Active
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false } }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 1 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # Precondition 2: Set Barcode, Set Piece Status To Claim Sent, Send Claim Date To Tomorrow
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

    # Step 1: Check Piece In Expected Accordion - Piece Should Be In Claim Sent Status
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId)', _receivingStatus: 'Claim sent' }

    # Step 2: Change StatusUpdatedDate To Past, ClaimingInterval To 1, And Run Batch Job
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

    # Step 3: Verify Piece Status Changed To Late
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId)', _receivingStatus: 'Late' }

    # Step 4: Verify PO Line Receipt Status Is Ongoing
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }

    # Step 5-6: Verify Item Status Is On Order
    * def poLine = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = poLine.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'


  # ============================================================
  # C436794: Piece status is changed to "Late" after "Delay claim" date is passed,
  # even when "Claiming interval" has not expired yet
  # https://foliotest.testrail.io/index.php?/cases/view/436794
  # ============================================================
  @C436794
  @Positive
  Scenario: Verify Piece Status Changed To Late After Delay Claim Date Passed
    * def orderId = call uuid
    * def poLineId = call uuid

    # Precondition 1: Create One-Time Order In Open Status With Claiming Active And Interval 3
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, claimingActive: true, claimingInterval: 3 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # Precondition 2: Set Piece Status To Claim Delayed (Delay Claim Set To Tomorrow)
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

    # Precondition 3.1: GET Piece To Copy Response
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    * def piece = $

    # Precondition 3.2: PUT Piece With StatusUpdatedDate In The Past And ClaimingInterval 1
    * set piece.statusUpdatedDate = previousDate
    * set piece.claimingInterval = 1
    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

    # Precondition 3.3: Run Pieces Claiming Batch Job
    Given path 'orders-storage/claiming/process'
    When method POST
    Then status 200
    * call pause 3000

    # Step 1: Verify Piece Status Changed To Late
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId)', _receivingStatus: 'Late' }

    # Step 2: Verify PO Line Receipt Status Is Awaiting Receipt
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Awaiting Receipt' }

    # Step 3-4: Verify Item Status Is On Order
    * def poLine = call getOrderLine { poLineId: '#(poLineId)' }
    * def holdingId = poLine.poLine.locations[0].holdingId
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].status.name == 'On order'
