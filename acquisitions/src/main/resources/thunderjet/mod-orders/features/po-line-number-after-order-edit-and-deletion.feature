# For MODINVOICE-647, https://foliotest.testrail.io/index.php?/cases/view/1621483, https://foliotest.testrail.io/index.php?/cases/view/1621484
Feature: PO Line Number After Order Edit And Deletion

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


  @C1621483
  @Positive
  Scenario: PO Line Number Is Not Reused After The Order Is Edited And Its Last PO Line Is Deleted
    # 1. Generate Unique Identifiers For This Test Scenario
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid

    # 2. Create A Pending Order With PO Lines 1 And 2
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId)' }

    # 3. Check The Next PO Line Number Of The Order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.nextPolNumber == 3
    * def poNumber = $.poNumber

    # 4. Edit The Order And Save It
    * def v = call updateOrder { id: '#(orderId)', reEncumber: true }
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.reEncumber == true
    And match $.nextPolNumber == 3

    # 5. Delete PO Line 2
    Given path 'orders/order-lines', poLineId2
    When method DELETE
    Then status 204
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.nextPolNumber == 3

    # 6. Add A New PO Line And Check That Number 2 Is Not Reused
    * def v = call createOrderLine { id: '#(poLineId3)', orderId: '#(orderId)' }
    * call getOrderLine { poLineId: '#(poLineId3)' }
    And match poLine.poLineNumber == poNumber + '-3'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.nextPolNumber == 4


  @C1621484
  @Positive
  Scenario: Changing The Next PO Line Number Of An Order Through The API Is Ignored
    # 1. Generate Unique Identifiers For This Test Scenario
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    # 2. Create A Pending Order With PO Line 1
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId)' }

    # 3. Check The Next PO Line Number Of The Order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.nextPolNumber == 2
    * def order = $
    * def poNumber = order.poNumber
    * remove order.poLines

    # 4. Update The Order With Next PO Line Number 1
    # Silently ignored since MODINVOICE-647; MODORDERS-1445 may turn this into a validation error
    * set order.nextPolNumber = 1
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    # 5. Check That The Next PO Line Number Is Unchanged
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.nextPolNumber == 2

    # 6. Update The Order Without The Next PO Line Number And Check It Is Unchanged
    * remove order.nextPolNumber
    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.nextPolNumber == 2

    # 7. Add A New PO Line And Check Its Number
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId)' }
    * call getOrderLine { poLineId: '#(poLineId2)' }
    And match poLine.poLineNumber == poNumber + '-2'
