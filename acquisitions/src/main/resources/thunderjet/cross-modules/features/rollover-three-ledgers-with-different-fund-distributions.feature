# For MODORDERS-1388, MODFISTO-549, https://foliotest.testrail.io/index.php?/cases/view/987720
Feature: Rollover Three Ledgers With Different Fund Distributions

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

  @C987720
  @Positive
  Scenario: Encumbrances Are Rollovered Correctly When PO Lines Contain Different Fund Distributions Related To Three Different Ledgers And Same Fiscal Year
    # 1. Generate Unique Identifiers For This Test Scenario
    * print '1. Generate Unique Identifiers For This Test Scenario'
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId1 = call uuid
    * def ledgerId2 = call uuid
    * def ledgerId3 = call uuid
    * def fundIdA = call uuid
    * def fundIdB = call uuid
    * def fundIdC = call uuid
    * def fundIdD = call uuid
    * def budgetId1A = call uuid
    * def budgetId1B = call uuid
    * def budgetId1C = call uuid
    * def budgetId1D = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def orderId3 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid
    * def poLineId5 = call uuid
    * def poLineId6 = call uuid
    * def poLineId7 = call uuid
    * def poLineId8 = call uuid
    * def poLineId9 = call uuid
    * def poLineId10 = call uuid
    * def rolloverId1 = call uuid
    * def rolloverId2 = call uuid
    * def rolloverId3 = call uuid

    # 2. Create Fiscal Years And Three Ledgers
    * print '2. Create Fiscal Years And Three Ledgers'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
    * def v = call createLedger { id: '#(ledgerId1)', fiscalYearId: '#(fyId1)' }
    * def v = call createLedger { id: '#(ledgerId2)', fiscalYearId: '#(fyId1)' }
    * def v = call createLedger { id: '#(ledgerId3)', fiscalYearId: '#(fyId1)' }

    # 3. Create Funds And Budgets For All Four Funds Across Three Ledgers
    # Ledger1: Fund A + Fund B, Ledger2: Fund C, Ledger3: Fund D
    * print '3. Create Funds And Budgets'
    * def v = call createFund { id: '#(fundIdA)', code: '#(fundIdA)', ledgerId: '#(ledgerId1)' }
    * def v = call createFund { id: '#(fundIdB)', code: '#(fundIdB)', ledgerId: '#(ledgerId1)' }
    * def v = call createFund { id: '#(fundIdC)', code: '#(fundIdC)', ledgerId: '#(ledgerId2)' }
    * def v = call createFund { id: '#(fundIdD)', code: '#(fundIdD)', ledgerId: '#(ledgerId3)' }
    * def v = call createBudget { id: '#(budgetId1A)', fundId: '#(fundIdA)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId1B)', fundId: '#(fundIdB)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId1C)', fundId: '#(fundIdC)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId1D)', fundId: '#(fundIdD)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 4. Create Ongoing Order #1 (reEncumber=false) With 3 PO Lines
    # POL1: FundA+FundB 50/50 $10, POL2: FundD $15, POL3: FundB+FundC 50/50 $20
    * print '4. Create Ongoing Order #1 (reEncumber=false) With 3 PO Lines'
    * def ongoingConfig = { 'interval': 123, 'isSubscription': false }
    * def v = call createOrder { id: '#(orderId1)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)', reEncumber: false }
    * table fundDistributionOrder1Line1
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId1)', fundDistribution: '#(fundDistributionOrder1Line1)', listUnitPrice: 10.00 }
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId1)', fundId: '#(fundIdD)', listUnitPrice: 15.00 }
    * table fundDistributionOrder1Line3
      | fundId  | code         | distributionType | value |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
      | fundIdC | '#(fundIdC)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId3)', orderId: '#(orderId1)', fundDistribution: '#(fundDistributionOrder1Line3)', listUnitPrice: 20.00 }

    # 5. Create One-Time Order #2 (reEncumber=true) With 3 PO Lines
    # POL4: FundA+B+C+D 25% each $30, POL5: FundA+B+C $11 each $33, POL6: FundA+FundB 50/50 $35
    * print '5. Create One-Time Order #2 (reEncumber=true) With 3 PO Lines'
    * def v = call createOrder { id: '#(orderId2)', orderType: 'One-Time', reEncumber: true }
    * table fundDistributionOrder2Line1
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 25    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 25    |
      | fundIdC | '#(fundIdC)' | 'percentage'     | 25    |
      | fundIdD | '#(fundIdD)' | 'percentage'     | 25    |
    * def v = call createOrderLine { id: '#(poLineId4)', orderId: '#(orderId2)', fundDistribution: '#(fundDistributionOrder2Line1)', listUnitPrice: 30.00 }
    * table fundDistributionOrder2Line2
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'amount'         | 11    |
      | fundIdB | '#(fundIdB)' | 'amount'         | 11    |
      | fundIdC | '#(fundIdC)' | 'amount'         | 11    |
    * def v = call createOrderLine { id: '#(poLineId5)', orderId: '#(orderId2)', fundDistribution: '#(fundDistributionOrder2Line2)', listUnitPrice: 33.00 }
    * table fundDistributionOrder2Line3
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId6)', orderId: '#(orderId2)', fundDistribution: '#(fundDistributionOrder2Line3)', listUnitPrice: 35.00 }

    # 6. Create Ongoing Order #3 (reEncumber=false) With 4 PO Lines
    # POL7: FundA $40, POL8: FundC $45, POL9: FundA+FundB 50/50 $50, POL10: FundC+FundD 50/50 $55
    * print '6. Create Ongoing Order #3 (reEncumber=false) With 4 PO Lines'
    * def v = call createOrder { id: '#(orderId3)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)', reEncumber: false }
    * def v = call createOrderLine { id: '#(poLineId7)', orderId: '#(orderId3)', fundId: '#(fundIdA)', listUnitPrice: 40.00 }
    * def v = call createOrderLine { id: '#(poLineId8)', orderId: '#(orderId3)', fundId: '#(fundIdC)', listUnitPrice: 45.00 }
    * table fundDistributionOrder3Line3
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId9)', orderId: '#(orderId3)', fundDistribution: '#(fundDistributionOrder3Line3)', listUnitPrice: 50.00 }
    * table fundDistributionOrder3Line4
      | fundId  | code         | distributionType | value |
      | fundIdC | '#(fundIdC)' | 'percentage'     | 50    |
      | fundIdD | '#(fundIdD)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId10)', orderId: '#(orderId3)', fundDistribution: '#(fundDistributionOrder3Line4)', listUnitPrice: 55.00 }

    # 7. Open All Orders
    * print '7. Open All Orders'
    * def v = call openOrder { orderId: '#(orderId1)' }
    * def v = call openOrder { orderId: '#(orderId2)' }
    * def v = call openOrder { orderId: '#(orderId3)' }

    # 8. Rollover All Three Ledgers FY1 To FY2 With Ongoing And One-Time Encumbrances
    * print '8. Rollover All Three Ledgers FY1 To FY2'
    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId1)",
        "ledgerId": "#(ledgerId1)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }],
        "encumbrancesRollover": [{ orderType: 'Ongoing', basedOn: 'InitialAmount', increaseBy: 0 }, { orderType: 'Ongoing-Subscription', basedOn: 'InitialAmount', increaseBy: 0 }, { orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
      }
      """
    When method POST
    Then status 201
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId2)",
        "ledgerId": "#(ledgerId2)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }],
        "encumbrancesRollover": [{ orderType: 'Ongoing', basedOn: 'InitialAmount', increaseBy: 0 }, { orderType: 'Ongoing-Subscription', basedOn: 'InitialAmount', increaseBy: 0 }, { orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
      }
      """
    When method POST
    Then status 201
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId3)",
        "ledgerId": "#(ledgerId3)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }],
        "encumbrancesRollover": [{ orderType: 'Ongoing', basedOn: 'InitialAmount', increaseBy: 0 }, { orderType: 'Ongoing-Subscription', basedOn: 'InitialAmount', increaseBy: 0 }, { orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
      }
      """
    When method POST
    Then status 201
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId3
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    # 8.1 Verify Rollover 1 (Ledger1 FY1->FY2) - Expected Error With Benign Order Warnings
    # Reason: POL3 (FundB+FundC) spans Ledger2 not yet rolled; Order2 POL4+POL5 span Ledger2/3 not yet rolled
    * print '8.1 Verify Rollover 1 Ledger1 FY1->FY2 - Expected Error With Benign Order Warnings'
    * def validateErrorWithWarnings =
      """
      function(r) {
        var p = r.ledgerFiscalYearRolloverProgresses[0];
        return p.overallRolloverStatus == 'Error' &&
               p.financialRolloverStatus == 'Error' &&
               p.ordersRolloverStatus == 'Success' &&
               p.budgetsClosingRolloverStatus == 'Success';
      }
      """
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    And retry until validateErrorWithWarnings(response)
    When method GET
    Then status 200

    * def validateBenignWarnings =
      """
      function(r) {
        return r.totalRecords > 0 &&
               r.ledgerFiscalYearRolloverErrors.every(function(e) {
                 return e.errorMessage.indexOf('[WARNING]') >= 0 &&
                        e.failedAction == 'Create encumbrance' &&
                        e.errorType == 'Order';
               });
      }
      """
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId1
    And retry until validateBenignWarnings(response)
    When method GET
    Then status 200

    # 8.2 Verify Rollover 2 (Ledger2 FY1->FY2) - Expected Error With Benign Order Warnings
    # Reason: Order2 POL4 (FundA+B+C+D) spans Ledger3 not yet rolled; Order3 POL10 (FundC+FundD) spans Ledger3 not yet rolled
    * print '8.2 Verify Rollover 2 Ledger2 FY1->FY2 - Expected Error With Benign Order Warnings'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    And retry until validateErrorWithWarnings(response)
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId2
    And retry until validateBenignWarnings(response)
    When method GET
    Then status 200

    # 8.3 Verify Rollover 3 (Ledger3 FY1->FY2) - Expected Success, No Warnings
    # Reason: Ledger3 is last - all other ledgers already rolled, no cross-ledger warnings
    * print '8.3 Verify Rollover 3 Ledger3 FY1->FY2 - Expected Success, No Warnings'
    * def validateRolloverSuccess =
      """
      function(r) {
        var p = r.ledgerFiscalYearRolloverProgresses[0];
        return p.overallRolloverStatus == 'Success' &&
               p.financialRolloverStatus == 'Success' &&
               p.ordersRolloverStatus == 'Success' &&
               p.budgetsClosingRolloverStatus == 'Success';
      }
      """
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId3
    And retry until validateRolloverSuccess(response)
    When method GET
    Then status 200

    * def v = call backdateFY { id: '#(fyId1)' }
    * def v = call backdateFY { id: '#(fyId2)' }

    # 9. Verify Order #1 (Ongoing, reEncumber=false) Encumbrances In FY2 - 5 Encumbrances (2+1+2), All Released, $0
    # POL1: FundA+FundB (2), POL2: FundD (1), POL3: FundB+FundC (2)
    * print '9. Verify Order #1 Total Encumbrances In FY2 - All Released And $0'
    * def validateOrder1 =
      """
      function(r) {
        return r.totalRecords == 5 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId1
    And retry until validateOrder1(response)
    When method GET
    Then status 200

    # 9.1 Verify Order #1 POL1 - FundA+FundB 50/50, 2 Encumbrances, Released, $0
    * print '9.1 Verify Order #1 POL1 - FundA+FundB, 2 Encumbrances, Released, $0'
    * def validatePOL1 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId1
    And retry until validatePOL1(response)
    When method GET
    Then status 200

    # 9.1.1 Verify Order #1 POL1 - Rollover Adjustment Is -$10.00
    * print '9.1.1 Verify Order #1 POL1 - Rollover Adjustment Is -$10.00'
    * def validatePOL1RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -10;
      }
      """
    Given path 'orders/order-lines', poLineId1
    And retry until validatePOL1RolloverAdj(response)
    When method GET
    Then status 200

    # 9.2 Verify Order #1 POL2 - FundD, 1 Encumbrance, Released, $0
    * print '9.2 Verify Order #1 POL2 - FundD, 1 Encumbrance, Released, $0'
    * def validatePOL2 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdD &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId2
    And retry until validatePOL2(response)
    When method GET
    Then status 200

    # 9.2.1 Verify Order #1 POL2 - Rollover Adjustment Is -$15.00
    * print '9.2.1 Verify Order #1 POL2 - Rollover Adjustment Is -$15.00'
    * def validatePOL2RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -15;
      }
      """
    Given path 'orders/order-lines', poLineId2
    And retry until validatePOL2RolloverAdj(response)
    When method GET
    Then status 200

    # 9.3 Verify Order #1 POL3 - FundB+FundC, 2 Encumbrances, Released, $0
    * print '9.3 Verify Order #1 POL3 - FundB+FundC, 2 Encumbrances, Released, $0'
    * def validatePOL3 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdC; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId3
    And retry until validatePOL3(response)
    When method GET
    Then status 200

    # 9.3.1 Verify Order #1 POL3 - Rollover Adjustment Is -$20.00
    * print '9.3.1 Verify Order #1 POL3 - Rollover Adjustment Is -$20.00'
    * def validatePOL3RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -20;
      }
      """
    Given path 'orders/order-lines', poLineId3
    And retry until validatePOL3RolloverAdj(response)
    When method GET
    Then status 200

    # 10. Verify Order #2 (One-Time, reEncumber=true) Encumbrances In FY2 - 9 Encumbrances (4+3+2), Unreleased With Correct Amounts
    # POL4: FundA+B+C+D $7.50 each (4), POL5: FundA+B+C $11 each (3), POL6: FundA+FundB $17.50 each (2)
    * print '10. Verify Order #2 Total Encumbrances In FY2 - 9 Unreleased With Correct Amounts'
    * def validateOrder2 =
      """
      function(r) {
        return r.totalRecords == 9 &&
               r.transactions.every(function(t) {
                 return t.encumbrance.status == 'Unreleased' &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId2
    And retry until validateOrder2(response)
    When method GET
    Then status 200

    # 10.1 Verify Order #2 POL4 - FundA+B+C+D, 4 Encumbrances, $7.50 Each, Unreleased
    * print '10.1 Verify Order #2 POL4 - FundA+B+C+D, 4 Encumbrances, $7.50 Each, Unreleased'
    * def validatePOL4 =
      """
      function(r) {
        return r.totalRecords == 4 &&
               r.transactions.every(function(t) {
                 return t.amount == 7.5 &&
                        t.encumbrance.status == 'Unreleased' &&
                        t.encumbrance.initialAmountEncumbered == 7.5 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdC; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdD; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId4
    And retry until validatePOL4(response)
    When method GET
    Then status 200

    # 10.2 Verify Order #2 POL5 - FundA+B+C, 3 Encumbrances, $11 Each, Unreleased
    * print '10.2 Verify Order #2 POL5 - FundA+B+C, 3 Encumbrances, $11 Each, Unreleased'
    * def validatePOL5 =
      """
      function(r) {
        return r.totalRecords == 3 &&
               r.transactions.every(function(t) {
                 return t.amount == 11 &&
                        t.encumbrance.status == 'Unreleased' &&
                        t.encumbrance.initialAmountEncumbered == 11 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdC; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId5
    And retry until validatePOL5(response)
    When method GET
    Then status 200

    # 10.3 Verify Order #2 POL6 - FundA+FundB, 2 Encumbrances, $17.50 Each, Unreleased
    * print '10.3 Verify Order #2 POL6 - FundA+FundB, 2 Encumbrances, $17.50 Each, Unreleased'
    * def validatePOL6 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 17.5 &&
                        t.encumbrance.status == 'Unreleased' &&
                        t.encumbrance.initialAmountEncumbered == 17.5 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId6
    And retry until validatePOL6(response)
    When method GET
    Then status 200

    # 11. Verify Order #3 (Ongoing, reEncumber=false) Encumbrances In FY2 - 6 Encumbrances (1+1+2+2), All Released, $0
    # POL7: FundA (1), POL8: FundC (1), POL9: FundA+FundB 50/50 (2), POL10: FundC+FundD 50/50 (2)
    * print '11. Verify Order #3 Total Encumbrances In FY2 - All Released And $0'
    * def validateOrder3 =
      """
      function(r) {
        return r.totalRecords == 6 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId3
    And retry until validateOrder3(response)
    When method GET
    Then status 200

    # 11.1 Verify Order #3 POL7 - FundA, 1 Encumbrance, Released, $0
    * print '11.1 Verify Order #3 POL7 - FundA, 1 Encumbrance, Released, $0'
    * def validatePOL7 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdA &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId7
    And retry until validatePOL7(response)
    When method GET
    Then status 200

    # 11.1.1 Verify Order #3 POL7 - Rollover Adjustment Is -$40.00
    * print '11.1.1 Verify Order #3 POL7 - Rollover Adjustment Is -$40.00'
    * def validatePOL7RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -40;
      }
      """
    Given path 'orders/order-lines', poLineId7
    And retry until validatePOL7RolloverAdj(response)
    When method GET
    Then status 200

    # 11.2 Verify Order #3 POL8 - FundC, 1 Encumbrance, Released, $0
    * print '11.2 Verify Order #3 POL8 - FundC, 1 Encumbrance, Released, $0'
    * def validatePOL8 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdC &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId8
    And retry until validatePOL8(response)
    When method GET
    Then status 200

    # 11.2.1 Verify Order #3 POL8 - Rollover Adjustment Is -$45.00
    * print '11.2.1 Verify Order #3 POL8 - Rollover Adjustment Is -$45.00'
    * def validatePOL8RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -45;
      }
      """
    Given path 'orders/order-lines', poLineId8
    And retry until validatePOL8RolloverAdj(response)
    When method GET
    Then status 200

    # 11.3 Verify Order #3 POL9 - FundA+FundB, 2 Encumbrances, Released, $0
    * print '11.3 Verify Order #3 POL9 - FundA+FundB, 2 Encumbrances, Released, $0'
    * def validatePOL9 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId9
    And retry until validatePOL9(response)
    When method GET
    Then status 200

    # 11.3.1 Verify Order #3 POL9 - Rollover Adjustment Is -$50.00
    * print '11.3.1 Verify Order #3 POL9 - Rollover Adjustment Is -$50.00'
    * def validatePOL9RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -50;
      }
      """
    Given path 'orders/order-lines', poLineId9
    And retry until validatePOL9RolloverAdj(response)
    When method GET
    Then status 200

    # 11.4 Verify Order #3 POL10 - FundC+FundD, 2 Encumbrances, Released, $0
    * print '11.4 Verify Order #3 POL10 - FundC+FundD, 2 Encumbrances, Released, $0'
    * def validatePOL10 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdC; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdD; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId10
    And retry until validatePOL10(response)
    When method GET
    Then status 200

    # 11.4.1 Verify Order #3 POL10 - Rollover Adjustment Is -$55.00
    * print '11.4.1 Verify Order #3 POL10 - Rollover Adjustment Is -$55.00'
    * def validatePOL10RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -55;
      }
      """
    Given path 'orders/order-lines', poLineId10
    And retry until validatePOL10RolloverAdj(response)
    When method GET
    Then status 200

    # 12. Verify Fund A Budget In FY2 - Encumbered $36.00 (7.50 + 11 + 17.50 from Order2 POL4+5+6), Available $964.00
    * print '12. Verify Fund A Budget In FY2 - Encumbered $36.00, Available $964.00'
    * def validateBudgetEncumbered36 =
      """
      function(b) {
        return b.encumbered == 36 &&
               b.awaitingPayment == 0 &&
               b.expenditures == 0 &&
               b.available == 964;
      }
      """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdA + ' AND fiscalYearId==' + fyId2
    And retry until validateBudgetEncumbered36(response.budgets[0])
    When method GET
    Then status 200

    # 13. Verify Fund B Budget In FY2 - Encumbered $36.00 (7.50 + 11 + 17.50 from Order2 POL4+5+6), Available $964.00
    * print '13. Verify Fund B Budget In FY2 - Encumbered $36.00, Available $964.00'
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdB + ' AND fiscalYearId==' + fyId2
    And retry until validateBudgetEncumbered36(response.budgets[0])
    When method GET
    Then status 200

    # 14. Verify Fund C Budget In FY2 - Encumbered $18.50 (7.50 + 11 from Order2 POL4+5), Available $981.50
    * print '14. Verify Fund C Budget In FY2 - Encumbered $18.50, Available $981.50'
    * def validateBudgetFundC =
      """
      function(b) {
        return b.encumbered == 18.5 &&
               b.awaitingPayment == 0 &&
               b.expenditures == 0 &&
               b.available == 981.5;
      }
      """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdC + ' AND fiscalYearId==' + fyId2
    And retry until validateBudgetFundC(response.budgets[0])
    When method GET
    Then status 200

    # 15. Verify Fund D Budget In FY2 - Encumbered $7.50 (7.50 from Order2 POL4 only), Available $992.50
    * print '15. Verify Fund D Budget In FY2 - Encumbered $7.50, Available $992.50'
    * def validateBudgetFundD =
      """
      function(b) {
        return b.encumbered == 7.5 &&
               b.awaitingPayment == 0 &&
               b.expenditures == 0 &&
               b.available == 992.5;
      }
      """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdD + ' AND fiscalYearId==' + fyId2
    And retry until validateBudgetFundD(response.budgets[0])
    When method GET
    Then status 200
