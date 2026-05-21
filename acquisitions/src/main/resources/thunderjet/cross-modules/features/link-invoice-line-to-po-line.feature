# Created for MODINVOICE-269
Feature: Link an invoice line to a po line

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


  Scenario: Link an invoice line to a po line
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # Create the invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # Create the invoice line without a link to a po line
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundId: '#(globalFundId)', poLineId: null, total: 100 }

    # Create order
    * def v = call createOrder { id: '#(orderId)' }

    # Create order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(globalFundId)' }

    # Update invoice line to link with po line
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200

    * def invoiceLine = $
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
    * configure headers = headersAdmin
    Given path 'orders-storage/order-invoice-relns'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
