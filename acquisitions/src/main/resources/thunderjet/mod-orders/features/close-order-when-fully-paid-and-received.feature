Feature: Verify once poline fully paid and received order should be closed

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
    * configure retry = { count: 4, interval: 1000 }

    * callonce variables

    * def verifyOrderStatusAfterPoLinePaymentReceiptUpdate = read('classpath:thunderjet/mod-orders/helpers/helper-close-order-when-fully-paid-and-received.feature@VerifyOrderStatusAfterPoLinePaymentReceiptUpdate')
    
  @Positive
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

  @Positive
  Scenario: Closed order should not be reopened when it has at least one resolved status
    * table orderStatusTestParams
      | expectedWorkflowStatus | paymentStatus          | receiptStatus          | checkinItems |
      | 'Closed'               | 'Fully Paid'           | 'Cancelled'            | false        |
      | 'Closed'               | 'Fully Paid'           | 'Partially Received'   | false        |
      | 'Closed'               | 'Fully Paid'           | 'Receipt Not Required' | true         |
      | 'Closed'               | 'Cancelled'            | 'Fully Received'       | false        |
      | 'Closed'               | 'Payment Not Required' | 'Awaiting Receipt'     | false        |
      | 'Closed'               | 'Partially Paid'       | 'Fully Received'       | false        |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams

  @Positive
  Scenario: Closed order should be reopened when it does not have any resolved statuses
    * table orderStatusTestParams
      | expectedWorkflowStatus | paymentStatus      | receiptStatus        |
      | 'Open'                 | 'Partially Paid'   | 'Awaiting Receipt'   |
      | 'Open'                 | 'Awaiting Payment' | 'Partially Received' |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams