@parallel=false
# for https://issues.folio.org/browse/MODORDERS-699
Feature: Cancel and delete order

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * call variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def fundId = call uuid1
    * def budgetId = call uuid2
    * def orderId = call uuid3
    * def poLineId1 = call uuid4
    * def poLineId2 = call uuid5


  Scenario: Cancel & Delete Order
    * print '## Prepare finances'
    * def v = call createFund { id: "#(fundId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000 }


    * print '## Create an order'
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
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0
