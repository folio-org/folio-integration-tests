# For FAT-21151, https://foliotest.testrail.io/index.php?/cases/view/436938
Feature: Unreleased Encumbrance Is Rolled Over To The Next Fiscal Year

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
    * configure retry = { count: 15, interval: 15000 }
    * callonce variables

  @C436938
  @Positive
  Scenario: Unreleased Encumbrance Is Rolled Over To The Next Fiscal Year
    # 1. Generate Unique Identifiers For This Test Scenario
    * print '1. Generate Unique Identifiers For This Test Scenario'
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
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

    # 5. Create Fund And Budgets For Both Fiscal Years
    * print '5. Create Fund And Budgets For Both Fiscal Years'
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }

    # 6. Create One-Time Order With Re-Encumber Active And Open It
    * print '6. Create One-Time Order With Re-Encumber Active And Open It'
    * def v = call createOrder { id: '#(orderId)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10.00 }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 7. Create Invoice With Invoice Line (Release Encumbrance = True), Approve And Pay
    * print '7. Create Invoice With Invoice Line (Release Encumbrance = True), Approve And Pay'
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(fyId1)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId)', fundId: '#(fundId)', total: 10.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # 8. Verify Encumbrance Is Released After Payment And Unrelease It
    * print '8. Verify Encumbrance Is Released After Payment And Unrelease It'
    * def isEncumbranceReleased =
    """
    function(response) {
      return response.transactions != null &&
             response.transactions.length > 0 &&
             response.transactions[0].encumbrance.status == 'Released';
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until isEncumbranceReleased(response)
    When method GET
    Then status 200
    * def encumbranceId = response.transactions[0].id

    Given path 'finance/unrelease-encumbrance', encumbranceId
    When method POST
    Then status 204

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 9. Perform Rollover With One-Time Encumbrance Rollover Based On Initial Amount
    * print '9. Perform Rollover With One-Time Encumbrance Rollover Based On Initial Amount'
    * def budgetsRollover = [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }]
    * def encumbrancesRollover = [{ orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', restrictEncumbrance: true, restrictExpenditures: true, needCloseBudgets: true, budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 10. Verify Rollover Completed Successfully With No Errors
    * print '10. Verify Rollover Completed Successfully With No Errors'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 11. Verify FY#1 Budget Is Closed After Rollover (Current Budget)
    * print '11. Verify FY#1 Budget Is Closed After Rollover (Current Budget)'
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match response.budgetStatus == 'Closed'

    # 12. Verify FY#2 Budget Is Active (Planned Budget)
    * print '12. Verify FY#2 Budget Is Active (Planned Budget)'
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match response.budgetStatus == 'Active'

    # 13. Verify Encumbrance Transaction In FY#2 Is Unreleased With Initial Amount ($10.00)
    * print '13. Verify Encumbrance Transaction In FY#2 Is Unreleased With Initial Amount ($10.00)'
    * def isEncumbranceRolledOverCorrectly =
    """
    function(response) {
      if (!response.transactions || response.transactions.length == 0) return false;
      var t = response.transactions[0];
      return response.totalRecords == 1 &&
             t.amount == 10.00 &&
             t.fiscalYearId == fyId2 &&
             t.fromFundId == fundId &&
             t.encumbrance.sourcePoLineId == orderLineId &&
             t.encumbrance.status == 'Unreleased' &&
             t.encumbrance.initialAmountEncumbered == 10.00 &&
             t.encumbrance.amountAwaitingPayment == 0.00 &&
             t.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2
    And retry until isEncumbranceRolledOverCorrectly(response)
    When method GET
    Then status 200
