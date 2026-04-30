# For MODINVOICE-270, MODFISTO-273, MODFISTO-284, MODINVOICE-360, MODINVOICE-446, MODFISTO-475 and MODORDERS-1439
Feature: Cancel an invoice linked to an order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Cancel an approved invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    * print "Create an order and line"
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: #(orderId) }

    * print "Create an invoice"
    * def v = call createInvoice { id: #(invoiceId) }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: 10 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    * print "Check the budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    * print "Check the pending payment before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 10
    And match $.transactions[0].awaitingPayment.encumbranceId == encumbranceId

    * print "Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 10
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Released'

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    * print "Check the invoice line status after cancelling"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "Check the pending payment after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    * print "Check the batch voucher after cancelling"
    Given path '/voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.vouchers[0].status == 'Cancelled'

    * print "Check the encumbrance after cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Unreleased'

    * print "Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 10


  Scenario: Cancel a paid invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    * print "Create finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    * print "Create an order and line"
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: #(orderId) }

    * print "Create an invoice"
    * def v = call createInvoice { id: #(invoiceId) }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line with a payment"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId1), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: 10 }

    * print "Add an invoice line with a credit"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId2), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: -5 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    * print "Pay the invoice"
    * def v = call payInvoice { invoiceId: #(invoiceId) }

    * print "Check the payment before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 10
    And match $.transactions[0].paymentEncumbranceId == encumbranceId

    * print "Check the credit before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 5

    * print "Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountExpended == 10
    And match $.encumbrance.amountCredited == 5
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.status == 'Released'

    * print "Check the budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 5
    And match $.available == 995
    And match $.awaitingPayment == 0
    And match $.expenditures == 10
    And match $.credits == 5
    And match $.cashBalance == 995
    And match $.encumbered == 0

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    * print "Check the invoice lines status after cancelling"
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "Check the payment after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    * print "Check the credit after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 5

    * print "Check the batch voucher after cancelling"
    Given path '/voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.vouchers[0].status == 'Cancelled'

    * print "Check the encumbrance after cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.amountCredited == 0
    And match $.encumbrance.status == 'Unreleased'

    * print "Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 10


  Scenario: Cancel a paid invoice with a single credit
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), allocated: 1000, fundId: #(fundId), status: 'Active' }

    * print "Create an order and line"
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: #(orderId) }

    * print "Create an invoice"
    * def v = call createInvoice { id: #(invoiceId) }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line with a credit"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: -5 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    * print "Pay the invoice"
    * def v = call payInvoice { invoiceId: #(invoiceId) }

    * print "Check the credit before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 5
    And match $.transactions[0].paymentEncumbranceId == encumbranceId

    * print "Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.amountCredited == 5
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.status == 'Released'

    * print "Check the budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1005
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 5
    And match $.cashBalance == 1005
    And match $.encumbered == 0

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    * print "Check the invoice line status after cancelling"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "Check the credit after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 5

    * print "Check the encumbrance after cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.amountCredited == 0
    And match $.encumbrance.status == 'Unreleased'

    * print "Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 10


  Scenario: Cancel an approved invoice with unreleasing the encumbrance (PO line payment status "Payment Not Required")
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    * print "Create an order"
    * def v = call createOrder { id: #(orderId) }

    * print "Create an order line, with 'Payment Not Required'"
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, paymentStatus: 'Payment Not Required' }

    * print "Open the order"
    * def v = call openOrder { orderId: #(orderId) }

    * print "Create an invoice"
    * def v = call createInvoice { id: #(invoiceId) }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: 10 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    * print "Check the budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    * print "Check the pending payment before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 10
    And match $.transactions[0].awaitingPayment.encumbranceId == encumbranceId

    * print "Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 10
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Released'

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    * print "Check the invoice line status after cancelling"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "Check the pending payment after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    * print "Check the encumbrance after cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Unreleased'

    * print "Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 10


  Scenario: Cancel an approved invoice without unreleasing the encumbrance
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * print "1. Create finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create an order and line
    * print "2. Create an order and line"
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

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
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 10 }

    # 7. Approve the invoice
    * print "7. Approve the invoice"
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 8. Change the order line paymentStatus to Cancelled
    * print "8. Change the order line paymentStatus to Cancelled"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.paymentStatus = 'Cancelled'
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 9. Check the budget before cancelling
    * print "9. Check the budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    # 10. Check the pending payment before cancelling
    * print "10. Check the pending payment before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 10
    And match $.transactions[0].awaitingPayment.encumbranceId == encumbranceId

    # 11. Check the encumbrance before cancelling
    * print "11. Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 10
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Released'

    # 12. Cancel the invoice
    * print "12. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    # 13. Check the invoice line status after cancelling
    * print "13. Check the invoice line status after cancelling"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    # 14. Check the pending payment after cancelling
    * print "14. Check the pending payment after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    # 15. Check the encumbrance after cancelling
    * print "15. Check the encumbrance after cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Released'

    # 16. Check the budget after cancelling
    * print "16. Check the budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1000
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0


  Scenario: Cancel an approved invoice for an ongoing order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    * print "Create order and line"
    * def ongoing = { interval: 123, isSubscription: true, renewalDate: '2022-05-08T00:00:00.000+00:00' }
    * def v = call createOrder { id: #(orderId), orderType: 'Ongoing', ongoing: #(ongoing), reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), listUnitPrice: 10 }

    * print "Open the order"
    * def v = call openOrder { orderId: #(orderId) }

    * print "Create an invoice"
    * def v = call createInvoice { id: #(invoiceId) }

    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), poLineId: #(poLineId), fundId: #(fundId), encumbranceId: #(encumbranceId), total: 10 }

    * print "Approve the invoice"
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    * print "Check the budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    * print "Check the pending payment before cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 10
    And match $.transactions[0].awaitingPayment.encumbranceId == encumbranceId

    * print "Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 10
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Released'

    * print "Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: #(invoiceId) }

    * print "Check the invoice line status after cancelling"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "Check the pending payment after cancelling"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    * print "Check the batch voucher after cancelling"
    Given path '/voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.vouchers[0].status == 'Cancelled'

    * print "Check the encumbrance after cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Unreleased'

    * print "Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 10


  @Negative
  Scenario: Cancel an approved invoice when a linked order line budget is inactive
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * print "1. Create finances"
    * def v = call createFund { id: '#(fundId1)' }
    * def v = call createFund { id: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId1)', allocated: 1000, fundId: '#(fundId1)', status: 'Active' }
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
    * remove invoiceLine.fundDistributions[0].encumbrance
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # 8. Approve the invoice
    * print "8. Approve the invoice"
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 9. Make the po line budget inactive
    * print "9. Make the po line budget inactive"
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    * def budget = $
    * set budget.budgetStatus = 'Inactive'
    Given path 'finance/budgets', budgetId1
    And request budget
    When method PUT
    Then status 204

    # 10. Try to cancel the invoice
    * print "10. Try to cancel the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Cancelled'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 404
    And match $.errors[0].code == 'budgetNotFoundByFundIdAndFiscalYearId'
    And match $.errors[0].parameters[0].key == 'fundId'
    And match $.errors[0].parameters[0].value == '#(fundId1)'

    # 11. Check the budget after cancelling failed
    * print "11. Check the budget after cancelling failed"
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    # 12. Check the pending payment after cancelling failed
    * print "12. Check the pending payment after cancelling failed"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].amount == 10
    And match $.transactions[0].awaitingPayment.encumbranceId == '#notpresent'

    # 13. Check the encumbrance after cancelling failed
    * print "13. Check the encumbrance after cancelling failed"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.encumbrance.status == 'Released'
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0

    # 14. Check the invoice line status after cancelling failed
    * print "14. Check the invoice line status after cancelling failed"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Approved'

    # 15. Check the batch voucher after cancelling failed
    * print "15. Check the batch voucher after cancelling failed"
    Given path '/voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.vouchers[0].status == 'Awaiting payment'


  @Positive
  Scenario: Cancel a paid invoice linked to an order line with received pieces
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * print "1. Create finances"
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create an order and line
    * print "2. Create an order and line"
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

    # 3. Open the order
    * print "3. Open the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Receive the piece
    * print "4. Receive the piece"
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def pieceId = $.pieces[0].id
    * def v = call receivePieceWithHolding { pieceId: '#(pieceId)', poLineId: '#(poLineId)' }

    # 5. Create an invoice
    * print "5. Create an invoice"
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 6. Get the encumbrance id
    * print "6. Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def encumbranceId = $.fundDistribution[0].encumbrance

    # 7. Add an invoice line linked to the po line
    * print "7. Add an invoice line linked to the po line"
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId)', total: 10 }

    # 8. Approve the invoice
    * print "8. Approve the invoice"
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 9. Pay the invoice
    * print "9. Pay the invoice"
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # 10. Check the order was closed automatically
    * print "10. Check the order was closed automatically"
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Closed'
    When method GET
    Then status 200

    # 11. Check the encumbrance before cancelling
    * print "11. Check the encumbrance before cancelling"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 10
    And match $.encumbrance.status == 'Released'

    # 12. Cancel the invoice
    * print "12. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    # 13. Check the encumbrance was unreleased
    * print "13. Check the encumbrance was unreleased"
    Given path 'finance/transactions', encumbranceId
    When method GET
    Then status 200
    And match $.amount == 10
    And match $.encumbrance.initialAmountEncumbered == 10
    And match $.encumbrance.amountAwaitingPayment == 0
    And match $.encumbrance.amountExpended == 0
    And match $.encumbrance.status == 'Unreleased'

    # 14. Check the order was reopened
    * print "14. Check the order was reopened"
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Open'
