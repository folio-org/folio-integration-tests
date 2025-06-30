@ignore
Feature: Helper for "close-order-when-fully-paid-and-received"

  Background:
    * url baseUrl

  @VerifyOrderStatusAfterPoLinePaymentReceiptUpdate #(expectedWorkflowStatus, paymentStatus, receiptStatus)
  Scenario: verifyOrderStatusAfterPoLinePaymentReceiptUpdate
    * print 'VerifyOrderStatusAfterPoLinePaymentReceiptUpdate:: expectedWorkflowStatus: ' + expectedWorkflowStatus + ', paymentStatus: ' + paymentStatus + ', receiptStatus: ' + receiptStatus

    # 1.1 Create order and order line
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(globalFundId), paymentStatus: 'Awaiting Payment', receiptStatus: 'Awaiting Receipt' }

    # 1.2 Open order and Close order
    * def v = call openOrder { orderId: "#(orderId)" }
    * def v = call closeOrder { orderId: "#(orderId)" }

    # 2 Update poLine payment to resolution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = response
    * set poLineResponse.paymentStatus = paymentStatus
    * set poLineResponse.receiptStatus = receiptStatus
    * set poLineResponse.checkinItems = karate.get('checkinItems', poLineResponse.checkinItems)

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

    # 3. Check order's expected workflow status
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == expectedWorkflowStatus
    When method GET
    Then status 200
    And match response.workflowStatus == expectedWorkflowStatus

    # 4. Delete order and PoLine
    * table deleteDetails
      | resourcePath              | resourceId |
      | 'orders/order-lines'      | poLineId   |
      | 'orders/composite-orders' | orderId    |
    * def v = call deleteResource deleteDetails