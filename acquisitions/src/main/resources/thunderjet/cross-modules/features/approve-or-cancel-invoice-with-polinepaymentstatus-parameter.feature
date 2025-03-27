  # For MODINVOICE-573
  Feature: Approve or cancel an invoice with the poLinePaymentStatus parameter

    Background:
      * print karate.info.scenarioName

      * url baseUrl
      * callonce login testAdmin
      * def okapitokenAdmin = okapitoken
      * callonce login testUser
      * def okapitokenUser = okapitoken

      * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
      * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }
      * configure headers = headersUser

      * callonce variables


    @Positive
    Scenario: Pay and cancel the invoice, first without poLinePaymentStatus and then using poLinePaymentStatus
      * def codePrefix = callonce random_string
      * def currentYear = callonce getCurrentYear
      * def pastYear = 2020
      * def currentPeriodStart = currentYear + '-01-01T00:00:00Z'
      * def currentPeriodEnd = currentYear + '-12-30T23:59:59Z'
      * def pastPeriodStart = pastYear + '-01-01T00:00:00Z'
      * def pastPeriodEnd = pastYear + '-12-30T23:59:59Z'
      * def currentFiscalCode = codePrefix + currentYear
      * def pastFiscalCode = codePrefix + pastYear
      * def currentFiscalYearId = call uuid
      * def pastFiscalYearId = call uuid
      * def ledgerId = call uuid
      * def fundId = call uuid
      * def currentBudgetId = call uuid
      * def pastBudgetId = call uuid
      * def orderId = call uuid
      * def poLineId = call uuid
      * def pastEncumbranceId = call uuid
      * def invoiceId = call uuid
      * def invoiceLineId = call uuid

      * print "Create finances with a current and a past fiscal year"
      * configure headers = headersAdmin
      * def v = call createFiscalYear { id: '#(currentFiscalYearId)', code: '#(currentFiscalCode)', periodStart: '#(currentPeriodStart)', periodEnd: '#(currentPeriodEnd)', series: '#(codePrefix)' }
      * def v = call createFiscalYear { id: '#(pastFiscalYearId)', code: '#(pastFiscalCode)', periodStart: '#(pastPeriodStart)', periodEnd: '#(pastPeriodEnd)', series: '#(codePrefix)' }
      * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(pastFiscalYearId)', restrictEncumbrance: false, restrictExpenditures: false }
      * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
      * def v = call createBudget { id: '#(currentBudgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active', fiscalYearId: '#(currentFiscalYearId)' }
      * def v = call createBudget { id: '#(pastBudgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active', fiscalYearId: '#(pastFiscalYearId)' }
      * configure headers = headersUser

      * print "Create an order and line"
      * def v = call createOrder { id: '#(orderId)' }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

      * print "Open the order"
      * def v = call openOrder { orderId: '#(orderId)' }

      * print "Create an encumbrance in the past fiscal year"
      * configure headers = headersAdmin
      * def v = call createTransaction { id: '#(pastEncumbranceId)', transactionType: 'Encumbrance', fiscalYearId: '#(pastFiscalYearId)', fundId: '#(fundId)', amount: 10.0, orderId: '#(orderId)', poLineId: '#(poLineId)' }
      * configure headers = headersUser

      * print "Create an invoice in the past fiscal year"
      * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(pastFiscalYearId)' }

      * print "Add an invoice line linked to the po line, using the past encumbrance, with releaseEncumbrance=true"
      * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', encumbranceId: '#(pastEncumbranceId)', total: 10, releaseEncumbrance: true }

      * def v = call approveInvoice

      * print "Pay the invoice without using the poLinePaymentStatus parameter"
      * call getInvoice
      * set invoice.status = 'Paid'
      Given path 'invoice/invoices', invoiceId
      And request invoice
      When method PUT
      Then status 400
      And match $.errors[0].code == 'poLinePaymentStatusNotPresent'

      * print "Pay the invoice using the poLinePaymentStatus parameter"
      * def v = call payInvoice { poLinePaymentStatus: 'Fully Paid' }

      * print "Check the order line payment status after paying"
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.paymentStatus == 'Fully Paid'

      * print "Cancel the invoice without using the poLinePaymentStatus parameter"
      * call getInvoice
      * set invoice.status = 'Cancelled'
      Given path 'invoice/invoices', invoiceId
      And request invoice
      When method PUT
      Then status 400
      And match $.errors[0].code == 'poLinePaymentStatusNotPresent'

      * print "Cancel the invoice using the poLinePaymentStatus parameter"
      * def v = call cancelInvoice { poLinePaymentStatus: 'Cancelled' }

      * print "Check the order line payment status after cancelling"
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.paymentStatus == 'Cancelled'
