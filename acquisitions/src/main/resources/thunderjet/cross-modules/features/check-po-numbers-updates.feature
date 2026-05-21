# Created for MODINVOICE-178
Feature: Check poNumbers updates when invoice lines are created and updated

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Check poNumbers updates when invoice lines are created and updated
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def poNumber1 = 'A1234'
    * def poNumber2 = 'A5678'

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
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId1)', fundId: '#(globalFundId)' }

    # Create order line for order 2
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId2)', fundId: '#(globalFundId)' }

    # Create the invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # Create invoice line 1 with a link to po 1
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId1)', fundId: '#(globalFundId)', total: 100 }

    # Check the invoice poNumbers field was updated when the invoice line 1 was created
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[1] #string'
    And match $.poNumbers[0] == poNumber1

    # Update invoice line 1 to remove the link with po 1
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    * def invoiceLine1 = $
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
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    * def invoiceLine1 = $
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
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', poLineId: null, fundId: '#(globalFundId)', total: 100 }

    # Update invoice line 2 to link with po 2
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    * def invoiceLine2 = $
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
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId3)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId2)', fundId: '#(globalFundId)', total: 100 }

    # Check the invoice poNumbers field was not changed (numbers are unique)
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.poNumbers == '#[2] #string'
    And match $.poNumbers[0] == poNumber1
    And match $.poNumbers[1] == poNumber2

    # Update invoice line 3 to remove the link with po 2
    Given path 'invoice/invoice-lines', invoiceLineId3
    When method GET
    Then status 200
    * def invoiceLine3 = $
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
    Given path 'invoice/invoice-lines', invoiceLineId3
    When method GET
    Then status 200
    * def invoiceLine3 = $
    * set invoiceLine3.quantity = 2
    Given path 'invoice/invoice-lines', invoiceLineId3
    And request invoiceLine3
    When method PUT
    Then status 204
