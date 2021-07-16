# Created for MODINVOICE-269
Feature: Link an invoice line to a po line

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def poLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2
    * def invoiceId = callonce uuid3
    * def invoiceLineId = callonce uuid4


  Scenario: Link an invoice line to a po line
    # Create the invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

    # Create the invoice line without a link to a po line
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    # Create order
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

    # Create order line
    * copy poLine = poLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = globalFundId
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # Update invoice line to link with po line
    * set invoiceLine.poLineId = poLineId
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # Check the link was actually saved
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.poLineId == poLineId

    # Check an order-invoice relationship was created as well
    Given path 'orders-storage/order-invoice-relns'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
