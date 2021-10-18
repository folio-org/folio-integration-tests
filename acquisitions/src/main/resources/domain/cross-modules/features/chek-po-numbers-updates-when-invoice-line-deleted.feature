# Created for MODINVOICE-275
Feature: Invoice poNumbers needs to be updated when an invoice line is deleted

  Background:
    * url baseUrl
    #* callonce dev {tenant: 'test_cross_modules2'}

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * callonce variables

    * def poLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def orderId1 = callonce uuid1
    * def orderId2 = callonce uuid2
    * def poLineId1 = callonce uuid3
    * def poLineId2 = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId1 = callonce uuid6
    * def invoiceLineId2 = callonce uuid7
    * def invoiceLineId3 = callonce uuid8
    * def poNumber1 = 'A91277'
    * def poNumber2 = 'A95277'


  Scenario: Invoice poNumbers needs to be updated when an invoice line is deleted
    # Create order 1
    Given path 'orders/composite-orders'
    And headers headersUser
    And request
    """
    {
      id: '#(orderId1)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      poNumber: '#(poNumber1)'
    }
    """
    When method POST
    Then status 201

    # Create order 2
    Given path 'orders/composite-orders'
    And headers headersUser
    And request
    """
    {
      id: '#(orderId2)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      poNumber: '#(poNumber2)'
    }
    """
    When method POST
    Then status 201

    # Create order line for order 1
    * copy poLine1 = poLineTemplate
    * set poLine1.id = poLineId1
    * set poLine1.purchaseOrderId = orderId1
    * set poLine1.fundDistribution[0].fundId = globalFundId

    Given path 'orders/order-lines'
    And headers headersUser
    And request poLine1
    When method POST
    Then status 201

    # Create order line for order 2
    * copy poLine2 = poLineTemplate
    * set poLine2.id = poLineId2
    * set poLine2.purchaseOrderId = orderId2
    * set poLine2.fundDistribution[0].fundId = globalFundId

   Given path 'orders/order-lines'
    And headers headersUser
    And request poLine2
    When method POST
    Then status 201

    # Create the invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId

    Given path 'invoice/invoices'
    And headers headersUser
    And request invoice
    When method POST
    Then status 201

    # Create invoice line 1 with a link to po 1 and invoice id
    * copy invoiceLine1 = invoiceLineTemplate
    * set invoiceLine1.id = invoiceLineId1
    * set invoiceLine1.invoiceId = invoiceId
    * set invoiceLine1.poLineId = poLineId1

    Given path 'invoice/invoice-lines'
    And headers headersUser
    And request invoiceLine1
    When method POST
    Then status 201

    # Create invoice line 2 with a link to po 2 and invoice id
    * copy invoiceLine2 = invoiceLineTemplate
    * set invoiceLine2.id = invoiceLineId2
    * set invoiceLine2.invoiceId = invoiceId
    * set invoiceLine2.poLineId = poLineId2

    Given path 'invoice/invoice-lines'
    And headers headersUser
    And request invoiceLine2
    When method POST
    Then status 201

    # Delete invoice line
    Given path 'invoice/invoice-lines', invoiceLineId1
    And headers headersUser
    When method DELETE
    Then status 204

    # Retrieve invoice with po numbers
    Given path 'invoice/invoices', invoiceId
    And headers headersUser
    When method GET
    Then status 200
    * def invoiceResponse = $
    And match invoiceResponse.poNumbers[0] == poNumber2
