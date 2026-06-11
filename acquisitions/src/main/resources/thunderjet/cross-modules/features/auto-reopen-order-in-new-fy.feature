  # For MODORDERS-1456
  Feature: Auto-reopen order in new FY

    Background:
      * print karate.info.scenarioName
      * url baseUrl

      * callonce login testUser
      * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
      * configure headers = headersUser

      * callonce variables

      * configure retry = { count: 10, interval: 500 }


    @Positive
    Scenario: Auto-reopen order by cancelling invoice in new FY
      # 1. Define new ids
      * def fyId1 = call uuid
      * def fyId2 = call uuid
      * def ledgerId = call uuid
      * def fundId = call uuid
      * def budgetId1 = call uuid
      * def budgetId2 = call uuid
      * def orderId = call uuid
      * def poLineId = call uuid
      * def invoiceId = call uuid
      * def invoiceLineId = call uuid
      * def rolloverId = call uuid

      # 2. Create fiscal years and associated ledgers
      * def fromYear = call getCurrentYear
      * def toYear = parseInt(fromYear) + 1
      * def periodStart1 = fromYear + '-01-01T00:00:00Z'
      * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
      * def series = call random_string
      * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
      * def periodStart2 = toYear + '-01-01T00:00:00Z'
      * def periodEnd2 = toYear + '-12-30T23:59:59Z'
      * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
      * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

      # 3. Create fund and budgets
      * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
      * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 100, status: 'Active' }
      * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 100, status: 'Active' }

      # 4. Create the order and line
      * def v = call createOrder { id: '#(orderId)', reEncumber: true }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

      # 5. Open the order
      * def v = call openOrder { orderId: '#(orderId)' }

      # 6. Create a related invoice and line
      * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(fyId1)' }
      * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', total: 10 }

      # 7. Approve and pay the invoice
      * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
      * def v = call payInvoice { invoiceId: '#(invoiceId)' }

      # 8. Receive the piece
      Given path 'orders/pieces'
      And param query = 'poLineId==' + poLineId
      When method GET
      Then status 200
      * def pieceId = $.pieces[0].id
      * def v = call receivePieceWithHolding { pieceId: '#(pieceId)', poLineId: '#(poLineId)' }
      * call pause 500

      # 9. Wait for the order to close automatically
      Given path 'orders/composite-orders', orderId
      And retry until response.workflowStatus == 'Closed'
      When method GET
      Then status 200

      # 10. Perform the fiscal year rollover
      * def budgetsRollover = [ { allowableEncumbrance: 100, allowableExpenditure: 100 } ]
      * def encumbrancesRollover = [ { orderType: 'One-time', basedOn: 'Remaining' } ]
      * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

      # 11. Check rollover status
      Given path 'finance/ledger-rollovers-progress'
      And param query = 'ledgerRolloverId==' + rolloverId
      When method GET
      Then status 200
      And match response.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']

      # 12 Update fiscal year dates so that we are in the second one
      * def v = call backdateFY { id: '#(fyId1)' }
      * def v = call backdateFY { id: '#(fyId2)' }

      # 13. Check the encumbrance link has been removed
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.fundDistribution[0].encumbrance == '#notpresent'

      # 14. Reactivate the past budget to cancel the invoice
      Given path 'finance/budgets', budgetId1
      When method GET
      Then status 200
      * def budget = $
      * set budget.budgetStatus = 'Active'
      Given path 'finance/budgets', budgetId1
      And request budget
      When method PUT
      Then status 204

      # 15. Cancel the invoice and wait for the order to reopen
      * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }
      Given path 'orders/composite-orders', orderId
      And retry until response.workflowStatus == 'Open'
      When method GET
      Then status 200

      # 16. Check an encumbrance was created in the new fiscal year and linked from the po line
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.fundDistribution[0].encumbrance == '#present'
      * def encumbranceId = $.fundDistribution[0].encumbrance
      Given path 'finance/transactions', encumbranceId
      When method GET
      Then status 200
      And match $.fiscalYearId == fyId2
      And match $.encumbrance.status == 'Unreleased'
      And match $.amount == 10.0


    @Positive
    Scenario: Auto-reopen order by unreceiving piece in new FY
      # 1. Define new ids
      * def fyId1 = call uuid
      * def fyId2 = call uuid
      * def ledgerId = call uuid
      * def fundId = call uuid
      * def budgetId1 = call uuid
      * def budgetId2 = call uuid
      * def orderId = call uuid
      * def poLineId = call uuid
      * def invoiceId = call uuid
      * def invoiceLineId = call uuid
      * def rolloverId = call uuid

      # 2. Create fiscal years and associated ledgers
      * def fromYear = call getCurrentYear
      * def toYear = parseInt(fromYear) + 1
      * def periodStart1 = fromYear + '-01-01T00:00:00Z'
      * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
      * def series = call random_string
      * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
      * def periodStart2 = toYear + '-01-01T00:00:00Z'
      * def periodEnd2 = toYear + '-12-30T23:59:59Z'
      * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
      * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

      # 3. Create fund and budgets
      * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
      * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 100, status: 'Active' }
      * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 100, status: 'Active' }

      # 4. Create the order and line
      * def v = call createOrder { id: '#(orderId)', reEncumber: true }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10 }

      # 5. Open the order
      * def v = call openOrder { orderId: '#(orderId)' }

      # 6. Create a related invoice and line
      * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(fyId1)' }
      * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId)', fundId: '#(fundId)', total: 10 }

      # 7. Approve and pay the invoice
      * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
      * def v = call payInvoice { invoiceId: '#(invoiceId)' }

      # 8. Receive the piece
      Given path 'orders/pieces'
      And param query = 'poLineId==' + poLineId
      When method GET
      Then status 200
      * def pieceId = $.pieces[0].id
      * def v = call receivePieceWithHolding { pieceId: '#(pieceId)', poLineId: '#(poLineId)' }
      * call pause 500

      # 9. Wait for the order to close automatically
      Given path 'orders/composite-orders', orderId
      And retry until response.workflowStatus == 'Closed'
      When method GET
      Then status 200

      # 10. Perform the fiscal year rollover
      * def budgetsRollover = [ { allowableEncumbrance: 100, allowableExpenditure: 100 } ]
      * def encumbrancesRollover = [ { orderType: 'One-time', basedOn: 'Remaining' } ]
      * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

      # 11. Check rollover status
      Given path 'finance/ledger-rollovers-progress'
      And param query = 'ledgerRolloverId==' + rolloverId
      When method GET
      Then status 200
      And match response.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']

      # 12. Update fiscal year dates so that we are in the second one
      * def v = call backdateFY { id: '#(fyId1)' }
      * def v = call backdateFY { id: '#(fyId2)' }

      # 13. Check the encumbrance link has been removed
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.fundDistribution[0].encumbrance == '#notpresent'

      # 14. Unreceive the piece and wait for the order to reopen
      * def v = call unreceivePieceLikeUI { pieceId: '#(pieceId)', poLineId: '#(poLineId)' }
      Given path 'orders/composite-orders', orderId
      And retry until response.workflowStatus == 'Open'
      When method GET
      Then status 200

      # 15. Check an encumbrance was created in the new fiscal year and linked from the po line
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.fundDistribution[0].encumbrance == '#present'
      * def encumbranceId = $.fundDistribution[0].encumbrance
      Given path 'finance/transactions', encumbranceId
      When method GET
      Then status 200
      And match $.fiscalYearId == fyId2
      And match $.encumbrance.status == 'Unreleased'
      And match $.amount == 10.0
