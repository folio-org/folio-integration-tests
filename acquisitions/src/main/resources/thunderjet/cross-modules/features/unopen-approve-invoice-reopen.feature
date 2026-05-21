# For MODORDERS-833
Feature: Unopen order, approve invoice and reopen

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Unopen order, approve invoice and reopen
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Prepare finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Unopen the order
    * def v = call unopenOrder { orderId: '#(orderId)' }

    # 6. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 7. Add an invoice line
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundId: '#(fundId)', poLineId: '#(poLineId)', total: 1 }

    # 8. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 9. Reopen the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 10. Check the transaction is still released
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].encumbrance.status == 'Released'
