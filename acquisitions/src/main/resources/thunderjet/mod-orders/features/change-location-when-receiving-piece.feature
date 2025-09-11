# For MODORDERS-616
@parallel=false
Feature: Change location when receiving a piece

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * def headersAdmin = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenAdmin)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }

    * callonce variables
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: Change location when receiving a piece
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid

    # 1. Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { "id": "#(fundId)" }
    * call createBudget { "id": "#(budgetId)", "allocated": 10000, "fundId": "#(fundId)" }
    * configure headers = headersUser

    # 2. Create an order
    Given path "orders/composite-orders"
    And request
    """
    {
      id: "#(orderId)",
      vendor: "#(globalVendorId)",
      orderType: "One-Time"
    }
    """
    When method POST
    Then status 201

    # 3. Create an order line
    * def poLine = read("classpath:samples/mod-orders/orderLines/minimal-order-line.json")
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = "Instance, Holding, Item"
    * set poLine.fundDistribution[0].fundId = fundId

    Given path "orders/order-lines"
    And request poLine
    When method POST
    Then status 201

    # 4. Open the order
    Given path "orders/composite-orders", orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path "orders/composite-orders", orderId
    And request orderResponse
    When method PUT
    Then status 204

    # 5. Receive the piece with a new location
    # Get the id of piece created when the order was opened
    Given path "orders/pieces"
    And param query = "poLineId==" + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    # Receive it
    Given path "orders/check-in"
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId)",
              itemStatus: "In process",
              locationId: "#(globalLocationsId2)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # 6.  Get piece holdingId
    Given path "orders/pieces", pieceId
    And retry until response.holdingId != null
    When method GET
    Then status 200
    * def pieceHoldingId = $.holdingId

    # 7. Get the instanceId from the po line
    Given path "orders/order-lines", poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId

    # 8. Check the piece holdingId is the same as the id of the holding for the new location
    * configure headers = headersAdmin
    Given path "holdings-storage/holdings"
    And param query = "instanceId==" + instanceId + " and permanentLocationId==" + globalLocationsId2
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.holdingsRecords[0].id == pieceHoldingId
