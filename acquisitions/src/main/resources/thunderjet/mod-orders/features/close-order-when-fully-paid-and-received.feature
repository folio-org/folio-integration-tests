Feature: Verify once poline fully paid and received order should be closed

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser
    * configure retry = { count: 4, interval: 1000 }

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')


  Scenario: Close order when fully paid and received
    # 1. Create order, order line and open order
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(globalFundId) }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 2 Get poLine and update payment and receipt status to resolution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLineResponse = response
    * set poLineResponse.paymentStatus = 'Fully Paid'
    * set poLineResponse.receiptStatus = 'Fully Received'

    # 3. PUT updated PoLine
    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

    # 4. Check that order closed
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Closed'
    When method GET
    Then status 200
    And match response.workflowStatus == 'Closed'

    # 5. Check the encumbrance was released
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 6. Delete order and PoLine
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

    Given path 'orders/composite-orders', orderId
    When method DELETE
    Then status 204


  Scenario: Closed order should not be reopened when it has at least one resolution status
    # 1. Create order, order line and open order
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(globalFundId) }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 2. Close order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = response
    * set order.workflowStatus = 'Closed'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # 3 Get poLine and update payment to resolution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLineResponse = response
    * set poLineResponse.paymentStatus = 'Fully Paid'

    # 3. PUT updated PoLine
    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

    # 4. Check that order is still closed
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Closed'

    # 5. Delete order and PoLine
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

    Given path 'orders/composite-orders', orderId
    When method DELETE
    Then status 204