@parallel=false
# created for https://issues.folio.org/browse/MODORDERS-578
Feature: Open order without creating holdings

  Background:
    * url baseUrl
   # * callonce dev {tenant: 'test_orders6666'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables


  Scenario Outline: Open order and check holdings with orderType = <poLineType> and createInventoryPhysical = <createInventoryPhysical> and createInventoryElectronic = <createInventoryElectronic>
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def locationId = call uuid

    * print 'Create a fund and a budget'
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 5, 'fundId': '#(fundId)'}

    * print 'Create an order'
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

    * print 'Create an order line'
    * def poLine = read('classpath:samples/mod-orders/orderLines/<poLineType>.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.physical.createInventory = <createInventoryPhysical>
    * set poLine.eresource.createInventory = <createInventoryElectronic>
    * set poLine.checkinItems = <isManualPieceCreate>


    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print 'Open the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    * print 'Check the order line'
    Given path 'orders/order-lines', poLineId
    * configure headers = headersUser
    When method GET
    Then status 200
    And match $.locations[0].holdingId == '#notpresent'
    * def instanceId = $.instanceId

    * configure headers = headersAdmin
    * print 'Check holdings with location'
    Given path 'holdings-storage/holdings'
    And param query = 'permanentLocationId==' + locationId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check holdings with instanceId'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Examples:
      | createInventoryPhysical  | createInventoryElectronic  | isManualPieceCreate | poLineType                    |
      | 'None'                   | 'Instance, Holding, Item'  | true                | minimal-order-line            |
      | 'Instance'               | 'Instance, Holding, Item'  | true                | minimal-order-line            |
      | 'None'                   | 'Instance, Holding, Item'  | false               | minimal-order-line            |
      | 'Instance'               | 'Instance, Holding, Item'  | false               | minimal-order-line            |
      | 'Instance, Holding, Item'| 'None'                     | true                | minimal-order-electronic-line |
      | 'Instance, Holding, Item'| 'Instance'                 | true                | minimal-order-electronic-line |
      | 'Instance, Holding, Item'| 'None'                     | false               | minimal-order-electronic-line |
      | 'Instance, Holding, Item'| 'Instance'                 | false               | minimal-order-electronic-line |