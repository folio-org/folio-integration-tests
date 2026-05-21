# Created for MODINVOICE-275
Feature: Invoice poNumbers needs to be updated when an invoice line is deleted

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Invoice poNumbers needs to be updated when an invoice line is deleted
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def poNumber1 = 'A91277'
    * def poNumber2 = 'A95277'

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

    # Create invoice line 1 with a link to po 1 and invoice id
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', fundId: '#(globalFundId)', poLineId: '#(poLineId1)', total: 100 }

    # Create invoice line 2 with a link to po 2 and invoice id
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', fundId: '#(globalFundId)', poLineId: '#(poLineId2)', total: 100 }

    # Delete invoice line 1
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method DELETE
    Then status 204

    # Retrieve invoice with po numbers
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoiceResponse = $
    And match invoiceResponse.poNumbers[0] == poNumber2
