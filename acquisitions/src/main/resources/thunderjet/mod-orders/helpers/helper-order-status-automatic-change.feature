@ignore
Feature: Helper for "close-order-when-fully-paid-and-received"

  Background:
    * url baseUrl

  @VerifyOrderStatusAfterPoLinePaymentReceiptUpdate #(initialWorkflowStatus, initialPaymentStatus, initialReceiptStatus, newPaymentStatus, newReceiptStatus, expectedWorkflowStatus)
  Scenario: verifyOrderStatusAfterPoLinePaymentReceiptUpdate
    * print 'VerifyOrderStatusAfterPoLinePaymentReceiptUpdate:: initialWorkflowStatus: ' + initialWorkflowStatus + ', initialPaymentStatus: ' + initialPaymentStatus + ', initialReceiptStatus: ' + initialReceiptStatus + ', newPaymentStatus: ' + newPaymentStatus + ', newReceiptStatus: ' + newReceiptStatus + ', expectedWorkflowStatus: ' + expectedWorkflowStatus

    * def checkinItems = (initialReceiptStatus == 'Receipt Not Required') || (newReceiptStatus == 'Receipt Not Required')

    # 1 Create order and order line
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', checkinItems: '#(checkinItems)' }

    # 2 Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3. Set po line initial statuses
    * def v = call updateOrderLine { id: '#(poLineId)', paymentStatus: '#(initialPaymentStatus)', receiptStatus: '#(initialReceiptStatus)' }

    # 4. Close order if initialWorkflowStatus is Closed
    * if (initialWorkflowStatus == 'Closed') karate.call('classpath:thunderjet/mod-orders/reusable/close-order.feature', { orderId: orderId })

    # 5. Wait for order's initial workflow status
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == initialWorkflowStatus
    When method GET
    Then status 200

    # 6. Check po line initial statuses have not changed
    Given path '/orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == initialPaymentStatus
    And match response.receiptStatus == initialReceiptStatus

    # 7. Update poLine statuses
    * def v = call updateOrderLine { id: '#(poLineId)', paymentStatus: '#(newPaymentStatus)', receiptStatus: '#(newReceiptStatus)' }

    # 8. Wait for a potential order status update
    * call pause 100

    # 9. Check order's expected workflow status
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == expectedWorkflowStatus

    # 10. Delete order and PoLine
    * table deleteDetails
      | resourcePath              | resourceId |
      | 'orders/order-lines'      | poLineId   |
      | 'orders/composite-orders' | orderId    |
    * def v = call deleteResource deleteDetails
