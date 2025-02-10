# MODORDERS-1210
Feature: Update Pieces statuses in batch

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * call loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure retry = { count: 10, interval: 5000 }
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
    * def v = callonce createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
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
    * def v = call read('@VerifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Partially Received' }

    # 3. Verify Piece receiving status is "Unreceivable"
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Unreceivable'   |
    * def v = call read('@VerifyPieceReceivingStatus') verifyPieceData

    # 4. Verify Piece status change audit events
    * table verifyPieceAuditData
      | _pieceId | _receivingStatus | _eventCount |
      | pieceId1 | 'Unreceivable'   | 2           |
    * def v = call read('@VerifyPieceAuditEvents') verifyPieceAuditData


  @Positive
  Scenario: Update all Piece statuses in batch to received and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Received"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }

    # 2. Verify PoLine receipt status is "Fully Received"
    * def v = call read('@VerifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Fully Received' }

    # 3. Verify Piece receiving status is "Unreceivable"
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId2 | 'Received'       |
      | pieceId3 | 'Received'       |
    * def v = call read('@VerifyPieceReceivingStatus') verifyPieceData

    # 4. Verify Piece status change audit events
    * table verifyPieceAuditData
      | _pieceId | _receivingStatus | _eventCount |
      | pieceId2 | 'Received'       | 2           |
      | pieceId3 | 'Received'       | 2           |
    * def v = call read('@VerifyPieceAuditEvents') verifyPieceAuditData


  @Positive
  Scenario: Update all Piece statuses in batch to expected and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Expected"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Expected' }

    # 2. Verify PoLine receipt status is "Awaiting Receipt"
    * def v = call read('@VerifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Awaiting Receipt' }

    # 3. Verify Piece receiving status is "Unreceivable"
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Expected'       |
      | pieceId2 | 'Expected'       |
      | pieceId3 | 'Expected'       |
    * def v = call read('@VerifyPieceReceivingStatus') verifyPieceData

    # 4. Verify Piece status change audit events
    * table verifyPieceAuditData
      | _pieceId | _receivingStatus | _eventCount |
      | pieceId1 | 'Expected'       | 3           |
      | pieceId2 | 'Expected'       | 3           |
      | pieceId3 | 'Expected'       | 3           |
    * def v = call read('@VerifyPieceAuditEvents') verifyPieceAuditData


  @Negative
  Scenario: Update Piece statuses in batch with wrong Receiving Status
    # 1. Update Pieces statuses in batch to "Bad Status"
    * def badStatus = 'Bad Status'
    Given path 'orders/pieces-batch/status'
    And request { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: '#(badStatus)' }
    When method PUT
    Then status 400

    # 2. Verify Piece receiving status is not modified
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Expected'       |
      | pieceId2 | 'Expected'       |
      | pieceId3 | 'Expected'       |
    * def v = call read('@VerifyPieceReceivingStatus') verifyPieceData


  @Negative
  Scenario: Update Piece statuses in batch with invalid Piece ID
    # 1. Update Pieces statuses in batch with one invalid piece ID
    * def invalidPieceId = call uuid
    Given path 'orders/pieces-batch/status'
    And request { pieceIds: ["#(invalidPieceId)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }
    When method PUT
    Then status 400

    # 2. Verify Piece receiving status is not modified
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Expected'       |
      | pieceId2 | 'Expected'       |
      | pieceId3 | 'Expected'       |
    * def v = call read('@VerifyPieceReceivingStatus') verifyPieceData


  @Negative
  Scenario: Update Piece statuses in batch with Cancelled/Ongoing PoLine
    # 1. Cancel Order so that PoLine receipt status is "Cancelled"
    * def v = call cancelOrder { orderId: "#(orderId)" }

    # 2. Update Pieces statuses in batch to "Received"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }

    # 3. Verify PoLine receipt status is not modified
    * def v = call read('@VerifyPoLineReceiptStatus') { _poLineId: '#(poLineId)', _receiptStatus: 'Cancelled' }

    # 4. Verify Piece receiving status is modified
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Received'       |
      | pieceId2 | 'Received'       |
      | pieceId3 | 'Received'       |
    * def v = call read('@VerifyPieceReceivingStatus') verifyPieceData

  @Positive
  Scenario: Update 100 pieces statuses in batch to delay claim, late claim and unreceivable
    # 1. Create 100 Pieces
    * def piecesIds = []
    * def piecesData = []
    * def populatePiecesData =
      """
      function() {
        for (let i = 0; i < 100; i++) {
          const randomPieceId = uuid();
          piecesIds.push(randomPieceId);
          piecesData.push({ id: randomPieceId, titleId: titleId, poLineId: poLineId, format: 'Physical', locationId: globalLocationsId });
        }
      }
      """
    * eval populatePiecesData()
    * def pieceCollection = { pieces: '#(piecesData)', totalRecords: 100 }
    * def v = call createPiecesBatch pieceCollection

    # 2 Update Pieces statuses in batch to "Claim delayed"
    * def v = call updatePiecesBatchStatus { pieceIds: '#(piecesIds)', receivingStatus: 'Claim delayed' }
    * def verifyPiecesData1 = karate.map(piecesIds, function(id) { return { _pieceId: id, _receivingStatus: 'Claim delayed', _eventCount: 2 } } )
    * def v = call verifyPieceAuditEvents verifyPiecesData1

    ## Relogin to avoid login expry problem
    * def headersAdmin = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'Accept': '*/*'  }
    * configure headers = headersUser
    * call loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * call loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    # 3 Update Pieces statuses in batch to "Claim sent"
    * def v = call updatePiecesBatchStatus { pieceIds: '#(piecesIds)', receivingStatus: 'Claim sent' }
    * def verifyPiecesData2 = karate.map(piecesIds, function(id) { return { _pieceId: id, _receivingStatus: 'Claim sent', _eventCount: 3 } } )
    * def v = call verifyPieceAuditEvents verifyPiecesData2

    # 4 Update Pieces statuses in batch to "Unreceivable"
    * def v = call updatePiecesBatchStatus { pieceIds: '#(piecesIds)', receivingStatus: 'Unreceivable' }
    * def verifyPiecesData3 = karate.map(piecesIds, function(id) { return { _pieceId: id, _receivingStatus: 'Unreceivable', _eventCount: 4 } } )
    * def v = call verifyPieceAuditEvents verifyPiecesData3


  @ignore @VerifyPoLineReceiptStatus
  Scenario: Verify PoLine receipt status
    Given path 'orders/order-lines', _poLineId
    And retry until response.receiptStatus == _receiptStatus
    When method GET
    Then status 200


  @ignore @VerifyPieceReceivingStatus
  Scenario: Verify Piece receiving status
    Given path 'orders/pieces', _pieceId
    When method GET
    Then status 200
    And match response.receivingStatus == _receivingStatus