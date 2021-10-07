@parallel=false
# created for https://issues.folio.org/browse/MODORDERS-578
Feature: Open order without creating holdings

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables


  Scenario Outline: Open order and check holdings with createInventory = <createInventory>
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def locationId = call uuid

    * print 'Create a fund and a budget'
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 5, 'fundId': '#(fundId)'}

    * print 'Create a new location'
    Given path 'locations'
    And request
    """
    {
        "id": "#(locationId)",
        "name": "<locationCode>",
        "code": "<locationCode>",
        "isActive": true,
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [
            "3a40852d-49fd-4df2-a1f9-6e2641a6e91f"
        ]
    }
    """
    When method POST
    Then status 201
    * configure headers = headersUser

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
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.physical.createInventory = <createInventory>
    * set poLine.eresource.createInventory = <createInventory>
    * set poLine.locations[0].locationId = locationId

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
      | createInventory | locationCode |
      | 'None'          | 'TESTLOC1'   |
      | 'Instance'      | 'TESTLOC2'   |
