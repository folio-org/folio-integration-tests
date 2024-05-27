Feature: Cancel order

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    # Generate unique UUIDs
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid

    # Define reusable functions
    * def createCompositeOrder               = read('classpath:thunderjet/mod-orders/reusable/create-composite-order.feature')
    * def createOrderLines                   = read('classpath:thunderjet/mod-orders/reusable/create-order-lines.feature')
    * def openOrder                          = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def cancelOrder                        = read('classpath:thunderjet/mod-orders/reusable/cancel-order.feature')
    * def checkOrderLinesAfterCancelingOrder = read('classpath:thunderjet/mod-orders/reusable/check-order-lines-after-cancelling-order.feature')
    * def checkBudgetAfterCancellingOrder    = read('classpath:thunderjet/mod-orders/reusable/check-budget-after-cancelling-order.feature')

  @Positive
  Scenario:
    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    * print '2. Create composite order'
    * call createCompositeOrder { orderId: #(orderId), globalVendorId: #(globalVendorId) }

    * print '3. Create order lines'
    * table statusTable
      | paymentStatus          | receiptStatus          | orderId | fundId |
      | 'Awaiting Payment'     | 'Partially Received'   | orderId | fundId |
      | 'Payment Not Required' | 'Awaiting Receipt'     | orderId | fundId |
      | 'Fully Paid'           | 'Receipt Not Required' | orderId | fundId |
      | 'Partially Paid'       | 'Fully Received'       | orderId | fundId |
    * call createOrderLines statusTable

    * print '4. Open the order'
    * call openOrder { orderId: #(orderId) }

    * print '5. Cancel the order'
    * call cancelOrder { orderId: #(orderId) }

    * print '6. Check the order lines after cancelling the order'
    * call checkOrderLinesAfterCancelingOrder { orderId: #(orderId), fundId: #(fundId) }

    * print '7. Check the budget after cancelling the order'
    * call checkBudgetAfterCancellingOrder { fundId: #(fundId) }