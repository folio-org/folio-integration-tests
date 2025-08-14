# For MODEBSNET-77
Feature: Close Order With Order Line

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Close Order With Order Line (using type=non-renewal)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid

    # 1. Prepare Finance
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    # 2. Create Order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create Order lines
    * table statusTable
      | id          | paymentStatus      | receiptStatus      | checkinItems |
      | orderLineId | 'Awaiting Payment' | 'Awaiting Receipt' | false        |
    * def v = call createOrderLine statusTable

    # 4. Open Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Set Order Line Wokflow Status to "Closed"
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def poLineNumber = $.poLineNumber
    * def delimiter = poLineNumber.lastIndexOf("-")
    * def poNumber = poLineNumber.substr(0, delimiter)

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    * def ebsconetLine = $
    * set ebsconetLine.type = 'non-renewal'

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    And request ebsconetLine
    When method PUT
    Then status 204

    # 6. Check Order
    Given path "orders/composite-orders"
    And param query = "poNumber==" + poNumber
    And retry until response.purchaseOrders != null && response.purchaseOrders.length == 1 && response.purchaseOrders[0].workflowStatus == "Closed"
    When method GET
    Then status 200

    # 7. Check Order Line
    Given path "orders/order-lines"
    And param query = "poLineNumber==" + poLineNumber
    When method GET
    Then status 200
    And match $.poLines == "#[1]"
    And match each $.poLines[*].paymentStatus == karate.get("paymentStatus", "Cancelled")
    And match each $.poLines[*].receiptStatus == karate.get("receiptStatus", "Cancelled")
    And match each $.poLines[*].checkinItems == karate.get("checkinItems", false)

  @Positive
  Scenario: Close Order With Order Line (using workFlowStatus=Closed)
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid

    # 1. Prepare Finance
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    # 2. Create Order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create Order lines
    * table statusTable
      | id          | paymentStatus      | receiptStatus      | checkinItems |
      | orderLineId | 'Awaiting Payment' | 'Awaiting Receipt' | false        |
    * def v = call createOrderLine statusTable

    # 4. Open Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Set Order Line Wokflow Status to "Closed"
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def poLineNumber = $.poLineNumber
    * def delimiter = poLineNumber.lastIndexOf("-")
    * def poNumber = poLineNumber.substr(0, delimiter)

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    When method GET
    Then status 200
    * def ebsconetLine = $
    * set ebsconetLine.workflowStatus = 'Closed'

    Given path 'ebsconet/orders/order-lines/' + poLineNumber
    And request ebsconetLine
    When method PUT
    Then status 204

    # 6. Check Order
    Given path "orders/composite-orders"
    And param query = "poNumber==" + poNumber
    And retry until response.purchaseOrders != null && response.purchaseOrders.length == 1 && response.purchaseOrders[0].workflowStatus == "Closed"
    When method GET
    Then status 200

    # 7. Check Order Line
    Given path "orders/order-lines"
    And param query = "poLineNumber==" + poLineNumber
    When method GET
    Then status 200
    And match $.poLines == "#[1]"
    And match each $.poLines[*].paymentStatus == karate.get("paymentStatus", "Cancelled")
    And match each $.poLines[*].receiptStatus == karate.get("receiptStatus", "Cancelled")
    And match each $.poLines[*].checkinItems == karate.get("checkinItems", false)