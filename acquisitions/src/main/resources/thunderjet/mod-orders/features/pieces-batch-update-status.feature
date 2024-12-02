Feature: Update Pieces statuses in batch

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure retry = { count: 5, interval: 1000 }
    * configure headers = headersAdmin

    * callonce variables
    * def fundId = callonce uuid
    * def budgetId = callonce uuid1
    * def orderId = callonce uuid2
    * def poLineId = callonce uuid3
    * def titleId = callonce uuid4
    * def pieceId1 = callonce uuid5
    * def pieceId2 = callonce uuid6
    * def pieceId3 = callonce uuid7

    ### Before All ###
    # 1. Prepare finance data
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }

    # 2. Prepare acquisitions data
    * def v = callonce createOrder { id: '#(orderId)' }
    * def v = callonce createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true }
    * def v = callonce openOrder { orderId: '#(orderId)' }
    * def v = callonce createTitle { titleId: '#(titleId)', poLineId: '#(poLineId)' }

    # 3. Prepare pieces data
    * table pieceData
      | pieceId  | titleId | poLineId |
      | pieceId1 | titleId | poLineId |
      | pieceId2 | titleId | poLineId |
      | pieceId3 | titleId | poLineId |
    * def v = callonce createPiece pieceData
    * configure headers = headersUser

  @Positive
  Scenario: Update once Piece status in batch to received and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Unreceivable"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)"], receivingStatus: 'Unreceivable' }
    # 2. Verify PoLine receipt status is "Partially Received"
    * def v = call read('@verifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Partially Received' }

  @Positive
  Scenario: Update all Piece statuses in batch to received and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Received"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }
    # 2. Verify PoLine receipt status is "Fully Received"
    * def v = call read('@verifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Fully Received' }

  @Positive
  Scenario: Update all Piece statuses in batch to expected and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Expected"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Expected' }
    # 2. Verify PoLine receipt status is "Awaiting Receipt"
    * def v = call read('@verifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Awaiting Receipt' }

  @Negative
  Scenario: Update Piece statuses in batch with wrong Receiving Status
    * def badStatus = 'Bad Status'

    Given path 'orders/pieces-batch/status'
    And request { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: '#(badStatus)' }
    When method PUT
    Then status 400

  @Negative
  Scenario: Update Piece statuses in batch with wrong Piece ID
    * def invalidPieceId = call uuid

    Given path 'orders/pieces-batch/status'
    And request { pieceIds: ["#(invalidPieceId)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }
    When method PUT
    Then status 400

  @Negative
  Scenario: Update Piece statuses in batch with Cancelled/Ongoing PoLine
    # 1. Cancel Order so that PoLine receipt status is "Cancelled"
    * def v = call cancelOrder { orderId: "#(orderId)" }
    # 2. Update Pieces statuses in batch to "Received"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }
    # 3. Verify PoLine receipt status is not modified
    * def v = call read('@verifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Cancelled' }

  @ignore @VerifyPoLineReceiptStatus
  Scenario: Verify PoLine receipt status
    Given path 'orders/order-lines', _poLineId
    And retry until response.receiptStatus == _receiptStatus
    When method GET
    Then status 200
