# For MODORDERS-369
Feature: Update purchase order with order lines

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

  @Positive
  Scenario: Update purchase order with order lines
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    ### 1. Create fund and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }
    * configure headers = headersUser

    ### 2. Create orders and order lines
    * def ongoingObj = { "interval": 123, "isSubscription": true, "renewalDate": "2022-05-08T00:00:00.000+00:00" }
    * table orders
      | id       | orderId  | orderType  | ongoing    |
      | orderId1 | orderId1 | 'One-Time' | null       |
      | orderId2 | orderId2 | 'Ongoing'  | ongoingObj |
    * def v = call createOrder orders

    * table orderLines
      | id        | orderId  | orderType  | listUnitPrice |
      | poLineId1 | orderId1 | 'One-Time' | 50.0          |
      | poLineId2 | orderId2 | 'Ongoing'  | 50.0          |
    * def v = call createOrderLine orderLines

    ### 3. Open orders
    * def v = call openOrder orders

    ### 4. Validate composite orders after opening
    * table ordersToValidate
      | id       | workflowStatus | titleOrPackage | paymentStatus      | receiptStatus      |
      | orderId1 | 'Open'         | 'test'         | 'Awaiting Payment' | 'Awaiting Receipt' |
      | orderId2 | 'Open'         | 'test'         | 'Ongoing'          | 'Ongoing'          |
    * def v = call validateCompositeOrders ordersToValidate

    ### 5. Update order lines with cancelled statuses
    # order workflow status is affected (async processing)
    * table orderLinesUpdated
      | id        | titleOrPackage  | paymentStatus | receiptStatus |
      | poLineId1 | 'testCancelled' | 'Cancelled'   | 'Cancelled'   |
      | poLineId2 | 'testCancelled' | 'Cancelled'   | 'Cancelled'   |
    * def v = call updateOrderLine orderLinesUpdated

    ### 6. Validate composite orders after order line update
    * table compositeOrdersToValidate
      | id       | workflowStatus | titleOrPackage  | paymentStatus | receiptStatus |
      | orderId1 | 'Closed'       | 'testCancelled' | 'Cancelled'   | 'Cancelled'   |
      | orderId2 | 'Closed'       | 'testCancelled' | 'Cancelled'   | 'Cancelled'   |
    * def v = call validateCompositeOrders compositeOrdersToValidate

