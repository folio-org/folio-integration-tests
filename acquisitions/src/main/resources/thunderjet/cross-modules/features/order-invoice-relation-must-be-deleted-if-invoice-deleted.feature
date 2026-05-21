Feature: When invoice is deleted, then order vs invoice relation must be deleted and POL can be deleted

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


  Scenario: When invoice is deleted, then order vs invoice relation must be deleted and POL can be deleted
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(globalFundId)' }

    # 3. Create invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 4. get order line with fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def fd = response.fundDistribution
    * def lineAmount = response.cost.listUnitPrice

    # 5. Create invoice line
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fd)', total: '#(lineAmount)' }

    # 6. Check that order invoice relation has been changed
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query

    * configure headers = headersAdmin
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # 7. Delete invoice
    * configure headers = headersUser
    Given path 'invoice/invoices', invoiceId
    And request
    When method DELETE
    Then status 204

    # 8. Check that order invoice relation has been deleted
    * def query = 'purchaseOrderId==' + orderId + ' AND invoiceId==' + invoiceId
    * print query

    * configure headers = headersAdmin
    Given path 'orders-storage/order-invoice-relns'
    And param query = query
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 9. Delete order lines
    * configure headers = headersUser
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 404
