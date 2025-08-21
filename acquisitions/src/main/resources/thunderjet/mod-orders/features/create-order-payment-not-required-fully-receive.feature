# For FAT-21348, https://foliotest.testrail.io/index.php?/cases/view/743
Feature: Create Order Payment Not Required Fully Receive

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Create Order With Payment Not Required And Fully Receive
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)", name: "Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 1000, fundId: "#(fundId)", status: "Active" }

    # 2. Create Order And Order Line
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)" }

    # 3. Verify Order Line Is Physical Resource
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.orderFormat == 'Physical Resource'
    And match response.cost.quantityPhysical == 1

    # 4. Set Payment Not Required On The Order Line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLineResponse = response
    * set poLineResponse.paymentStatus = 'Payment Not Required'
    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

    # 5. Open Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 6. Verify Order Is Open
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Open'
    And match each response.poLines[*].paymentStatus == 'Payment Not Required'

    # 7. Verify Piece Is Created With Expected Status
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def pieces = response.pieces
    * def pieceId = pieces[0].id
    And match pieces == '#[1]'
    And match each pieces[*].receivingStatus == 'Expected'

    # 8. Receive Piece
    * def v = call receivePieceWithHolding { pieceId: "#(pieceId)", poLineId: "#(poLineId)" }

    # 9. Verify Piece Status Is Set To Received
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.pieces != null && response.pieces.length > 0 && response.pieces[0].receivingStatus == 'Received'
    When method GET
    Then status 200

    # 10. Verify Order Status After Fully Receiving - Should Close Automatically
    * def isOrderFullyClosedWithComplete =
    """
    function(response) {
      return response.workflowStatus == 'Closed' &&
             response.closeReason != null &&
             response.closeReason.reason == 'Complete'
             response.poLines != null &&
             response.poLines.length > 0 &&
             response.poLines[0].paymentStatus == 'Payment Not Required' &&
             response.poLines[0].receiptStatus == 'Fully Received'
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until isOrderFullyClosedWithComplete(response)
    When method GET
    Then status 200
