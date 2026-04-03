# For MODINVOICE-385
Feature: Cancel invoice and unrelease 2 encumbrances

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Cancel invoice and unrelease 2 encumbrances
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * def v = call createFund { id: '#(fundId1)', code: '#(fundId1)' }
    * def v = call createBudget { id: '#(budgetId1)', allocated: 1000, fundId: '#(fundId1)', status: 'Active' }
    * def v = call createFund { id: '#(fundId2)', code: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId2)', allocated: 1000, fundId: '#(fundId2)', status: 'Active' }

    # 2. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line with 2 fund distributions
    * table fundDistribution
      | fundId  | code    | distributionType | value |
      | fundId1 | fundId1 | 'percentage'     | 50    |
      | fundId2 | fundId2 | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', listUnitPrice: 10, fundDistribution: '#(fundDistribution)' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 6. Add an invoice line with the same fund distributions
    * table fundDistributions
    | fundId  | distributionType | value |
    | fundId1 | 'percentage'     | 50    |
    | fundId2 | 'percentage'     | 50    |
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundDistributions: '#(fundDistributions)', poLineId: '#(poLineId)', total: 10, releaseEncumbrance: true }

    # 7. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 8. Check invoice line encumbrances have been added when the invoice was approved
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * match $.fundDistributions[0].encumbrance == '#present'
    * match $.fundDistributions[1].encumbrance == '#present'

    # 9. Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # 10. Check encumbrances before cancelling the invoice
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * match $.transactions[0].encumbrance.status == 'Released'
    * match $.transactions[1].encumbrance.status == 'Released'

    # 11. Cancel the invoice
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    # 12. Check encumbrances after cancelling the invoice
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * match $.transactions[0].encumbrance.status == 'Unreleased'
    * match $.transactions[1].encumbrance.status == 'Unreleased'
