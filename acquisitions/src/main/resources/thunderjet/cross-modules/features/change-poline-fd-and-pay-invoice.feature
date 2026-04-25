# For MODINVOICE-342
Feature: Change poline fund distribution and pay invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Change poline fund distribution and pay invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 6. Add an invoice line linked to the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', total: 10 }

    # 7. Remove the order line fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * remove poLine.fundDistribution
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 8. Add a new order line fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.fundDistribution = [ { fundId:'#(fundId)', code:'#(fundId)', distributionType:'percentage', value:100.0 } ]
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 9. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 10. Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }
