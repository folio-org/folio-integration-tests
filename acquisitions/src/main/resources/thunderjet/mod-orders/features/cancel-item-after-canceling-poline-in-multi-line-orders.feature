@parallel=false
Feature: Cancel order

  Background:
    * print karate.info.scenarioName

    * url baseUrl
#    * callonce dev {tenant: 'testorders2'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

  Scenario: Create an order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

  Scenario Outline: Create a po line
    * copy poLine = orderLineTemplate
    * set poLine.id = <poLineId>
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = '<paymentStatus>'
    * set poLine.receiptStatus = '<receiptStatus>'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    Examples:
      | paymentStatus        | receiptStatus        | poLineId  |
      | Awaiting Payment     | Partially Received   | poLineId1 |
      | Awaiting Payment     | Partially Received   | poLineId2 |

  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

  Scenario: Cancel the orderLine
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


  Scenario: Check the po lines after cancelling the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def poLines = $.compositePoLines
    * def line1 = poLines[0]
    * match line1.paymentStatus == 'Cancelled'
    * match line1.receiptStatus == 'Cancelled'
    * def line2 = poLines[1]
    * match line2.paymentStatus == 'Awaiting Payment'
    * match line2.receiptStatus == 'Partially Received'

  Scenario: Check the item after cancelling the order
    Given path 'orders/order-lines/', poLineId1
    When method GET
    Then status 200
    * def poLine = $

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

    Given path 'orders/order-lines/', poLineId2
    When method GET
    Then status 200
    * def poLine2 = $

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