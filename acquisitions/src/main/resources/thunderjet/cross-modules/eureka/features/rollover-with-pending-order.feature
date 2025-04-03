  # For MODORDERS-1217
  Feature: Rollover with pending order

    Background:
      * print karate.info.scenarioName

      * url baseUrl
      * callonce login testAdmin
      * def okapitokenAdmin = okapitoken
      * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant':'#(testTenant)' }
      * configure headers = headersAdmin

      * callonce variables


    @Positive
    Scenario: Rollover a pending order with an encumbrance
      ## Define new ids
      * def fyId1 = call uuid
      * def fyId2 = call uuid
      * def ledgerId = call uuid
      * def fundId = call uuid
      * def budgetId1 = call uuid
      * def budgetId2 = call uuid
      * def orderId = call uuid
      * def poLineId = call uuid
      * def rolloverId = call uuid

      ## Create fiscal years and associated ledgers
      * def fromYear = call getCurrentYear
      * def toYear = parseInt(fromYear) + 1
      * def periodStart1 = fromYear + '-01-01T00:00:00Z'
      * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
      * def series = 'TESTFYC'
      * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
      * def periodStart2 = toYear + '-01-01T00:00:00Z'
      * def periodEnd2 = toYear + '-12-30T23:59:59Z'
      * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
      * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }


      ## Create fund and budgets
      * configure headers = headersAdmin
      * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
      * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 100, status: 'Active' }
      * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 100, status: 'Active' }


      ## Create the order and line
      * def ongoing = { interval: 123, isSubscription: true, renewalDate: '2022-05-08T00:00:00.000+00:00' }
      * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: '#(ongoing)', reEncumber: true }
      * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)' }


      # Open and unopen the order
      * def v = call openOrder { orderId: '#(orderId)' }
      * def v = call unopenOrder { orderId: '#(orderId)' }


      ## Fiscal year rollover
      * def budgetsRollover = [ { allowableEncumbrance: 100, allowableExpenditure: 100 } ]
      * def encumbrancesRollover = [ { orderType: 'Ongoing', basedOn: 'Remaining' } ]
      * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }


      ## Check rollover status
      Given path 'finance/ledger-rollovers-progress'
      And param query = 'ledgerRolloverId==' + rolloverId
      When method GET
      Then status 200
      And match response.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']


      ## Update fiscal year dates so that we are in the second one
      * def v = call backdateFY { id: '#(fyId1)' }
      * def v = call backdateFY { id: '#(fyId2)' }


      ## Check the encumbrance link has been removed
      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match $.fundDistribution[0].encumbrance == '#notpresent'


      ## Reopen the order in the new FY
      * def v = call openOrder { orderId: '#(orderId)' }
