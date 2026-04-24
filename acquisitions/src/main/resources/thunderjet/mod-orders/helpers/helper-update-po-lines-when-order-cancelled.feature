@ignore
Feature: Helper for "update-po-lines-when-order-cancelled"

  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 10000 }

  @CreateOrderUpdateStatusesAndCancel
  Scenario: Create open order, set PO line statuses, cancel order, and verify final statuses
    * def initialPaymentStatus = karate.get('initialPaymentStatus', null)
    * def initialReceiptStatus = karate.get('initialReceiptStatus', null)

    # 1. Create order and order line
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', checkinItems: '#(checkinItems)' }

    # 2. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3. Update PO line to the desired payment/receipt statuses
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = response
    * set poLine.paymentStatus = initialPaymentStatus
    * set poLine.receiptStatus = initialReceiptStatus
    * set poLine.checkinItems = checkinItems

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    * call pause 100

    # 4. Verify order status after POL update and cancel if not auto-closed
    * def expectedStatusAfterUpdate = isAutoClosed ? 'Closed' : 'Open'
    * def validateOrderStatusAfterUpdate =
    """
    function(response) {
      return response.workflowStatus == expectedStatusAfterUpdate;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderStatusAfterUpdate(response)
    When method GET
    Then status 200

    * if (!isAutoClosed) karate.call('classpath:thunderjet/mod-orders/reusable/cancel-order.feature', { orderId: orderId })

    # 5. Verify the resulting PO line statuses
    * def validatePoLineStatuses =
    """
    function(response) {
      return response.paymentStatus == expectedPaymentStatus &&
             response.receiptStatus == expectedReceiptStatus;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until validatePoLineStatuses(response)
    When method GET
    Then status 200

    # 6. Verify the order close reason
    * def validateOrderClosed =
    """
    function(response) {
      return response.workflowStatus == 'Closed' &&
             response.closeReason != null &&
             response.closeReason.reason == expectedCloseReason;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderClosed(response)
    When method GET
    Then status 200
