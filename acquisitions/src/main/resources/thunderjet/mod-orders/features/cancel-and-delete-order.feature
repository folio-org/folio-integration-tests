# For MODORDERS-699
Feature: Cancel and delete order

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

    * call variables


  Scenario: Cancel & Delete Order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000 }

    # 2. Create an order
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }

    # 3. Create order lines
    * def v = call createOrderLine { id: "#(poLineId1)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * def v = call createOrderLine { id: "#(poLineId2)", orderId: "#(orderId)", fundId: "#(fundId)" }

    # 4. Open the order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Cancel the order
    * def v = call cancelOrder { orderId: '#(orderId)' }

    # 6. Delete the order
    Given  path 'orders/composite-orders/', orderId
    When method DELETE
    Then status 204

    # 7. Check the encumbrances were deleted
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0
