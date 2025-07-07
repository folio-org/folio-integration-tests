# MODORDERS-1210
Feature: Update Pieces statuses in batch

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * configure retry = { count: 10, interval: 5000 }

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
    * configure headers = headersAdmin
    * def v = callonce createFund { id: '#(fundId)' }
    * def v = callonce createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', status: 'Active' }

    # 2. Prepare acquisitions data
    * configure headers = headersUser
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

  @Positive
  Scenario: Update once Piece status in batch to received and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Unreceivable"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)"], receivingStatus: 'Unreceivable' }

    # 2. Verify PoLine receipt status is "Partially Received"
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Partially Received' }

    # 3. Verify Piece receiving status is "Unreceivable"
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Unreceivable'   |
    * def v = call verifyPieceReceivingStatus verifyPieceData

    # 4. Verify Piece status change audit events
    * configure headers = headersAdmin
    * table verifyPieceAuditData
      | _pieceId | _receivingStatus | _eventCount |
      | pieceId1 | 'Unreceivable'   | 2           |
    * def v = call verifyPieceAuditEvents verifyPieceAuditData


  @Positive
  Scenario: Update all Piece statuses in batch to received and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Received"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }

    # 2. Verify PoLine receipt status is "Fully Received"
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Fully Received' }

    # 3. Verify Piece receiving status is "Unreceivable"
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId2 | 'Received'       |
      | pieceId3 | 'Received'       |
    * def v = call verifyPieceReceivingStatus verifyPieceData

    # 4. Verify Piece status change audit events
    * configure headers = headersAdmin
    * table verifyPieceAuditData
      | _pieceId | _receivingStatus | _eventCount |
      | pieceId2 | 'Received'       | 2           |
      | pieceId3 | 'Received'       | 2           |
    * def v = call verifyPieceAuditEvents verifyPieceAuditData


  @Positive
  Scenario: Update all Piece statuses in batch to expected and verify PoLine receipt status
    # 1. Update once Piece status in batch to "Expected"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Expected' }

    # 2. Verify PoLine receipt status is "Awaiting Receipt"
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Awaiting Receipt' }

    # 3. Verify Piece receiving status is "Unreceivable"
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Expected'       |
      | pieceId2 | 'Expected'       |
      | pieceId3 | 'Expected'       |
    * def v = call verifyPieceReceivingStatus verifyPieceData

    # 4. Verify Piece status change audit events
    * configure headers = headersAdmin
    * table verifyPieceAuditData
      | _pieceId | _receivingStatus | _eventCount |
      | pieceId1 | 'Expected'       | 3           |
      | pieceId2 | 'Expected'       | 3           |
      | pieceId3 | 'Expected'       | 3           |
    * def v = call verifyPieceAuditEvents verifyPieceAuditData


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
    * def v = call verifyPieceReceivingStatus verifyPieceData


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
    * def v = call verifyPieceReceivingStatus verifyPieceData


  @Negative
  Scenario: Update Piece statuses in batch with Cancelled/Ongoing PoLine
    # 1. Cancel Order so that PoLine receipt status is "Cancelled"
    * def v = call cancelOrder { orderId: "#(orderId)" }

    # 2. Update Pieces statuses in batch to "Received"
    * def v = call updatePiecesBatchStatus { pieceIds: ["#(pieceId1)", "#(pieceId2)", "#(pieceId3)"], receivingStatus: 'Received' }

    # 3. Verify PoLine receipt status is not modified
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Cancelled' }

    # 4. Verify Piece receiving status is modified
    * table verifyPieceData
      | _pieceId | _receivingStatus |
      | pieceId1 | 'Received'       |
      | pieceId2 | 'Received'       |
      | pieceId3 | 'Received'       |
    * def v = call verifyPieceReceivingStatus verifyPieceData

  @Positive
  Scenario: Update Piece statuses in batch with claimingInterval, internalNote and externalNote
    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleId = call uuid

    # 1. Create order with 2 pieces
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, claimingActive: true, claimingInterval: 1 }
    * def v = call createTitle { titleId: '#(titleId)', poLineId: '#(poLineId)' }
    * table pieceData
      | pieceId  | titleId | poLineId |
      | pieceId1 | titleId | poLineId |
      | pieceId2 | titleId | poLineId |
    * def v = call createPiece pieceData

    # 2. Update Pieces statuses in batch with additional fields
    Given path 'orders/pieces-batch/status'
    And request { pieceIds: ["#(pieceId1)", "#(pieceId2)"], receivingStatus: 'Claim delayed', claimingInterval: 15, internalNote: 'Internal test note', externalNote: 'External test note' }
    When method PUT
    Then status 204

    # 3. Verify Piece status and fields are updated correctly
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.receivingStatus == 'Claim delayed'
    And match $.claimingInterval == 15
    And match $.internalNote == 'Internal test note'
    And match $.externalNote == 'External test note'

    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match $.receivingStatus == 'Claim delayed'
    And match $.claimingInterval == 15
    And match $.internalNote == 'Internal test note'
    And match $.externalNote == 'External test note'

  @Positive
  Scenario: Update 100 pieces statuses in batch to delay claim, late claim and unreceivable
    ## Relogin to avoid login expry problem
    * call login testAdmin
    * def okapitokenAdmin = okapitoken
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    # 1. Create 100 Pieces
    * def piecesData = []
    * def populatePiecesData =
      """
      function() {
        for (let i = 0; i < 100; i++) {
          const randomPieceId = uuid();
          piecesData.push({ id: randomPieceId, titleId: titleId, poLineId: poLineId, format: 'Physical', locationId: globalLocationsId });
        }
      }
      """
    * eval populatePiecesData()
    * def piecesIds = piecesData.map(x => x.id)
    * print 'piecesIds:' + piecesIds
    * def pieceCollection = { pieces: '#(piecesData)', totalRecords: 100 }
    * def v = call createPiecesBatch pieceCollection

    # 2 Update Pieces statuses in batch to "Claim delayed"
    * def v = call updatePiecesBatchStatus { pieceIds: '#(piecesIds)', receivingStatus: 'Claim delayed' }
    * def verifyPiecesData1 = karate.map(piecesIds, function(id) { return { _pieceId: id, _receivingStatus: 'Claim delayed', _eventCount: 2 } } )
    * configure headers = headersAdmin
    * def v = call verifyPieceAuditEvents verifyPiecesData1

    # 3 Update Pieces statuses in batch to "Claim sent"
    * configure headers = headersUser
    * def v = call updatePiecesBatchStatus { pieceIds: '#(piecesIds)', receivingStatus: 'Claim sent' }
    * def verifyPiecesData2 = karate.map(piecesIds, function(id) { return { _pieceId: id, _receivingStatus: 'Claim sent', _eventCount: 3 } } )
    * configure headers = headersAdmin
    * def v = call verifyPieceAuditEvents verifyPiecesData2

    # 4 Update Pieces statuses in batch to "Unreceivable"
    * configure headers = headersUser
    * def v = call updatePiecesBatchStatus { pieceIds: '#(piecesIds)', receivingStatus: 'Unreceivable' }
    * def verifyPiecesData3 = karate.map(piecesIds, function(id) { return { _pieceId: id, _receivingStatus: 'Unreceivable', _eventCount: 4 } } )

    * configure headers = headersAdmin
    * def v = call verifyPieceAuditEvents verifyPiecesData3
