# For C422159, https://foliotest.testrail.io/index.php?/cases/view/422159
Feature: Delete One Piece After Receiving

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
  Scenario: Delete One Piece After Receiving And Verify Quantity Update
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Fund And Budget
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)", name: "Test Fund For Piece Deletion" }
    * def v = call createBudget { id: "#(budgetId)", allocated: 1000, fundId: "#(fundId)", status: "Active" }

    # 2. Create Order And Order Line With Quantity 1 Initially
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", quantity: 1 }

    # 3. Verify Order Line Has Quantity 1 Initially
    Given path 'orders/order-lines', poLineId
    And retry until response.orderFormat == 'Physical Resource' && response.cost.quantityPhysical == 1
    When method GET
    Then status 200

    # 4. Open Order To Set Receiving Workflow
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Unopen Order To Edit Quantity
    * def v = call unopenOrder { orderId: "#(orderId)" }

    # 6. Edit Order Line To Increase Quantity From 1 To 2
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLineResponse = response
    * set poLineResponse.cost.quantityPhysical = 2
    * set poLineResponse.locations[0].quantityPhysical = 2
    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

    # 7. Verify Order Line Quantity Updated To 2
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.cost.quantityPhysical == 2

    # 8. Reopen Order After Editing
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 9. Verify Order Is Open
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Open'

    # 10. Get Title Information For Navigation Verification
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def titleId = response.titles[0].id
    * def titleName = response.titles[0].title

    # 11. Verify Two Pieces Were Created In Expected Status
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def pieces = response.pieces
    And match pieces == '#[2]'
    And match each pieces[*].receivingStatus == 'Expected'
    And match each pieces[*].titleId == titleId
    * def pieceToDeleteId = pieces[0].id

    # 12. Delete The First Piece
    Given path 'orders/pieces', pieceToDeleteId
    When method DELETE
    Then status 204

    # 13. Verify Piece Was Deleted
    Given path 'orders/pieces', pieceToDeleteId
    When method GET
    Then status 404

    # 14. Verify Only One Piece Remains
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def remainingPieces = response.pieces
    And match remainingPieces == '#[1]'
    And match each remainingPieces[*].receivingStatus == 'Expected'
    And match each remainingPieces[*].titleId == titleId

    # 15. Verify PO Line Details: Quantity Changed From 2 To 1
    Given path 'orders/order-lines', poLineId
    And retry until response.cost.quantityPhysical == 1 && response.orderFormat == 'Physical Resource'
    When method GET
    Then status 200

    # 16. Verify Order Workflow Status Remains Open
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Open'
