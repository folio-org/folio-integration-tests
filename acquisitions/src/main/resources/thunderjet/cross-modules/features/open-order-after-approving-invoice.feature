# For MODORDERS-859
Feature: Open order after approving invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Open order after approving invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Prepare finances
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line with Receipt Not Required
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', receiptStatus: 'Receipt Not Required', checkinItems: true }

    # 4. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 5. Add an invoice line linked to the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', total: 1 }

    # 6. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 7. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 8. Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }
    * call pause 1500

    # 9. Check the order was closed
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'

    # 10. Check the encumbrance was released
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId + ' and encumbrance.status==Released'
    When method GET
    Then status 200
    And match $.totalRecords == 1
