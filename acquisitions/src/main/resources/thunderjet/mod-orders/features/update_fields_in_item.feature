# Created for MODORDERS-807
Feature: Should update copy number, enumeration and chronology in item after updating in piece

  Background:
    * url baseUrl
    * print karate.info.scenarioName

    # * callonce dev {tenant: 'testorders1'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

  @Positive
  Scenario: Should update copy number, enumeration and chronology in item after updating in piece
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    * print '2. Create an order'
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time' }

    * print '3. Create a po line'
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = 'Awaiting Payment'
    * set poLine.receiptStatus = 'Partially Received'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print '4. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '5. Update fields in piece'
    Given path '/orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200

    * def piece = $.pieces[0]
    * set piece.copyNumber = '111'
    * set piece.chronology = '222'
    * set piece.enumeration = '333'

    Given path '/orders/pieces', piece.id
    And request piece
    When method PUT
    Then status 204

    * print '6. Check updated fields in item'
    Given path '/orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200

    * def piece = $.pieces[0]
    
    Given path '/inventory/items/', piece.itemId
    When method GET
    Then status 200

    * def item = $

    And match piece.copyNumber == '111'
    And match piece.chronology == '222'
    And match piece.enumeration == '333'
    And match item.copyNumber == '111'
    And match item.chronology == '222'
    And match item.enumeration == '333'
