  # For MODFISTO-512, FAT-21205
  Feature: Encumbrance remains released after another credited invoice was paid

    Background:
      * print karate.info.scenarioName
      * url baseUrl

      * callonce login testUser
      * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
      * configure headers = headersUser

      * callonce variables
      * def fundId = callonce uuid1
      * def budgetId = callonce uuid2
      * def orderId = callonce uuid3
      * def poLineId = callonce uuid4
      * def invoiceId1 = callonce uuid5
      * def invoiceId2 = callonce uuid6
      * def invoiceLineId1 = callonce uuid7
      * def invoiceLineId2 = callonce uuid8


    @C624240
    @Positive
    Scenario: Encumbrance remains released after another credited invoice was paid
      # 1. Create a fund and a budget
      * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
      * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

      # 2. Create an order, order line and open the order
      * def v = call createOrder { id: '#(orderId)' }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, quantity: 1 }
      * def v = call openOrder { orderId: '#(orderId)' }

      # 3. Get encumbrance transaction and check the amount
      Given path '/finance/transactions'
      And param query = 'encumbrance.sourcePurchaseOrderId == ' + orderId
      When method GET
      Then status 200
      And match response.transactions[0].encumbrance.status == 'Unreleased'
      And match response.transactions[0].amount == 10
      * def encumbranceId = response.transactions[0].id

      # 4. Create an invoice and invoice line
      * def v = call createInvoice { id: '#(invoiceId1)' }
      * table invoiceLineData
        | invoiceLineId  | invoiceId  | poLineId | total | releaseEncumbrance | fundId | encumbranceId |
        | invoiceLineId1 | invoiceId1 | poLineId | 10    | true               | fundId | encumbranceId |
      * def v = call createInvoiceLine invoiceLineData

      # 5. Approve invoice and check the encumbrance transaction amount
      * def v = call approveInvoice { invoiceId: '#(invoiceId1)' }
      * def v = call verifyReleasedEncumbrance { encId: '#(encumbranceId)' }

      # 6. Pay invoice and check the encumbrance transaction amount
      * def v = call payInvoice { invoiceId: '#(invoiceId1)' }
      * def v = call verifyReleasedEncumbrance { encId: '#(encumbranceId)' }

      # 7. Create second invoice and invoice line
      * def v = call createInvoice { id: '#(invoiceId2)' }
      * table invoiceLineData
        | invoiceLineId  | invoiceId  | poLineId | total | releaseEncumbrance | fundId | encumbranceId |
        | invoiceLineId2 | invoiceId2 | poLineId | -10   | false              | fundId | encumbranceId |
      * def v = call createInvoiceLine invoiceLineData

      # 8. Approve second invoice and check the encumbrance transaction amount
      * def v = call approveInvoice { invoiceId: '#(invoiceId2)' }
      * def v = call verifyReleasedEncumbrance { encId: '#(encumbranceId)' }

      # 9. Pay second invoice and check the encumbrance transaction amount
      * def v = call payInvoice { invoiceId: '#(invoiceId2)' }
      * def v = call verifyReleasedEncumbrance { encId: '#(encumbranceId)' }
