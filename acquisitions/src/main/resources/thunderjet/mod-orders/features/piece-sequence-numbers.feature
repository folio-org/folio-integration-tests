# For: https://folio-org.atlassian.net/browse/MODORDERS-1356
#      https://folio-org.atlassian.net/browse/MODORDSTOR-485
Feature: Piece sequence numbers

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

    * def verifyTitleNextSequenceNumber = read('classpath:thunderjet/mod-orders/helpers/helper-piece-sequence-numbers.feature@VerifyTitleNextSequenceNumber')
    * def verifyPieceSequenceNumbersPresent = read('classpath:thunderjet/mod-orders/helpers/helper-piece-sequence-numbers.feature@VerifyPieceSequenceNumbersPresent')
    * def verifyPieceSequenceNumbers = read('classpath:thunderjet/mod-orders/helpers/helper-piece-sequence-numbers.feature@VerifyPieceSequenceNumbers')
    * def changePieceSequenceNumber = read('classpath:thunderjet/mod-orders/helpers/helper-piece-sequence-numbers.feature@ChangePieceSequenceNumber')

    * callonce variables
    * def orderId = call uuid
    * def poLineId = call uuid
    * def fundId = globalFundId

  @Positive
  Scenario: Open order with synchronized order line and manually add pieces without providing sequence numbers manually
    # 1. Create order and order line
    * def poLineLocations = [ { locationId: #(globalLocationsId), quantity: 5, quantityPhysical: 5 } ]
    * table orderLineData
      | id       | orderId | locations       | quantity | titleOrPackage |
      | poLineId | orderId | poLineLocations | 5        | 't1'           |
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine orderLineData

    # 2. Get title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.titles[0].poLineId == poLineId
    And match response.titles[0].nextSequenceNumber == 1
    * def titleId = response.titles[0].id

    # 3.1 Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3.2 Verify that 5 pieces are created automatically with correct sequence numbers
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 5
    And match response.pieces[*].sequenceNumber contains only [ 1, 2, 3, 4, 5 ]
    * def holdingId = response.pieces[0].holdingId

    # 3.3 Verify that title's nextSequenceNumber is updated to 6 after 5 pieces are created
    * def v = call verifyTitleNextSequenceNumber { titleId: '#(titleId)', nextSequenceNumber: 6 }

    # 4.1 Create piece manually without providing sequence number
    * table piecesData
      | poLineId | titleId | holdingId | format     | createItem |
      | poLineId | titleId | holdingId | 'Physical' | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 4.2 Verify that the piece is created with the next sequence number 6
    * def expectedSequenceNumbers = [ 1, 2, 3, 4, 5, 6 ]
    * def v = call verifyPieceSequenceNumbersPresent { poLineId: '#(poLineId)', expectedSequenceNumbers: '#(expectedSequenceNumbers)' }

    # 4.3 Verify that title's nextSequenceNumber is updated to 7 after the piece is created
    * def v = call verifyTitleNextSequenceNumber { titleId: '#(titleId)', nextSequenceNumber: 7 }

    # 5.1 Create 3 pieces in batch without providing all sequence numbers
    * table piecesData
      | poLineId | titleId | holdingId | format     | sequenceNumber |
      | poLineId | titleId | holdingId | 'Physical' | null           |
      | poLineId | titleId | holdingId | 'Physical' | 8              |
      | poLineId | titleId | holdingId | 'Physical' | 9              |
      | poLineId | titleId | holdingId | 'Physical' | null           |
    * def v = call createPiecesBatch { pieceCollection: { pieces: "#(piecesData)", totalRecords: 4 } }

    # 5.2 Verify that 3 pieces are created with the next sequence numbers 7, 8 and 9, 10
    * def expectedSequenceNumbers = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
    * def v = call verifyPieceSequenceNumbersPresent { poLineId: '#(poLineId)', expectedSequenceNumbers: '#(expectedSequenceNumbers)' }

    # 5.3 Verify that title's nextSequenceNumber is updated to 10 after 3 pieces are created
    * def v = call verifyTitleNextSequenceNumber { titleId: '#(titleId)', nextSequenceNumber: 11 }

  @Positive
  Scenario: Verify piece sequence numbers while adding piece with provided numbers
    # 1. Create and open order with order line
    * def poLineLocations = [ { locationId: #(globalLocationsId), quantity: 5, quantityPhysical: 5 } ]
    * table orderLineData
      | id       | orderId | locations       | quantity | titleOrPackage |
      | poLineId | orderId | poLineLocations | 5        | 't1'           |
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine orderLineData
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Get title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 3.1 Verify that 5 pieces are created automatically with correct sequence numbers
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 5
    And match response.pieces[*].sequenceNumber contains only [ 1, 2, 3, 4, 5 ]
    * def holdingId = response.pieces[0].holdingId

    # 3.3 Verify that title's nextSequenceNumber is updated to 6 after 5 pieces are created
    * def v = call verifyTitleNextSequenceNumber { titleId: '#(titleId)', nextSequenceNumber: 6 }

    # 4.1 Create piece manually and provide sequence number
    * def pieceId = call uuid
    * table piecesData
      | id      | poLineId | titleId | holdingId | format     | sequenceNumber | createItem |
      | pieceId | poLineId | titleId | holdingId | 'Physical' | 3              | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 4.2 Verify that the piece is created and other pieces' sequence numbers are resequenced accordingly
    * def expectedSequenceNumbers = [ 1, 2, 3, 4, 5, 6 ]
    * def v = call verifyPieceSequenceNumbersPresent { poLineId: '#(poLineId)', expectedSequenceNumbers: '#(expectedSequenceNumbers)' }

    # 4.3 Verify that the piece with provided sequence number is created correctly
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match response.sequenceNumber == 3

    # 4.4 Verify that title's nextSequenceNumber is updated to 7 after the piece is created
    * def v = call verifyTitleNextSequenceNumber { titleId: '#(titleId)', nextSequenceNumber: 7 }

  @Positive
  Scenario: Verify resequence logic while editing sequence numbers
    # 1. Create and open order with order line (independent receiving)
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', titleOrPackage: 't1', checkinItems: true }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Get title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 3.1 Create 6 pieces manually with sequence numbers and unique display summaries
    * table piecesData
      | poLineId | titleId | format     | displaySummary | sequenceNumber |
      | poLineId | titleId | 'Physical' | 'P1'           | 1              |
      | poLineId | titleId | 'Physical' | 'P2'           | 2              |
      | poLineId | titleId | 'Physical' | 'P3'           | 3              |
      | poLineId | titleId | 'Physical' | 'P4'           | 4              |
      | poLineId | titleId | 'Physical' | 'P5'           | 5              |
      | poLineId | titleId | 'Physical' | 'P6'           | 6              |
    * def v = call createPiece piecesData

    # 3.2 Verify that 6 pieces are created with correct sequence numbers
    * def expectedPieces = { 'P1': 1, 'P2': 2, 'P3': 3, 'P4': 4, 'P5': 5, 'P6': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

    # 4.1 Change sequence number of P2 to 4 (P3 and P4 should be shifted down)
    * def v = call changePieceSequenceNumber { poLineId: '#(poLineId)', displaySummary: 'P2', sequenceNumber: 4 }

    # 4.2 Verify the new sequence numbers
    * def expectedPieces = { 'P1': 1, 'P3': 2, 'P4': 3, 'P2': 4, 'P5': 5, 'P6': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

    # 5.1 Change sequence number of P6 to 2 (P3, P4, P2 and P5 should be shifted up)
    * def v = call changePieceSequenceNumber { poLineId: '#(poLineId)', displaySummary: 'P6', sequenceNumber: 2 }

    # 5.2 Verify the new sequence numbers
    * def expectedPieces = { 'P1': 1, 'P6': 2, 'P3': 3, 'P4': 4, 'P2': 5, 'P5': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

  @Positive
  Scenario: Verify resequence logic with deleted pieces while editing sequence numbers
    # 1. Create and open order with order line (independent receiving)
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', titleOrPackage: 't1', checkinItems: true }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 2. Get title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 3.1 Create 6 pieces manually with sequence numbers and unique display summaries
    * table piecesData
      | poLineId | titleId | format     | displaySummary | sequenceNumber |
      | poLineId | titleId | 'Physical' | 'P1'           | 1              |
      | poLineId | titleId | 'Physical' | 'P2'           | 2              |
      | poLineId | titleId | 'Physical' | 'P3'           | 3              |
      | poLineId | titleId | 'Physical' | 'P4'           | 4              |
      | poLineId | titleId | 'Physical' | 'P5'           | 5              |
      | poLineId | titleId | 'Physical' | 'P6'           | 6              |
    * def v = call createPiece piecesData

    # 3.2 Verify that 6 pieces are created with correct sequence numbers
    * def expectedPieces = { 'P1': 1, 'P2': 2, 'P3': 3, 'P4': 4, 'P5': 5, 'P6': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

    # 4.1 Delete piece with displaySummary P5
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId + ' AND displaySummary==P5'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def pieceId = response.pieces[0].id

    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 204

    # 4.2 Verify the new sequence numbers
    * def expectedPieces = { 'P1': 1, 'P2': 2, 'P3': 3, 'P4': 4, 'P6': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

    # 5.1 Change sequence number of P2 to 5 (P3, P4 should be shifted down)
    * def v = call changePieceSequenceNumber { poLineId: '#(poLineId)', displaySummary: 'P2', sequenceNumber: 5 }

    # 5.2 Verify the new sequence numbers
    * def expectedPieces = { 'P1': 1, 'P3': 2, 'P4': 3, 'P2': 5, 'P6': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

    # 6.1 Change sequence number of P6 to 1 (P3, P4 and P2 should be shifted up)
    * def v = call changePieceSequenceNumber { poLineId: '#(poLineId)', displaySummary: 'P6', sequenceNumber: 1 }

    # 6.2 Verify the new sequence numbers
    * def expectedPieces = { 'P6': 1, 'P1': 2, 'P3': 3, 'P4': 4, 'P2': 6 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }

    # 7.1 Delete piece with displaySummary P2
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId + ' AND displaySummary==P2'
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def pieceId = response.pieces[0].id

    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 204

    # 7.2 Create piece with sequence number 7
    * def pieceId = call uuid
    * table piecesData
      | pieceId | poLineId | titleId | format     | displaySummary | sequenceNumber |
      | pieceId | poLineId | titleId | 'Physical' | 'P7'           | 7              |
    * def v = call createPiece piecesData

    # 7.3 Verify the new sequence numbers
    * def expectedPieces = { 'P6': 1, 'P1': 2, 'P3': 3, 'P4': 4, 'P7': 7 }
    * def v = call verifyPieceSequenceNumbers { poLineId: '#(poLineId)', expectedPieces: '#(expectedPieces)' }