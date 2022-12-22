@parallel=false
# for https://issues.folio.org/browse/MODORDERS-807
Feature: Should update copy number, enumeration and chronology in item after updating in piece

  Background:
    * print karate.info.scenarioName

    * url baseUrl
#    * callonce dev {tenant: 'testorders1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid3
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6

  Scenario: Prepare finances
    * def fundId = fundId
    * def budgetId = budgetId
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

  Scenario: Create a po line
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

  Scenario: Update fields in piece
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

  Scenario: Check updated fields in item
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
