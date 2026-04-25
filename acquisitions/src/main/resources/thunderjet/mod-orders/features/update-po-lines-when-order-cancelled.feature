# For MODORDERS-636, https://foliotest.testrail.io/index.php?/cases/view/353543
Feature: Update PO Lines When Order Is Cancelled

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken
    * call login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * call variables

    # Create fund and budget
    * def fundId = call uuid
    * def budgetId = call uuid
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100000, 'fundId': '#(fundId)', 'status': 'Active' }
    * configure headers = headersUser

    * def createOrderUpdateStatusesAndCancel = read('classpath:thunderjet/mod-orders/helpers/helper-update-po-lines-when-order-cancelled.feature@CreateOrderUpdateStatusesAndCancel')

  @C353543
  @Positive
  Scenario: Update PO Lines When An Order Is Closed With The Cancelled Reason
    * table orderCancelTests
      | initialPaymentStatus   | initialReceiptStatus   | expectedPaymentStatus  | expectedReceiptStatus  | expectedCloseReason | isAutoClosed | checkinItems | fundId   |
      | 'Payment Not Required' | 'Receipt Not Required' | 'Payment Not Required' | 'Receipt Not Required' | 'Complete'          | true         | true         | fundId   |
      | 'Payment Not Required' | 'Fully Received'       | 'Payment Not Required' | 'Fully Received'       | 'Complete'          | true         | false        | fundId   |
      | 'Payment Not Required' | 'Awaiting Receipt'     | 'Payment Not Required' | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Payment Not Required' | 'Partially Received'   | 'Payment Not Required' | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Payment Not Required' | 'Cancelled'            | 'Payment Not Required' | 'Cancelled'            | 'Complete'          | true         | false        | fundId   |
      | 'Payment Not Required' | null                   | 'Payment Not Required' | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Fully Paid'           | 'Fully Received'       | 'Fully Paid'           | 'Fully Received'       | 'Complete'          | true         | false        | fundId   |
      | 'Fully Paid'           | 'Awaiting Receipt'     | 'Fully Paid'           | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Fully Paid'           | 'Partially Received'   | 'Fully Paid'           | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Fully Paid'           | 'Cancelled'            | 'Fully Paid'           | 'Cancelled'            | 'Complete'          | true         | false        | fundId   |
      | 'Fully Paid'           | null                   | 'Fully Paid'           | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Fully Paid'           | 'Receipt Not Required' | 'Fully Paid'           | 'Receipt Not Required' | 'Complete'          | true         | true         | fundId   |
      | 'Partially Paid'       | 'Awaiting Receipt'     | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Partially Paid'       | 'Partially Received'   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Partially Paid'       | 'Cancelled'            | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Partially Paid'       | null                   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Partially Paid'       | 'Receipt Not Required' | 'Cancelled'            | 'Receipt Not Required' | 'Cancelled'         | false        | true         | fundId   |
      | 'Partially Paid'       | 'Fully Received'       | 'Cancelled'            | 'Fully Received'       | 'Cancelled'         | false        | false        | fundId   |
      | 'Cancelled'            | 'Partially Received'   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Cancelled'            | 'Cancelled'            | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | true         | false        | fundId   |
      | 'Cancelled'            | null                   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | 'Cancelled'            | 'Receipt Not Required' | 'Cancelled'            | 'Receipt Not Required' | 'Complete'          | true         | true         | fundId   |
      | 'Cancelled'            | 'Fully Received'       | 'Cancelled'            | 'Fully Received'       | 'Complete'          | true         | false        | fundId   |
      | 'Cancelled'            | 'Awaiting Receipt'     | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | null                   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | null                   | null                   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | null                   | 'Receipt Not Required' | 'Cancelled'            | 'Receipt Not Required' | 'Cancelled'         | false        | true         | fundId   |
      | null                   | 'Fully Received'       | 'Cancelled'            | 'Fully Received'       | 'Cancelled'         | false        | false        | fundId   |
      | null                   | 'Awaiting Receipt'     | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
      | null                   | 'Partially Received'   | 'Cancelled'            | 'Cancelled'            | 'Cancelled'         | false        | false        | fundId   |
    * def v = call createOrderUpdateStatusesAndCancel orderCancelTests
