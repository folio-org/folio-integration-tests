# For MODORDERS-679, https://foliotest.testrail.io/index.php?/cases/view/350926
Feature: An Open Order With POL And Funds Distribution Can Be Unopened

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

    * def fundId = call uuid
    * def budgetId = call uuid
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }
    * configure headers = headersUser

  @C350926
  @Positive
  Scenario: An Open Order With POL And Funds Distribution Can Be Unopened
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. An Order Without PO Lines Exists In "Pending" Status For An Active Vendor With "Approved" Checked
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time' }

    # 2. Go To The Order Details Pane - Order Details Are Displayed (Pending, No PO Lines)
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Pending'
    And match response.poLines == '#[0]'

    # 3. Add PO Line To The Order And Fill In All Required Fields With Valid Values (Including Fund Distribution)
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 4. Click "Save & Open Order" - Order Moved To "Open" Status With POL Successfully Created
    * def v = call openOrder { orderId: '#(orderId)' }

    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.poLines != null && response.poLines.length == 1 && response.poLines[0].id == poLineId
    When method GET
    Then status 200

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == 'Awaiting Payment'
    And match response.receiptStatus == 'Awaiting Receipt'
    And match response.fundDistribution == '#[1]'
    And match response.fundDistribution[0].fundId == fundId

    # 5. Unopen The Order (Confirm With "Delete Items") - Order Moved Back To "Pending" Status
    * def v = call unopenOrder { orderId: '#(orderId)', deleteHoldings: true }

    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Pending'
    When method GET
    Then status 200

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.paymentStatus == 'Pending'
    And match response.receiptStatus == 'Pending'
    And match response.fundDistribution == '#[1]'
    And match response.fundDistribution[0].fundId == fundId

