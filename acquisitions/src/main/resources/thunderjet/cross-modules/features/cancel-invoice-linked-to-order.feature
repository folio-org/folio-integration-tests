# For MODINVOICE-270, MODFISTO-273, MODFISTO-284, MODINVOICE-360, MODINVOICE-446 and MODFISTO-475
Feature: Cancel an invoice linked to an order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')


  Scenario: Cancel an approved invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

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
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

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
    * call createFund { id: #(fundId) }
    * call createBudget { id: #(budgetId), allocated: 1000, fundId: #(fundId), status: 'Active' }

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
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

    * print "Create an order"
    * def v = call createOrder { id: #(orderId) }

    * print "Create an order line, with 'Payment Not Required'"
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.cost.listUnitPrice = 10
    * set poLine.paymentStatus = 'Payment Not Required'
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

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


  Scenario: Cancel an approved invoice for an ongoing order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }

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
