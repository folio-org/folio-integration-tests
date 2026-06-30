# For FAT-26793, https://foliotest.testrail.io/index.php?/cases/view/1347127
Feature: Rollover only ongoing encumbrances

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

  @C1347127
  @Positive
  Scenario: Rollover With Three Order Types And Only Ongoing Encumbrances Selected
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
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def orderId3 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def rolloverId = call uuid

    # 2. Create Fiscal Years And Ledger
    * print '2. Create Fiscal Years And Ledger'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

    # 3. Create Fund And Budgets For Both Fiscal Years
    * print '3. Create Fund And Budgets For Both Fiscal Years'
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }

    # 4. Create Orders: One-Time ($10), Ongoing Non-Subscription ($20), Ongoing Subscription ($30)
    * print '4. Create Orders: One-Time ($10), Ongoing Non-Subscription ($20), Ongoing Subscription ($30)'
    * def ongoingNonSub = { interval: 123, isSubscription: false }
    * def ongoingSub = { interval: 365, isSubscription: true }
    * table orders
      | id       | orderId  | orderType  | reEncumber | ongoing       |
      | orderId1 | orderId1 | 'One-Time' | true       | null          |
      | orderId2 | orderId2 | 'Ongoing'  | true       | ongoingNonSub |
      | orderId3 | orderId3 | 'Ongoing'  | false      | ongoingSub    |
    * def v = call createOrder orders

    # 5. Create Order Lines With Fund Distribution
    * print '5. Create Order Lines With Fund Distribution'
    * table orderLines
      | id        | orderId  | fundId | listUnitPrice |
      | poLineId1 | orderId1 | fundId | 10.0          |
      | poLineId2 | orderId2 | fundId | 20.0          |
      | poLineId3 | orderId3 | fundId | 30.0          |
    * def v = call createOrderLine orderLines

    # 6. Open Orders To Create Encumbrances In FY#1
    * print '6. Open Orders To Create Encumbrances In FY#1'
    * def v = call openOrder orders

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Perform Rollover With Only Ongoing (Non-Subscription) Encumbrances Selected, Based On Initial Amount
    * print '7. Perform Rollover With Only Ongoing (Non-Subscription) Encumbrances Selected, Based On Initial Amount'
    * def budgetsRollover = [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }]
    * def encumbrancesRollover = [{ orderType: 'Ongoing', basedOn: 'InitialAmount', increaseBy: 0 }]
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', restrictEncumbrance: true, needCloseBudgets: true, budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 8. Verify Rollover Completed Successfully With No Errors
    * print '8. Verify Rollover Completed Successfully With No Errors'
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

    # 9. Verify Order #1 (One-Time) Encumbrance In FY#2 Is Released With Zero Amount
    * print '9. Verify Order #1 (One-Time) Encumbrance In FY#2 Is Released With Zero Amount'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId1
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.transactions[0].amount == 0.0
    And match response.transactions[0].encumbrance.status == 'Released'
    And match response.transactions[0].encumbrance.initialAmountEncumbered == 0.0
    * def encumbranceId1 = response.transactions[0].id

    # 10. Verify Order #2 (Ongoing) Encumbrance In FY#2 Is Unreleased With Amount $20.00
    * print '10. Verify Order #2 (Ongoing) Encumbrance In FY#2 Is Unreleased With Amount $20.00'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId2
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.transactions[0].amount == 20.0
    And match response.transactions[0].encumbrance.status == 'Unreleased'
    And match response.transactions[0].encumbrance.initialAmountEncumbered == 20.0
    * def encumbranceId2 = response.transactions[0].id

    # 11. Verify Order #3 (Ongoing Subscription) Encumbrance In FY#2 Is Released With Zero Amount
    * print '11. Verify Order #3 (Ongoing Subscription) Encumbrance In FY#2 Is Released With Zero Amount'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId3
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.transactions[0].amount == 0.0
    And match response.transactions[0].encumbrance.status == 'Released'
    And match response.transactions[0].encumbrance.initialAmountEncumbered == 0.0
    * def encumbranceId3 = response.transactions[0].id

    # 12. Verify POL Encumbrance Links Point To New FY#2 Encumbrances
    * print '12. Verify POL Encumbrance Links Point To New FY#2 Encumbrances'
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    And match response.fundDistribution[0].encumbrance == encumbranceId1

    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    And match response.fundDistribution[0].encumbrance == encumbranceId2

    Given path 'orders/order-lines', poLineId3
    When method GET
    Then status 200
    And match response.fundDistribution[0].encumbrance == encumbranceId3
