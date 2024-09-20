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

    # 5. Delete order and PoLine
    * table deleteDetails
      | resourcePath              | resourceId |
      | 'orders/order-lines'      | poLineId   |
      | 'orders/composite-orders' | orderId    |
    * def v = call deleteResource deleteDetails


  Scenario: Closed order should not be reopened when it has at least one resolution status
    # 1.1 Create order and order line
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(globalFundId) }

    # 1.2 Open order and Close order
    * def v = call openOrder { orderId: "#(orderId)" }
    * def v = call closeOrder { orderId: "#(orderId)" }

    # 2 Update poLine payment to resolution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = response
    * set poLineResponse.paymentStatus = 'Fully Paid'

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

    # 3. Check that order is still closed
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Closed'

    # 4. Delete order and PoLine
    * table deleteDetails
      | resourcePath              | resourceId |
      | 'orders/order-lines'      | poLineId   |
      | 'orders/composite-orders' | orderId    |
    * def v = call deleteResource deleteDetails