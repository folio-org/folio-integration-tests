# For MODINVOICE-270 and MODFISTO-273
Feature: Cancel an invoice

  Background:
    * url baseUrl
    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * call variables

    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')
    * def approveInvoice = read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature')
    * def payInvoice = read('classpath:thunderjet/mod-invoice/reusable/pay-invoice.feature')
    * def cancelInvoice = read('classpath:thunderjet/mod-invoice/reusable/cancel-invoice.feature')


  Scenario: Cancel an approved invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }
    * configure headers = headersUser

    * print "2. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "3. Add an invoice line"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", fundId: "#(fundId)", total: 10, expenseClassId: null }

    * print "4. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "5. Check budget before cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 990
    And match $.awaitingPayment == 10
    And match $.expenditures == 0
    And match $.credits == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

    * print "6. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    * print "7. Check the invoice line status"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "8. Check the pending payment"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    * print "9. Check the batch voucher"
    Given path '/voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.vouchers[0].status == 'Cancelled'

    * print "10. Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1000
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0


  Scenario: Cancel a paid invoice
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    * print "1. Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active' }
    * configure headers = headersUser

    * print "2. Create an invoice"
    * def v = call createInvoice { id: "#(invoiceId)" }

    * print "3. Add an invoice line with a payment"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId1)", invoiceId: "#(invoiceId)", fundId: "#(fundId)", total: 10, expenseClassId: null }

    * print "4. Add an invoice line with a credit"
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId2)", invoiceId: "#(invoiceId)", fundId: "#(fundId)", total: -5, expenseClassId: null }

    * print "5. Approve the invoice"
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    * print "6. Pay the invoice"
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    * print "7. Check budget before cancelling"
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

    * print "8. Cancel the invoice"
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    * print "9. Check the invoice lines status"
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    * print "10. Check the payment"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId1 + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 10

    * print "11. Check the credit"
    Given path 'finance/transactions'
    And param query = 'sourceInvoiceLineId==' + invoiceLineId2 + ' and transactionType==Credit'
    When method GET
    Then status 200
    And match $.transactions[0].invoiceCancelled == true
    And match $.transactions[0].amount == 0
    And match $.transactions[0].voidedAmount == 5

    * print "12. Check the batch voucher"
    Given path '/voucher/vouchers'
    And param query = 'invoiceId==' + invoiceId
    When method GET
    Then status 200
    And match $.vouchers[0].status == 'Cancelled'

    * print "13. Check budget after cancelling"
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1000
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.credits == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0
