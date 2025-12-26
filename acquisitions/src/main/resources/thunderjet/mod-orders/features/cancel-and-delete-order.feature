# For MODORDERS-699
@parallel=false
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

    * def fundId = call uuid1
    * def budgetId = call uuid2
    * def orderId = call uuid3
    * def poLineId1 = call uuid4
    * def poLineId2 = call uuid5


  Scenario: Cancel & Delete Order
    * print '## Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000 }


    * print '## Create an order'
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }


    * print '## Create order lines'
    * def v = call createOrderLine { id: "#(poLineId1)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * def v = call createOrderLine { id: "#(poLineId2)", orderId: "#(orderId)", fundId: "#(fundId)" }


    * print '## Open the order'
    * def v = call openOrder { orderId: "#(orderId)" }


    * print '## Cancel the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Closed'
    * set order.closeReason = { reason: 'Cancelled' }

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


    * print '## Delete the order'
    Given  path 'orders/composite-orders/', orderId
    When method DELETE
    Then status 204


    * print '## Check the encumbrances were deleted'
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0
