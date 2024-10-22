Feature: Piece deletion restrictions from order and order line

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*' }

    * callonce variables
    * def last_piece_error_masage = "The piece cannot be deleted because it is the last piece for the poLine in with Receiving Workflow 'Synchronized order and receipt quantity' and cost quantity '1'"
    * def fundId = call uuid
    * def budgetId = call uuid

    # Prepare finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

  Scenario: Avoid deletion of piece when poLine cost quantity '1' and ReceivingWorkflow 'Syncronized'
    increase piece quantity and delete successfully
    * def orderId = call uuid
    * def poLineId = call uuid
    * def newPieceId = call uuid

    # 1. Create order
    * def v = call createOrder { 'id': '#(orderId)' }

    # 2. Create order line with quantity 1 and Receiving Workflow 'Synchronized order and receipt quantity' = false
    * def v = call createOrderLine { 'id': '#(poLineId)', 'orderId': '#(orderId)', 'quantity': 1, 'checkinItems': false }

    # 3. Open Order
    * def v = call openOrder { 'id': '#(orderId)' }

    # 4. Get Piece by poLineId
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    # 5. Verify validation for delete Piece with Order Status 'Open'
    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 422
    And match $.errors[0].message == last_piece_error_masage

    # 6. close Order
    * def v = call closeOrder { 'id': '#(orderId)' }

    # 7. Verify validation for delete Piece with Order Status 'Closed'
    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 422
    And match $.errors[0].message == last_piece_error_masage

    # 8. Get title and create second piece for poLine in order to increase cost quantity
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    * def v = call createPiece { pieceId: "#(newPieceId)", poLineId: "#(poLineId)", titleId: "#(titleId)" }

    # 9. Delete piece after having more than one piece for poLine
    Given path 'orders/pieces', pieceId
    When method DELETE
    Then status 204


  Scenario: Delete With Order Status 'Open' and poLine cost quantity '2' and Check Verification for last piece
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid

    # 1. Create order
    * def v = call createOrder { 'id': '#(orderId)' }

    # 2. Create order line with quantity 1 and Receiving Workflow 'Manual'
    * table poLineLocations
      | locationId         | quantity | quantityPhysical |
      | globalLocationsId  | 1        | 1                |
      | globalLocationsId2 | 1        | 1                |
    * def v = call createOrderLine { 'id': '#(poLineId)', 'orderId': '#(orderId)', 'quantity': 2, locations: '#(poLineLocations)', 'checkinItems': false }

    # 3. Open Order
    * def v = call openOrder { 'id': '#(orderId)' }

    # 4. Get Piece by poLineId
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def piece1 = $.pieces[0]
    * def piece2 = $.pieces[1]
    * def pieceId1 = piece1.id
    * def pieceId2 = piece2.id

    # 5. Verify validation for delete Piece with Order Status 'Open'
    Given path 'orders/pieces', pieceId1
    When method DELETE
    Then status 204

    # 6. Verify validation for delete Piece for the last piece for poLine with Receiving workflow status 'Syncronized order and receipt quantity'
    Given path 'orders/pieces', pieceId2
    When method DELETE
    Then status 422
    And match $.errors[0].message == last_piece_error_masage
