# For MODORDERS-1143, MODORDERS-1439
Feature: Order status automatic change caused by a po line update

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

    * callonce variables

    * def verifyOrderStatusAfterPoLinePaymentReceiptUpdate = read('classpath:thunderjet/mod-orders/helpers/helper-order-status-automatic-change.feature@VerifyOrderStatusAfterPoLinePaymentReceiptUpdate')
    
  @Positive
  Scenario: Closed order should not be reopened when a line status is changed to final
    * table orderStatusTestParams
      | initialWorkflowStatus | initialPaymentStatus | initialReceiptStatus | newPaymentStatus       | newReceiptStatus       | expectedWorkflowStatus |
      | 'Closed'              | 'Awaiting Payment'   | 'Awaiting Receipt'   | 'Fully Paid'           | 'Awaiting Receipt'     | 'Closed'               |
      | 'Closed'              | 'Awaiting Payment'   | 'Awaiting Receipt'   | 'Awaiting Payment'     | 'Fully Received'       | 'Closed'               |
      | 'Closed'              | 'Partially Paid'     | 'Partially Received' | 'Cancelled'            | 'Partially Received'   | 'Closed'               |
      | 'Closed'              | 'Awaiting Payment'   | 'Awaiting Receipt'   | 'Awaiting Payment'     | 'Cancelled'            | 'Closed'               |
      | 'Closed'              | 'Awaiting Payment'   | 'Awaiting Receipt'   | 'Awaiting Payment'     | 'Receipt Not Required' | 'Closed'               |
      | 'Closed'              | 'Awaiting Payment'   | 'Partially Received' | 'Payment Not Required' | 'Partially Received'   | 'Closed'               |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams

  @Positive
  Scenario: Closed order should not be reopened when the initial line statuses are non-final (because the order was not closed automatically)
    * table orderStatusTestParams
      | initialWorkflowStatus | initialPaymentStatus | initialReceiptStatus | newPaymentStatus   | newReceiptStatus   | expectedWorkflowStatus |
      | 'Closed'              | 'Fully Paid'         | 'Awaiting Receipt'   | 'Awaiting Payment' | 'Awaiting Receipt' | 'Closed'               |
      | 'Closed'              | 'Awaiting Payment'   | 'Fully Received'     | 'Awaiting Payment' | 'Awaiting Receipt' | 'Closed'               |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams

  @Positive
  Scenario: Closed order should be reopened when line statuses are changed from final to non-final
    * table orderStatusTestParams
      | initialWorkflowStatus | initialPaymentStatus | initialReceiptStatus | newPaymentStatus       | newReceiptStatus       | expectedWorkflowStatus |
      | 'Closed'              | 'Fully Paid'         | 'Fully Received'     | 'Awaiting Payment'     | 'Fully Received'       | 'Open'                 |
      | 'Closed'              | 'Fully Paid'         | 'Fully Received'     | 'Fully Paid'           | 'Awaiting Receipt'     | 'Open'                 |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams

  @Positive
  Scenario: Open order should not be closed when a line status is changed to non-final
    * table orderStatusTestParams
      | initialWorkflowStatus | initialPaymentStatus | initialReceiptStatus | newPaymentStatus       | newReceiptStatus       | expectedWorkflowStatus |
      | 'Open'                | 'Fully Paid'         | 'Awaiting Receipt'   | 'Partially Paid'       | 'Awaiting Receipt'     | 'Open'                 |
      | 'Open'                | 'Awaiting Payment'   | 'Fully Received'     | 'Awaiting Payment'     | 'Partially Received'   | 'Open'                 |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams

  @Positive
  Scenario: Open order should be closed when a status change makes both line statuses final
    * table orderStatusTestParams
      | initialWorkflowStatus | initialPaymentStatus   | initialReceiptStatus   | newPaymentStatus       | newReceiptStatus       | expectedWorkflowStatus |
      | 'Open'                | 'Fully Paid'           | 'Awaiting Receipt'     | 'Fully Paid'           | 'Fully Received'       | 'Closed'               |
      | 'Open'                | 'Awaiting Payment'     | 'Fully Received'       | 'Fully Paid'           | 'Fully Received'       | 'Closed'               |
      | 'Open'                | 'Payment Not Required' | 'Awaiting Receipt'     | 'Payment Not Required' | 'Fully Received'       | 'Closed'               |
      | 'Open'                | 'Awaiting Payment'     | 'Receipt Not Required' | 'Fully Paid'           | 'Receipt Not Required' | 'Closed'               |
    * def v = call verifyOrderStatusAfterPoLinePaymentReceiptUpdate orderStatusTestParams
