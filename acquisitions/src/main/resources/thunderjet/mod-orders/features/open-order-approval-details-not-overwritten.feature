# For MODORDERS-1458, https://foliotest.testrail.io/index.php?/cases/view/1621341, https://foliotest.testrail.io/index.php?/cases/view/1621342
Feature: Approval Details Are Not Overwritten When Opening An Order

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
    * configure retry = { count: 10, interval: 500 }

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }
    * configure headers = headersUser


  @C1621341
  @Positive
  Scenario: Approval Details Set On First Opening Are Kept After The Order Is Unopened And Opened Again
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create A Pending Order With One PO Line And No Approval Details
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Pending'
    And match $.approvalDate == '##null'
    And match $.approvedById == '##null'

    # 2. Open The Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3. Approval Details Are Set On First Opening
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.approvalDate != null && response.approvedById != null
    When method GET
    Then status 200
    * def initialApprovalDate = response.approvalDate
    * def initialApprovedById = response.approvedById

    # 4. Unopen The Order
    * def v = call unopenOrder { orderId: '#(orderId)', deleteHoldings: true }

    # 5. Approval Details Are Kept After Unopening
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Pending'
    When method GET
    Then status 200

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.approvalDate == initialApprovalDate
    And match $.approvedById == initialApprovedById

    # 6. Open The Order Again
    * def v = call openOrder { orderId: '#(orderId)' }

    # 7. Approval Details Still Contain The Values From The First Opening
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open'
    When method GET
    Then status 200

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.approvalDate == initialApprovalDate
    And match $.approvedById == initialApprovedById


  @C1621342
  @Positive
  Scenario: Approval Date Set On A Pending Order Is Not Overwritten When The Order Is Opened
    * def orderId = call uuid
    * def poLineId = call uuid

    # Prerequisites: Pending Order With One PO Line
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 1. Approve The Order With An Explicit Approval Date
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def order = response
    * set order.approved = true
    * set order.approvalDate = '2026-01-15T10:00:00.000+00:00'
    * remove order.approvedById
    * remove order.poLines

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # 2. Approval Date Is Stored And Approved By Is Empty
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Pending'
    And match $.approved == true
    And match $.approvalDate contains '2026-01-15T10:00:00'
    And match $.approvedById == '##null'
    * def presetApprovalDate = response.approvalDate

    # 3. Open The Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Approval Date Is Kept And Approved By Is Set To The Opening User
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open'
    When method GET
    Then status 200

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.approved == true
    And match $.approvalDate == presetApprovalDate
    And match $.approvedById == '#uuid'
