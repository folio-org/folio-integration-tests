# For: https://folio-org.atlassian.net/browse/MODORDERS-1356
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

    * callonce variables
    * def fundId = call uuid

  @Positive
  Scenario: Open order with synchronized order line and manually add pieces without providing sequence numbers manually
    # 1. Create order and order line
    * def orderId = call uuid
    * def poLineId = call uuid
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
    And match response.pieces[*].sequenceNumber contains only [1, 2, 3, 4, 5]
    * def holdingId = response.pieces[0].holdingId

    # 3.3 Verify that title's nextSequenceNumber is updated to 6 after 5 pieces are created
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match response.nextSequenceNumber == 6

    # 4.1 Create piece manually without providing sequence number
    * table piecesData
      | poLineId | titleId | holdingId | format     | createItem |
      | poLineId | titleId | holdingId | 'Physical' | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 4.2 Verify that the piece is created with the next sequence number 6
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 6
    And match response.pieces[*].sequenceNumber contains only [1, 2, 3, 4, 5, 6]

    # 4.3 Verify that title's nextSequenceNumber is updated to 7 after the piece is created
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match response.nextSequenceNumber == 7

    # 5.1 Create 3 pieces in batch without providing all sequence numbers
    * table piecesData
      | poLineId | titleId | holdingId | format     | sequenceNumber |
      | poLineId | titleId | holdingId | 'Physical' | null           |
      | poLineId | titleId | holdingId | 'Physical' | 8              |
      | poLineId | titleId | holdingId | 'Physical' | 9              |
      | poLineId | titleId | holdingId | 'Physical' | null           |
    * def v = call createPiecesBatch { pieceCollection: { pieces: "#(piecesData)", totalRecords: 4 } }

    # 5.2 Verify that 3 pieces are created with the next sequence numbers 7, 8 and 9, 10
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 10
    And match response.pieces[*].sequenceNumber contains only [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    # 5.3 Verify that title's nextSequenceNumber is updated to 10 after 3 pieces are created
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match response.nextSequenceNumber == 11