# For MODORDERS-841, MODORDERS-800, MODORDERS-834, MODFISTO-370, UIF-611, https://foliotest.testrail.io/index.php?/cases/view/375102
Feature: Rollover After Fund Distribution Change With Paid Invoice Based On Initial Encumbrance

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
    * configure retry = { count: 15, interval: 500 }
    * callonce variables

  @C375102
  @Positive
  Scenario: Rollover After Fund Distribution Change With Paid Invoice Based On Initial Encumbrance
    # 1. Generate Unique Identifiers For This Test Scenario
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId = call uuid
    * def budgetBId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def rolloverId = call uuid

    # 2. Create Fiscal Year #1 (Current Year) And Fiscal Year #2 (Next Year)
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }

    # 3. Create Active Ledger Related To Fiscal Year #1
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

    # 4. Create Fund A And Budget A With $1000 Allocation In Fiscal Year #1
    * def v = call createFund { id: '#(fundAId)', code: '#(fundAId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetAId)', fundId: '#(fundAId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }

    # 5. Create Fund B And Budget B With $1000 Allocation In Fiscal Year #1
    * def v = call createFund { id: '#(fundBId)', code: '#(fundBId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetBId)', fundId: '#(fundBId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }

    # 6. Create One-Time Order With Re-Encumber Enabled And POL With Fund A Distribution ($10)
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundId: '#(fundAId)', listUnitPrice: 10.00 }

    # 7. Open Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 8. Create Invoice With Invoice Line ($10, Release Encumbrance = True) Linked To POL And Fiscal Year #1
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(fyId1)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId)', fundId: '#(fundAId)', total: 10.00, releaseEncumbrance: true }

    # 9. Approve And Pay Invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 10. Change Fund Distribution In POL From Fund A To Fund B
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def poLine = response
    * set poLine.fundDistribution[0].fundId = fundBId
    * set poLine.fundDistribution[0].code = fundBId
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 11. Verify Encumbrance For Fund B Is Created As Released With $0 Amount And Initial Amount $10
    * def validateFundBEncumbrance =
    """
    function(response) {
      var t = response.transactions[0];
      return t.amount == 0.00 &&
             t.encumbrance.status == 'Released' &&
             t.encumbrance.initialAmountEncumbered == 10.00 &&
             t.encumbrance.amountExpended == 10.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND encumbrance.sourcePurchaseOrderId==' + orderId + ' AND fromFundId==' + fundBId
    And retry until validateFundBEncumbrance(response)
    When method GET
    Then status 200

    # 12. Perform Fiscal Year Rollover With One-Time Encumbrances Based On Initial Encumbrance
    * def budgetsRollover = [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }]
    * def encumbrancesRollover = [{ orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', restrictEncumbrance: true, restrictExpenditures: true, needCloseBudgets: true, rolloverType: 'Commit', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    * def validateBudget =
    """
    function(b, expectedEncumbered, expectedAvailable) {
      return b.encumbered == expectedEncumbered &&
             b.awaitingPayment == 0 &&
             b.expenditures == 0 &&
             b.available == expectedAvailable;
    }
    """

    # 13. Verify Fund A Planned Budget In Fiscal Year #2 Has Encumbered $0.00 (Unavailable = $0.00)
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundAId + ' AND fiscalYearId==' + fyId2
    And retry until validateBudget(response.budgets[0], 0.00, 1000.00)
    When method GET
    Then status 200

    # 14. Verify Fund B Planned Budget In Fiscal Year #2 Has Encumbered $10.00 (Unavailable = $10.00)
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundBId + ' AND fiscalYearId==' + fyId2
    And retry until validateBudget(response.budgets[0], 10.00, 990.00)
    When method GET
    Then status 200
