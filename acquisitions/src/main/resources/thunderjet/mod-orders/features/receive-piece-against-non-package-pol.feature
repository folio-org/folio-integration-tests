@parallel=false
# for https://issues.folio.org/browse/MODORDERS-519
Feature: Receive piece against non-package POL

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def pieceId1 = callonce uuid5
    * def pieceId2 = callonce uuid6


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }


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


  Scenario: Create an order line with isPackage=false
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.isPackage = false
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.fundDistribution[0].fundId = fundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    And match $.instanceId == '#notpresent'


  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # Check the order line now has an instanceId
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#notnull'

    # Check a piece was created when the order was opened
    # NOTE: this is strange to call orders-storage, but the UI is doing it too
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'
    And match $.pieces[0].itemId == '#notnull'


  Scenario: Create piece 1
    # we need to get the title id first
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId1)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201


  Scenario: Receive piece 1
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId1)",
              itemStatus: "In process",
              displayOnHolding: false,
              enumeration: "#(pieceId1)",
              chronology: "#(pieceId1)",
              supplement: true,
              discoverySuppress: true,
              locationId: "#(globalLocationsId)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # Check piece 1 receivingStatus
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.displayOnHolding == false
    And match $.enumeration == "#(pieceId1)"
    And match $.chronology == "#(pieceId1)"
    And match $.supplement == true
    And match $.discoverySuppress == true
    And match $.displayOnHolding == false

  Scenario: Create piece 2
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId2)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201


  Scenario: Receive piece 2
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId2)",
              itemStatus: "In process",
              locationId: "#(globalLocationsId)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # Check piece 2 receivingStatus
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'


  Scenario: Unreceive piece 1
    Given path 'orders/receive'
    And request
    """
    {
      toBeReceived: [
        {
          "poLineId": "#(poLineId)",
          "received": 1,
          "receivedItems": [
            {
              "itemStatus": "On order",
              "pieceId": "#(pieceId1)"
            }
          ]
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # Check the unreceived piece status
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.receivingStatus == 'Expected'

