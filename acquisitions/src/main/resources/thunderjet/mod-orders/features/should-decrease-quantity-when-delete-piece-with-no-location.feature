@parallel=false
Feature: Should decrease quantity when delete piece with no location

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testorders1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def orderIdForPhysicalQuantity = callonce uuid1
    * def orderIdForElectronicQuantity = callonce uuid2
    * def poLineIdWithPhysicalQuantity = callonce uuid3
    * def poLineIdWithElectronicQuantity = callonce uuid4
    * def pieceIdForPhysicalQuantity = callonce uuid5
    * def pieceIdForElectronicQuantity = callonce uuid6

  Scenario: Create composite order for physical quantity
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderIdForPhysicalQuantity)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

  Scenario: Create composite order for electronic quantity
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderIdForElectronicQuantity)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

    Given path 'orders/composite-orders', orderIdForPhysicalQuantity
    When method GET
    Then status 200

    * def orderResponse = $
    And match orderResponse.approved == false
    And match orderResponse.workflowStatus == "Pending"

  Scenario: Create order line for physical quantity
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineIdWithPhysicalQuantity
    * set orderLine.purchaseOrderId = orderIdForPhysicalQuantity
    * set orderLine.physical.createInventory = "None"
    * remove orderLine.locations

    And request orderLine
    When method POST
    Then status 201
    * def orderPhysicalLineResponse = $
    And match orderPhysicalLineResponse.checkinItems == false
    And match orderPhysicalLineResponse.locations == [ ]
    And match orderPhysicalLineResponse.paymentStatus == "Pending"
    And match orderPhysicalLineResponse.physical.createInventory == "None"

  Scenario: Create order line for electronic quantity
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.orderFormat = "Electronic Resource"
    * set orderLine.cost.quantityElectronic = "1"
    * set orderLine.cost.listUnitPriceElectronic = "1"
    * set orderLine.id = poLineIdWithElectronicQuantity
    * set orderLine.purchaseOrderId = orderIdForElectronicQuantity
    * set orderLine.eresource.createInventory = "None"
    * remove orderLine.locations
    * remove orderLine.cost.quantityPhysical
    * remove orderLine.cost.listUnitPrice
    * remove orderLine.physical

    And request orderLine
    When method POST
    Then status 201

  Scenario: Open order for physical quantity
    Given path 'orders/composite-orders', orderIdForPhysicalQuantity
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderIdForPhysicalQuantity
    And request orderResponse
    When method PUT
    Then status 204

    Given path 'orders/composite-orders', orderIdForPhysicalQuantity
    And request orderResponse
    When method GET
    Then status 200
    * def orderResponse = $
    And match orderResponse.workflowStatus == "Open"

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineIdWithPhysicalQuantity
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'

  Scenario: Open order for electronic quantity
    Given path 'orders/composite-orders', orderIdForElectronicQuantity
    When method GET
    Then status 200

    * def orderResponseElectronic = $
    * set orderResponseElectronic.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderIdForElectronicQuantity
    And request orderResponseElectronic
    When method PUT
    Then status 204

    Given path 'orders/composite-orders', orderIdForElectronicQuantity
    And request orderResponseElectronic
    When method GET
    Then status 200
    * def orderResponse = $
    And match orderResponse.workflowStatus == "Open"

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineIdWithElectronicQuantity
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'

     #-- DELETE Physical piece -- #
  Scenario: Delete piece with physical quantity
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineIdWithPhysicalQuantity
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'
    * def physicalPieceId = $.pieces[0].id

    Given path '/orders/pieces', physicalPieceId
    * configure headers = headersUser
    When method DELETE
    Then status 204

    * print 'Check Physical piece should be deleted'
    Given path 'orders/pieces', physicalPieceId
    * configure headers = headersUser
    When method GET
    Then status 404
    * call pause 2000


  Scenario: Delete piece with electronic quantity
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineIdWithElectronicQuantity
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'
    * def electronicPieceId = $.pieces[0].id

    Given path '/orders/pieces', electronicPieceId
    * configure headers = headersUser
    When method DELETE
    Then status 204

    * print 'Check Electronic piece should be deleted'
    Given path 'orders/pieces', electronicPieceId
    * configure headers = headersUser
    When method GET
    Then status 404
    * call pause 2000

  Scenario: Check physical quantity decreased to 0
    Given path 'orders/order-lines', poLineIdWithPhysicalQuantity
    When method GET
    Then status 200
    And match $.cost.listUnitPrice == 1.0
    And match $.cost.quantityPhysical == 0
    * call pause 2000

  Scenario: Check electronic quantity decreased to 0
    Given path 'orders/order-lines', poLineIdWithElectronicQuantity
    When method GET
    Then status 200
    And match $.cost.listUnitPriceElectronic == 1.0
    And match $.cost.quantityElectronic == 0

