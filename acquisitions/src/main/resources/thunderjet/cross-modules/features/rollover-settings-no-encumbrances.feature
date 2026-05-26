# For FAT-21147, https://foliotest.testrail.io/index.php?/cases/view/356411
Feature: Rollover Settings Applying To Encumbrances With No Encumbrance Rollover Options

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

  @C356411
  @Positive
  Scenario: Rollover Settings Applying To Encumbrances With No Encumbrance Rollover Options Active
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
    * def oneTimeOrderId = call uuid
    * def oneTimePoLineId = call uuid
    * def ongoingOrderId = call uuid
    * def ongoingPoLineId = call uuid
    * def rolloverId = call uuid

    # 2. Create Two Fiscal Years With Non-Overlapping Periods And The Same Series
    * print '2. Create Two Fiscal Years With Non-Overlapping Periods And The Same Series'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }

    # 3. Create Ledger Associated With Fiscal Year #1
    * print '3. Create Ledger Associated With Fiscal Year #1'
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

    # 4. Create Fund And Budgets For Both Fiscal Years
    * print '4. Create Fund And Budgets For Both Fiscal Years'
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }

    # 5. Create One-Time Order With Re-Encumber Active And Open It
    * print '5. Create One-Time Order With Re-Encumber Active And Open It'
    * def v = call createOrder { id: '#(oneTimeOrderId)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(oneTimePoLineId)', orderId: '#(oneTimeOrderId)', fundId: '#(fundId)', listUnitPrice: 10.00, fiscalYearId: '#(fyId1)' }
    * def v = call openOrder { orderId: '#(oneTimeOrderId)' }

    # 6. Create Ongoing Order With Re-Encumber Active And Open It
    * print '6. Create Ongoing Order With Re-Encumber Active And Open It'
    * def ongoingConfig = { interval: 123, isSubscription: false }
    * def v = call createOrder { id: '#(ongoingOrderId)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)', reEncumber: true }
    * def v = call createOrderLine { id: '#(ongoingPoLineId)', orderId: '#(ongoingOrderId)', fundId: '#(fundId)', listUnitPrice: 10.00, fiscalYearId: '#(fyId1)' }
    * def v = call openOrder { orderId: '#(ongoingOrderId)' }

    # 7. Verify Ledger Encumbered Is Sum Of Both Orders ($20.00) And Current Fiscal Year Before Rollover
    * print '7. Verify Ledger Encumbered Is Sum Of Both Orders ($20.00) And Current Fiscal Year Before Rollover'
    * def isLedgerEncumberedCorrect =
    """
    function(response) {
      return response.id == ledgerId && response.encumbered == 20.00;
    }
    """
    Given path 'finance/ledgers', ledgerId
    And param fiscalYear = fyId1
    And retry until isLedgerEncumberedCorrect(response)
    When method GET
    Then status 200

    Given path 'finance/ledgers', ledgerId, 'current-fiscal-year'
    When method GET
    Then status 200
    And match response.id == fyId1

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Perform Rollover With All Encumbrance Options Inactive And No Budget Value Rollover
    * print '8. Perform Rollover With All Encumbrance Options Inactive And No Budget Value Rollover'
    * def budgetsRollover = [{ rolloverAllocation: false, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }]
    * def encumbrancesRollover = []
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', restrictEncumbrance: true, restrictExpenditures: true, needCloseBudgets: true, budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 9. Verify Rollover Completed Successfully With No Errors
    * print '9. Verify Rollover Completed Successfully With No Errors'
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

    # 10. Verify Budget For Fiscal Year #1 Is Closed After Rollover
    * print '10. Verify Budget For Fiscal Year #1 Is Closed After Rollover'
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match response.budgetStatus == 'Closed'

    # 11. Verify Budget For Fiscal Year #2 Has Encumbered = $0.00 (No Encumbrances Rolled Over)
    * print '11. Verify Budget For Fiscal Year #2 Has Encumbered = $0.00 (No Encumbrances Rolled Over)'
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match response.encumbered == 0.00
    And match response.awaitingPayment == 0.00
    And match response.expenditures == 0.00

    # 12. Verify Encumbrance Transactions In Fiscal Year #2 Have $0.00 Amount
    * print '12. Verify Encumbrance Transactions In Fiscal Year #2 Have $0.00 Amount'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match each response.transactions[*].amount == 0.00
