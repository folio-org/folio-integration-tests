# For MODORDERS-1449
Feature: Pay, unopen, open

Background:
  * print karate.info.scenarioName
  * url baseUrl

  * callonce login testAdmin
  * def okapitokenAdmin = okapitoken
  * callonce login testUser
  * def okapitokenUser = okapitoken
  * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
  * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
  * configure headers = headersUser

  * callonce variables


@Positive
Scenario: Pay, unopen, open
  * def fundId = call uuid
  * def budgetId = call uuid
  * def orderId = call uuid
  * def poLineId = call uuid
  * def invoiceId = call uuid
  * def invoiceLineId = call uuid

  # 1. Create a fund and budget
  * def v = call createFund { id: '#(fundId)' }
  * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)' }

  # 2. Create an order and line
  * def v = call createOrder { id: '#(orderId)' }
  * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 11 }

  # 3. Open the order
  * def v = call openOrder { orderId: '#(orderId)' }

  # 4. Get the encumbrance id
  Given path 'orders/order-lines', poLineId
  When method GET
  Then status 200
  * def encumbranceId = $.fundDistribution[0].encumbrance

  # 5. Create an invoice
  * def v = call createInvoice { id: '#(invoiceId)' }

  # 6. Add an invoice line linked to the po line, releaseEncumbrance=false
  * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', releaseEncumbrance: false, total: 4.0 }

  # 7. Approve and pay the invoice
  * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
  * def v = call payInvoice { invoiceId: '#(invoiceId)' }

  # 8. Unopen the order
  * def v = call unopenOrder { orderId: '#(orderId)' }

  # 9. Reopen the order
  * def v = call openOrder { orderId: '#(orderId)' }

  # 10. Check the encumbrance is unreleased
  Given path 'finance/transactions', encumbranceId
  When method GET
  Then status 200
  And match $.encumbrance.status == 'Unreleased'
  And match $.amount == 7.0
  And match $.encumbrance.initialAmountEncumbered == 11.0
  And match $.encumbrance.amountAwaitingPayment == 0
  And match $.encumbrance.amountExpended == 4.0
