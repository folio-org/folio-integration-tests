# For MODINVOICE-290 and MODINVOICE-626
Feature: Approve invoice with different fund than order

Background:
  * print karate.info.scenarioName
  * url baseUrl

  * callonce login testUser
  * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
  * configure headers = headersUser

  * callonce variables


@Positive
Scenario: Approve invoice with different fund than order when order fund is active
  * def fundId1 = call uuid
  * def budgetId1 = call uuid
  * def fundId2 = call uuid
  * def budgetId2 = call uuid
  * def orderId = call uuid
  * def poLineId = call uuid
  * def invoiceId = call uuid
  * def invoiceLineId = call uuid

  # 1. Create finances
  * print "1. Create finances"
  * def v = call createFund { id: '#(fundId1)' }
  * def v = call createBudget { id: '#(budgetId1)', allocated: 1000, fundId: '#(fundId1)', status: 'Active' }
  * def v = call createFund { id: '#(fundId2)' }
  * def v = call createBudget { id: '#(budgetId2)', allocated: 1000, fundId: '#(fundId2)', status: 'Active' }

  # 2. Create an order and line
  * print "2. Create an order and line"
  * def v = call createOrder { id: '#(orderId)' }
  * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', listUnitPrice: 10 }

  # 3. Open the order
  * print "3. Open the order"
  * def v = call openOrder { orderId: '#(orderId)' }

  # 4. Create an invoice
  * print "4. Create an invoice"
  * def v = call createInvoice { id: '#(invoiceId)' }

  # 5. Get the encumbrance id
  * print "5. Get the encumbrance id"
  Given path 'orders/order-lines', poLineId
  When method GET
  Then status 200
  * def poLine = $
  * def encumbranceId = poLine.fundDistribution[0].encumbrance

  # 6. Add an invoice line linked to the po line
  * print "6. Add an invoice line linked to the po line"
  * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', encumbranceId: '#(encumbranceId)', total: 10 }

  # 7. Change the invoice line fund
  * print "7. Change the invoice line fund"
  Given path 'invoice/invoice-lines', invoiceLineId
  When method GET
  Then status 200
  * def invoiceLine = $
  * set invoiceLine.fundDistributions[0].fundId = fundId2
  * set invoiceLine.fundDistributions[0].code = fundId2
  * set invoiceLine.fundDistributions[0].encumbrance = null
  Given path 'invoice/invoice-lines', invoiceLineId
  And request invoiceLine
  When method PUT
  Then status 204

  # 8. Approve the invoice
  * print "8. Approve the invoice"
  * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

  # 9. Check the pending payment was created
  * print "9. Check the pending payment was created"
  Given path 'finance/transactions'
  And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
  When method GET
  Then status 200
  And match response.totalRecords == 1
  And match $.transactions[0].awaitingPayment.encumbranceId == '#notpresent'

  # 10. Check the encumbrance was released
  * print "10. Check the encumbrance was released"
  Given path 'finance/transactions', encumbranceId
  When method GET
  Then status 200
  And match $.encumbrance.status == 'Released'


@Negative
Scenario: Approve invoice with different fund than order when order fund is inactive
  * def fundId1 = call uuid
  * def budgetId1 = call uuid
  * def fundId2 = call uuid
  * def budgetId2 = call uuid
  * def orderId = call uuid
  * def poLineId = call uuid
  * def invoiceId = call uuid
  * def invoiceLineId = call uuid

  # 1. Create finances
  * print "1. Create finances"
  * def v = call createFund { id: '#(fundId1)' }
  * def v = call createBudget { id: '#(budgetId1)', allocated: 1000, fundId: '#(fundId1)', status: 'Active' }
  * def v = call createFund { id: '#(fundId2)' }
  * def v = call createBudget { id: '#(budgetId2)', allocated: 1000, fundId: '#(fundId2)', status: 'Active' }

  # 2. Create an order and line
  * print "2. Create an order and line"
  * def v = call createOrder { id: '#(orderId)' }
  * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)', listUnitPrice: 10 }

  # 3. Open the order
  * print "3. Open the order"
  * def v = call openOrder { orderId: '#(orderId)' }

  # 4. Create an invoice
  * print "4. Create an invoice"
  * def v = call createInvoice { id: '#(invoiceId)' }

  # 5. Get the encumbrance id
  * print "5. Get the encumbrance id"
  Given path 'orders/order-lines', poLineId
  When method GET
  Then status 200
  * def poLine = $
  * def encumbranceId = poLine.fundDistribution[0].encumbrance

  # 6. Add an invoice line linked to the po line
  * print "6. Add an invoice line linked to the po line"
  * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId1)', encumbranceId: '#(encumbranceId)', total: 10 }

  # 7. Change the invoice line fund
  * print "7. Change the invoice line fund"
  Given path 'invoice/invoice-lines', invoiceLineId
  When method GET
  Then status 200
  * def invoiceLine = $
  * set invoiceLine.fundDistributions[0].fundId = fundId2
  * set invoiceLine.fundDistributions[0].code = fundId2
  * set invoiceLine.fundDistributions[0].encumbrance = null
  Given path 'invoice/invoice-lines', invoiceLineId
  And request invoiceLine
  When method PUT
  Then status 204

  # 8. Set po line budget to Inactive
  * print "8. Set po line budget to Inactive"
  Given path 'finance/budgets', budgetId1
  When method GET
  Then status 200
  * def budget = $
  * set budget.budgetStatus = 'Inactive'
  Given path 'finance/budgets', budgetId1
  And request budget
  When method PUT
  Then status 204

  # 9. Try to approve the invoice
  * print "9. Try to approve the invoice"
  Given path 'invoice/invoices', invoiceId
  When method GET
  Then status 200
  * def invoice = $
  * set invoice.status = 'Approved'
  Given path 'invoice/invoices', invoiceId
  And request invoice
  When method PUT
  Then status 400

  # 10. Check the pending payment was not created
  * print "10. Check the pending payment was not created"
  Given path 'finance/transactions'
  And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
  When method GET
  Then status 200
  And match response.totalRecords == 0

  # 11. Check the encumbrance was not released
  * print "11. Check the encumbrance was not released"
  Given path 'finance/transactions', encumbranceId
  When method GET
  Then status 200
  And match $.encumbrance.status == 'Unreleased'
