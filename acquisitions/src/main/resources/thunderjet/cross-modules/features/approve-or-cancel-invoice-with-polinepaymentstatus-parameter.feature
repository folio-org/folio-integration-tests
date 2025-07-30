  # For MODINVOICE-573
  Feature: Approve or cancel an invoice with the poLinePaymentStatus parameter

    Background:
      * print karate.info.scenarioName
      * url baseUrl

      * callonce login testUser
      * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
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
      * def poLineId1 = call uuid
      * def poLineId2 = call uuid
      * def pastEncumbranceId1 = call uuid
      * def pastEncumbranceId2 = call uuid
      * def invoiceId = call uuid
      * def invoiceLineId1 = call uuid
      * def invoiceLineId2 = call uuid

      * print "Create finances with a current and a past fiscal year"
      * def v = call createFiscalYear { id: '#(currentFiscalYearId)', code: '#(currentFiscalCode)', periodStart: '#(currentPeriodStart)', periodEnd: '#(currentPeriodEnd)', series: '#(codePrefix)' }
      * def v = call createFiscalYear { id: '#(pastFiscalYearId)', code: '#(pastFiscalCode)', periodStart: '#(pastPeriodStart)', periodEnd: '#(pastPeriodEnd)', series: '#(codePrefix)' }
      * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(pastFiscalYearId)', restrictEncumbrance: false, restrictExpenditures: false }
      * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
      * def v = call createBudget { id: '#(currentBudgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active', fiscalYearId: '#(currentFiscalYearId)' }
      * def v = call createBudget { id: '#(pastBudgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active', fiscalYearId: '#(pastFiscalYearId)' }

      * print "Create an order and 2 lines"
      * def v = call createOrder { id: '#(orderId)' }
      * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }
      * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

      * print "Open the order"
      * def v = call openOrder { orderId: '#(orderId)' }

      * print "Create encumbrances in the past fiscal year"
      * def v = call createTransaction { id: '#(pastEncumbranceId1)', transactionType: 'Encumbrance', fiscalYearId: '#(pastFiscalYearId)', fundId: '#(fundId)', amount: 10.0, orderId: '#(orderId)', poLineId: '#(poLineId1)' }
      * def v = call createTransaction { id: '#(pastEncumbranceId2)', transactionType: 'Encumbrance', fiscalYearId: '#(pastFiscalYearId)', fundId: '#(fundId)', amount: 10.0, orderId: '#(orderId)', poLineId: '#(poLineId2)' }

      * print "Create an invoice in the past fiscal year"
      * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(pastFiscalYearId)' }

      * print "Add invoice lines linked to the po lines, using the past encumbrances, with releaseEncumbrance=true and releaseEncumbrance=false"
      * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId1)', fundId: '#(fundId)', encumbranceId: '#(pastEncumbranceId1)', total: 10, releaseEncumbrance: true }
      * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId2)', fundId: '#(fundId)', encumbranceId: '#(pastEncumbranceId2)', total: 10, releaseEncumbrance: false }

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

      * print "Check the first order line payment status after paying"
      Given path 'orders/order-lines', poLineId1
      When method GET
      Then status 200
      And match $.paymentStatus == 'Fully Paid'

      * print "Check the second order line payment status after paying"
      Given path 'orders/order-lines', poLineId2
      When method GET
      Then status 200
      And match $.paymentStatus == 'Partially Paid'

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

      * print "Check the first order line payment status after cancelling"
      Given path 'orders/order-lines', poLineId1
      When method GET
      Then status 200
      And match $.paymentStatus == 'Cancelled'

      * print "Check the second order line payment status after cancelling"
      Given path 'orders/order-lines', poLineId2
      When method GET
      Then status 200
      And match $.paymentStatus == 'Partially Paid'
