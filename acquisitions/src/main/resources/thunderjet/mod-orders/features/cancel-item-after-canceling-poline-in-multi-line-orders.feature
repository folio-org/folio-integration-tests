Feature: Cancel poLine in multi-line order

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * configure readTimeout = 120000

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Cancel poLine in multi-line order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    # 2. Create an order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create po lines
    * def paymentStatus = 'Awaiting Payment'
    * def receiptStatus = 'Partially Received'
    * table lines
      | id        |
      | poLineId1 |
      | poLineId2 |
    * def v = call createOrderLine lines

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Cancel the orderLine
    Given path 'orders/order-lines/', poLineId1
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.paymentStatus = 'Cancelled'
    * set poLine.receiptStatus = 'Cancelled'

    Given path 'orders/order-lines/', poLineId1
    And request poLine
    When method PUT
    Then status 204

    # 6. Check the po lines after cancelling the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def poLines = $.poLines
    * def line1 = poLines[0]
    * match line1.paymentStatus == 'Cancelled'
    * match line1.receiptStatus == 'Cancelled'
    * def line2 = poLines[1]
    * match line2.paymentStatus == 'Awaiting Payment'
    * match line2.receiptStatus == 'Partially Received'

    # 7. Check the item after cancelling the order
    Given path 'orders/order-lines/', poLineId1
    When method GET
    Then status 200
    * def poLine = $

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + poLine.instanceId
    When method GET
    Then status 200
    * def holdings = $.holdingsRecords

    Given path 'inventory/items'
    And param query = 'holdingsRecordId ==' + holdings[0].id
    When method GET
    Then status 200
    * def items = $.items

    * def item = items[0]
    * match item.status.name == 'Order closed'

    * configure headers = headersUser
    Given path 'orders/order-lines/', poLineId2
    When method GET
    Then status 200
    * def poLine2 = $

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId ==' + poLine2.instanceId
    When method GET
    Then status 200
    * def holdings2 = $.holdingsRecords

    Given path 'inventory/items'
    And param query = 'holdingsRecordId ==' + holdings2[0].id
    When method GET
    Then status 200
    * def items2 = $.items

    * def item2 = items2[0]
    * match item2.status.name == 'On order'
