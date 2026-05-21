# For MODFISTO-483, UIF-611, https://foliotest.testrail.io/index.php?/cases/view/503142
Feature: Rollover Based On Expended When Credit Invoice Exists

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

  @C503142
  @Positive
  Scenario: Rollover Based On Expended When Credit Invoice Exists
    # 1. Generate Unique Identifiers For This Test Scenario
    * print '1. Generate Unique Identifiers For This Test Scenario'
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def creditInvoiceLineId = call uuid
    * def rolloverId = call uuid

    # 2. Create Fiscal Year #1 (Current Year)
    * print '2. Create Fiscal Year #1 (Current Year)'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }

    # 3. Create Fiscal Year #2 (Next Year)
    * print '3. Create Fiscal Year #2 (Next Year)'
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }

    # 4. Create Active Ledger Related To Fiscal Year #1
    * print '4. Create Active Ledger Related To Fiscal Year #1'
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

    # 5. Create Fund A With $100 Budget In Fiscal Year #1
    * print '5. Create Fund A With $100 Budget In Fiscal Year #1'
    * def v = call createFund { id: '#(fundAId)', code: '#(fundAId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundAId)', fiscalYearId: '#(fyId1)', allocated: 100, status: 'Active' }

    # 6. Create One-Time Order With Re-Encumber Enabled And POL With Fund A Distribution ($20)
    * print '6. Create One-Time Order With Re-Encumber Enabled And POL With Fund A Distribution ($20)'
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundId: '#(fundAId)', listUnitPrice: 20.00 }

    # 7. Open Order
    * print '7. Open Order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 8. Create Invoice With Regular Invoice Line ($10, Release Encumbrance = True) And Credit Invoice Line (-$5, Release Encumbrance = True) Linked To Same POL
    * print '8. Create Invoice With Regular Invoice Line ($10) And Credit Invoice Line (-$5) Linked To Same POL'
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(fyId1)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId)', fundId: '#(fundAId)', total: 10.00, releaseEncumbrance: true }
    * def v = call createInvoiceLine { invoiceLineId: '#(creditInvoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId)', fundId: '#(fundAId)', total: -5.00, releaseEncumbrance: true }

    # 9. Approve And Pay Invoice
    * print '9. Approve And Pay Invoice'
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 10. Perform Fiscal Year Rollover Based On Expended For One-Time Orders With Rollover Allocation Active
    * print '10. Perform Fiscal Year Rollover Based On Expended For One-Time Orders With Rollover Allocation Active'
    * def budgetsRollover = [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }]
    * def encumbrancesRollover = [{ orderType: 'One-time', basedOn: 'Expended', increaseBy: 0 }]
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', restrictEncumbrance: true, restrictExpenditures: true, needCloseBudgets: true, rolloverType: 'Commit', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 11. Verify Fund A Planned Budget In Fiscal Year #2 Has Encumbered $5.00 (Unavailable = $5.00)
    # Net expended in FY1: $10 paid - $5 credit = $5; rollover based on Expended creates $5 encumbrance in FY2
    * print '11. Verify Fund A Planned Budget In Fiscal Year #2 Has Encumbered $5.00 (Unavailable = $5.00)'
    * def validatePlannedBudget =
    """
    function(b) {
      return b.encumbered == 5.00 &&
             b.awaitingPayment == 0 &&
             b.expenditures == 0;
    }
    """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundAId + ' AND fiscalYearId==' + fyId2
    And retry until validatePlannedBudget(response.budgets[0])
    When method GET
    Then status 200
