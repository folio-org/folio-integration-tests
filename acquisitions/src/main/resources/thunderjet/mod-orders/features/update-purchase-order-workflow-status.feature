# For MODORDERS-369
Feature: Update purchase order workflow status

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

  @Positive
  Scenario: Update purchase order workflow status
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

    ### 2. Create orders and order lines
    * configure headers = headersUser
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

    ### 5. Update orders workflow status with Pending (i.e. unopen)
    # affects order line statuses (sync processing)
    * table ordersUpdated
      | id       | workflowStatus |
      | orderId1 | 'Pending'      |
      | orderId2 | 'Pending'      |
    * def v = call updateOrder ordersUpdated

    ### 6. Validate composite orders that only order workflow status is updated
    * table ordersToValidate
      | id       | workflowStatus | titleOrPackage | paymentStatus | receiptStatus |
      | orderId1 | 'Pending'      | 'test'         | 'Pending'     | 'Pending'     |
      | orderId2 | 'Pending'      | 'test'         | 'Pending'     | 'Pending'     |
    * def v = call validateCompositeOrders ordersToValidate

    ### 7. Update orders workflow status with Closed
    # does not affect order line statuses
    * table ordersUpdated
      | id       | workflowStatus |
      | orderId1 | 'Closed'       |
      | orderId2 | 'Closed'       |
    * def v = call updateOrder ordersUpdated

    ### 8. Validate composite orders again that only order workflow status is updated
    * table ordersToValidate
      | id       | workflowStatus | titleOrPackage | paymentStatus | receiptStatus |
      | orderId1 | 'Closed'       | 'test'         | 'Pending'     | 'Pending'     |
      | orderId2 | 'Closed'       | 'test'         | 'Pending'     | 'Pending'     |
    * def v = call validateCompositeOrders ordersToValidate

