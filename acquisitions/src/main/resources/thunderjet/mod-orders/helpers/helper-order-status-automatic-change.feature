@ignore
Feature: Helper for "close-order-when-fully-paid-and-received"

  Background:
    * url baseUrl

    * def verifyOrderStatusSetup = read('classpath:thunderjet/mod-orders/helpers/helper-order-status-automatic-change.feature@Setup')


  @VerifyOrderStatusAfterPoLinePaymentReceiptUpdate #(initialWorkflowStatus, initialPaymentStatus, initialReceiptStatus, newPaymentStatus, newReceiptStatus, expectedWorkflowStatus)
  Scenario: verifyOrderStatusAfterPoLinePaymentReceiptUpdate
    * print 'VerifyOrderStatusAfterPoLinePaymentReceiptUpdate:: initialWorkflowStatus: ' + initialWorkflowStatus + ', initialPaymentStatus: ' + initialPaymentStatus + ', initialReceiptStatus: ' + initialReceiptStatus + ', newPaymentStatus: ' + newPaymentStatus + ', newReceiptStatus: ' + newReceiptStatus + ', expectedWorkflowStatus: ' + expectedWorkflowStatus
    * call verifyOrderStatusSetup

    # 9. Update poLine statuses
    * def v = call updateOrderLine { id: '#(poLineId)', paymentStatus: '#(newPaymentStatus)', receiptStatus: '#(newReceiptStatus)' }

    # 10. Wait for a potential order status update
    * call pause 100

    # 11. Check order's expected workflow status
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == expectedWorkflowStatus


  @VerifyOrderStatusAfterReceivingChange #(initialWorkflowStatus, initialPaymentStatus, initialReceiptStatus, expectedWorkflowStatus)
  Scenario: verifyOrderStatusAfterReceivingChange
    * print 'VerifyOrderStatusAfterReceivingChange:: initialWorkflowStatus: ' + initialWorkflowStatus + ', initialPaymentStatus: ' + initialPaymentStatus + ', initialReceiptStatus: ' + initialReceiptStatus + ', expectedWorkflowStatus: ' + expectedWorkflowStatus
    * call verifyOrderStatusSetup

    # 9. Receive or unreceive the piece
    * if (newReceiptStatus == 'Fully Received') karate.call('classpath:thunderjet/mod-orders/reusable/receive-piece-with-holding.feature', { pieceId: pieceId, poLineId: poLineId })
    * if (newReceiptStatus == 'Awaiting Receipt') karate.call('classpath:thunderjet/mod-orders/reusable/unreceive-piece-like-ui.feature', { pieceId: pieceId, poLineId: poLineId })

    # 10. Wait for a potential order status update
    * call pause 100

    # 11. Check order's expected workflow status
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == expectedWorkflowStatus


  @Setup #(initialWorkflowStatus, initialPaymentStatus, initialReceiptStatus)
  Scenario: setup
    * def checkinItems = (initialReceiptStatus == 'Receipt Not Required') || (newReceiptStatus == 'Receipt Not Required')

    # 1 Create order and order line
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', checkinItems: '#(checkinItems)' }

    # 2 Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3. Get Piece id
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == checkinItems ? 0 : 1
    * def pieceId = checkinItems ? '' : response.pieces[0].id

    # 4. Receive the piece if initialReceiptStatus is Fully Received
    * if (initialReceiptStatus == 'Fully Received' && !checkinItems) karate.call('classpath:thunderjet/mod-orders/reusable/receive-piece-with-holding.feature', { pieceId: pieceId, poLineId: poLineId })

    # 5. Set po line initial statuses
    * def v = call updateOrderLine { id: '#(poLineId)', paymentStatus: '#(initialPaymentStatus)', receiptStatus: '#(initialReceiptStatus)' }

    # 6. Close order if initialWorkflowStatus is Closed
    * if (initialWorkflowStatus == 'Closed') karate.call('classpath:thunderjet/mod-orders/reusable/close-order.feature', { orderId: orderId })

    # 7. Wait for order's initial workflow status
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == initialWorkflowStatus
    When method GET
    Then status 200

    # 8. Check po line initial statuses have not changed
    Given path '/orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == initialPaymentStatus
    And match response.receiptStatus == initialReceiptStatus
