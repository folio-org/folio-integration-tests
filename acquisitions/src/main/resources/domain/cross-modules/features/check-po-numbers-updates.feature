# Created for MODINVOICE-178
Feature: Check poNumbers updates when invoice lines are created and updated

  Background:
    * url baseUrl
    #* callonce dev {tenant: 'test_cross_modules1'}

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

    * def orderId1 = callonce uuid1
    * def orderId2 = callonce uuid2
    * def poLineId1 = callonce uuid3
    * def poLineId2 = callonce uuid4
    * def invoiceId = callonce uuid5
    * def invoiceLineId1 = callonce uuid6
    * def invoiceLineId2 = callonce uuid7
    * def invoiceLineId3 = callonce uuid8
    * def poNumber1 = 'A1234'
    * def poNumber2 = 'A5678'


  Scenario: Check poNumbers updates when invoice lines are created and updated
    # Create order 1
    Given path 'orders/composite-orders'
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
    And request poLine1
    When method POST
    Then status 201

    # Create order line for order 2
    * copy poLine2 = poLineTemplate
    * set poLine2.id = poLineId2
    * set poLine2.purchaseOrderId = orderId2
    * set poLine2.fundDistribution[0].fundId = globalFundId
    Given path 'orders/order-lines'
    And request poLine2
    When method POST
    Then status 201

    # Create the invoice
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

    # Create invoice line 1 with a link to po 1
    * copy invoiceLine1 = invoiceLineTemplate
    * set invoiceLine1.id = invoiceLineId1
    * set invoiceLine1.invoiceId = invoiceId
    * set invoiceLine1.poLineId = poLineId1
    Given path 'invoice/invoice-lines'
    And request invoiceLine1
    When method POST
    Then status 201

    # Check the invoice poNumbers field was updated when the invoice line 1 was created
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[1] #string'
    And match $.poNumbers[0] == poNumber1

    # Update invoice line 1 to remove the link with po 1
    * set invoiceLine1.poLineId = null
    Given path 'invoice/invoice-lines', invoiceLineId1
    And request invoiceLine1
    When method PUT
    Then status 204

    # Check the invoice poNumbers field was updated when the invoice line 1 was updated
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[0]'

    # Update invoice line 1 to relink with po 1
    * set invoiceLine1.poLineId = poLineId1
    Given path 'invoice/invoice-lines', invoiceLineId1
    And request invoiceLine1
    When method PUT
    Then status 204

    # Check the invoice poNumbers field was updated when the invoice line 1 was updated
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[1] #string'
    And match $.poNumbers[0] == poNumber1

    # Create invoice line 2 without a link to a po
    * copy invoiceLine2 = invoiceLineTemplate
    * set invoiceLine2.id = invoiceLineId2
    * set invoiceLine2.invoiceId = invoiceId
    Given path 'invoice/invoice-lines'
    And request invoiceLine2
    When method POST
    Then status 201

    # Update invoice line 2 to link with po 2
    * set invoiceLine2.poLineId = poLineId2
    Given path 'invoice/invoice-lines', invoiceLineId2
    And request invoiceLine2
    When method PUT
    Then status 204

    # Check the invoice poNumbers field was updated when the invoice line 2 was updated
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[2] #string'
    And match $.poNumbers[0] == poNumber1
    And match $.poNumbers[1] == poNumber2

    # Create invoice line 3 with a link to po 2
    * copy invoiceLine3 = invoiceLineTemplate
    * set invoiceLine3.id = invoiceLineId3
    * set invoiceLine3.invoiceId = invoiceId
    * set invoiceLine3.poLineId = poLineId2
    Given path 'invoice/invoice-lines'
    And request invoiceLine3
    When method POST
    Then status 201

    # Check the invoice poNumbers field was not changed (numbers are unique)
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[2] #string'
    And match $.poNumbers[0] == poNumber1
    And match $.poNumbers[1] == poNumber2

    # Update invoice line 3 to remove the link with po 2
    * set invoiceLine3.poLineId = null
    Given path 'invoice/invoice-lines', invoiceLineId3
    And request invoiceLine3
    When method PUT
    Then status 204

    # Check the invoice poNumbers field was not changed (because invoice line 2 is still linked with po 2)
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[2] #string'
    And match $.poNumbers[0] == poNumber1
    And match $.poNumbers[1] == poNumber2

    # Update invoice line 3 without changing links
    * set invoiceLine3.quantity = 2
    Given path 'invoice/invoice-lines', invoiceLineId3
    And request invoiceLine3
    When method PUT
    Then status 204
