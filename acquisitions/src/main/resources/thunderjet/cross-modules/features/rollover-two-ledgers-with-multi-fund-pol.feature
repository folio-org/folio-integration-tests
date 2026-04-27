# For MODORDERS-1388, MODFISTO-549, https://foliotest.testrail.io/index.php?/cases/view/987716
Feature: Rollover Two Ledgers With Multi-Fund POL

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

  @C987716
  @Positive
  Scenario: Encumbrances Are Rollovered Correctly When PO Lines Contain Fund Distributions Related To Two Different Ledgers And Same Fiscal Year
    # 1. Generate Unique Identifiers For This Test Scenario
    * print '1. Generate Unique Identifiers For This Test Scenario'
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId1 = call uuid
    * def ledgerId2 = call uuid
    * def fundIdA = call uuid
    * def fundIdB = call uuid
    * def budgetId1A = call uuid
    * def budgetId1B = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def orderId3 = call uuid
    * def orderId4 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid
    * def poLineId5 = call uuid
    * def poLineId6 = call uuid
    * def poLineId7 = call uuid
    * def poLineId8 = call uuid
    * def rolloverId1 = call uuid
    * def rolloverId2 = call uuid

    # 2. Create Fiscal Years And Associated Ledgers
    # Ledger1: Fund A, Ledger2: Fund B
    * print '2. Create Fiscal Years And Associated Ledgers'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
    * def v = call createLedger { id: '#(ledgerId1)', fiscalYearId: '#(fyId1)' }
    * def v = call createLedger { id: '#(ledgerId2)', fiscalYearId: '#(fyId1)' }

    # 3. Create Funds And Budgets
    * print '3. Create Funds And Budgets'
    * def v = call createFund { id: '#(fundIdA)', code: '#(fundIdA)', ledgerId: '#(ledgerId1)' }
    * def v = call createFund { id: '#(fundIdB)', code: '#(fundIdB)', ledgerId: '#(ledgerId2)' }
    * def v = call createBudget { id: '#(budgetId1A)', fundId: '#(fundIdA)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId1B)', fundId: '#(fundIdB)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 4. Create Order #1 (One-Time, reEncumber=false) With 2 PO Lines
    # POL1: FundA $10, POL2: FundA+FundB 50/50 $15
    * print '4. Create Order #1 (One-Time, reEncumber=false) With 2 PO Lines'
    * def v = call createOrder { id: '#(orderId1)', orderType: 'One-Time', reEncumber: false }
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId1)', fundId: '#(fundIdA)', listUnitPrice: 10.00 }
    * table fundDistributionOrder1Line2
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId1)', fundDistribution: '#(fundDistributionOrder1Line2)', listUnitPrice: 15.00 }

    # 5. Create Order #2 (One-Time, reEncumber=true) With 2 PO Lines
    # POL3: FundA $20, POL4: FundA+FundB 50/50 $25
    * print '5. Create Order #2 (One-Time, reEncumber=true) With 2 PO Lines'
    * def v = call createOrder { id: '#(orderId2)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(poLineId3)', orderId: '#(orderId2)', fundId: '#(fundIdA)', listUnitPrice: 20.00 }
    * table fundDistributionOrder2Line2
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId4)', orderId: '#(orderId2)', fundDistribution: '#(fundDistributionOrder2Line2)', listUnitPrice: 25.00 }

    # 6. Create Order #3 (One-Time, reEncumber=false) With 3 PO Lines
    # POL5: FundB $30, POL6: FundA+FundB 50/50 $35, POL7: FundA+FundB amount $20 each $40
    * print '6. Create Order #3 (One-Time, reEncumber=false) With 3 PO Lines'
    * def v = call createOrder { id: '#(orderId3)', orderType: 'One-Time', reEncumber: false }
    * def v = call createOrderLine { id: '#(poLineId5)', orderId: '#(orderId3)', fundId: '#(fundIdB)', listUnitPrice: 30.00 }
    * table fundDistributionOrder3Line2
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId6)', orderId: '#(orderId3)', fundDistribution: '#(fundDistributionOrder3Line2)', listUnitPrice: 35.00 }
    * table fundDistributionOrder3Line3
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'amount'         | 20    |
      | fundIdB | '#(fundIdB)' | 'amount'         | 20    |
    * def v = call createOrderLine { id: '#(poLineId7)', orderId: '#(orderId3)', fundDistribution: '#(fundDistributionOrder3Line3)', listUnitPrice: 40.00 }

    # 7. Create Order #4 (One-Time, reEncumber=true) With 1 PO Line
    # POL8: FundA+FundB 50/50 $50
    * print '7. Create Order #4 (One-Time, reEncumber=true) With 1 PO Line'
    * def v = call createOrder { id: '#(orderId4)', orderType: 'One-Time', reEncumber: true }
    * table fundDistributionOrder4Line1
      | fundId  | code         | distributionType | value |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: '#(poLineId8)', orderId: '#(orderId4)', fundDistribution: '#(fundDistributionOrder4Line1)', listUnitPrice: 50.00 }

    # 8. Open All 4 Orders
    * print '8. Open All 4 Orders'
    * def v = call openOrder { orderId: '#(orderId1)' }
    * def v = call openOrder { orderId: '#(orderId2)' }
    * def v = call openOrder { orderId: '#(orderId3)' }
    * def v = call openOrder { orderId: '#(orderId4)' }

    # 9. Rollover Both Ledgers From FY1 To FY2 With One-Time Encumbrances Based On Initial Amount
    * print '9. Rollover Both Ledgers From FY1 To FY2'
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
        "encumbrancesRollover": [{ orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
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
        "encumbrancesRollover": [{ orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
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

    # 9.1 Verify Rollover 1 (Ledger1 FY1->FY2) - Expected Error With Benign Order Warnings
    # Reason: POL2, POL4, POL6, POL7, POL8 all span FundB (Ledger2) which has not been rolled yet
    * print '9.1 Verify Rollover 1 Ledger1 FY1->FY2 - Expected Error With Benign Order Warnings'
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

    # 9.2 Verify Rollover 2 (Ledger2 FY1->FY2) - Expected Success, No Warnings
    # Reason: Ledger2 is last - Ledger1 already rolled, no cross-ledger warnings
    * print '9.2 Verify Rollover 2 Ledger2 FY1->FY2 - Expected Success, No Warnings'
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
    And param query = 'ledgerRolloverId==' + rolloverId2
    And retry until validateRolloverSuccess(response)
    When method GET
    Then status 200

    * def v = call backdateFY { id: '#(fyId1)' }
    * def v = call backdateFY { id: '#(fyId2)' }

    # 10. Verify Order #1 (One-Time, reEncumber=false) Encumbrances In FY2 - 3 Encumbrances (1+2), All Released, $0
    # POL1: FundA (1), POL2: FundA+FundB (2)
    * print '10. Verify Order #1 Total Encumbrances In FY2 - All Released And $0'
    * def validateOrder1 =
      """
      function(r) {
        return r.totalRecords == 3 &&
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

    # 10.1 Verify Order #1 POL1 - FundA, 1 Encumbrance, Released, $0
    * print '10.1 Verify Order #1 POL1 - FundA, 1 Encumbrance, Released, $0'
    * def validatePOL1 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId1
    And retry until validatePOL1(response)
    When method GET
    Then status 200

    # 10.1.1 Verify Order #1 POL1 - Rollover Adjustment Is -$10.00
    * print '10.1.1 Verify Order #1 POL1 - Rollover Adjustment Is -$10.00'
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

    # 10.2 Verify Order #1 POL2 - FundA+FundB, 2 Encumbrances, Released, $0
    * print '10.2 Verify Order #1 POL2 - FundA+FundB, 2 Encumbrances, Released, $0'
    * def validatePOL2 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId2
    And retry until validatePOL2(response)
    When method GET
    Then status 200

    # 10.2.1 Verify Order #1 POL2 - Rollover Adjustment Is -$15.00
    * print '10.2.1 Verify Order #1 POL2 - Rollover Adjustment Is -$15.00'
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

    # 11. Verify Order #2 (One-Time, reEncumber=true) Encumbrances In FY2 - 3 Encumbrances (1+2), Unreleased With Correct Amounts
    # POL3: FundA $20 (1), POL4: FundA+FundB $12.50 each (2)
    * print '11. Verify Order #2 Total Encumbrances In FY2 - 3 Unreleased With Correct Amounts'
    * def validateOrder2 =
      """
      function(r) {
        return r.totalRecords == 3 &&
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

    # 11.1 Verify Order #2 POL3 - FundA, 1 Encumbrance, $20, Unreleased
    * print '11.1 Verify Order #2 POL3 - FundA, 1 Encumbrance, $20, Unreleased'
    * def validatePOL3 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 20 &&
               t.fromFundId == fundIdA &&
               t.encumbrance.status == 'Unreleased' &&
               t.encumbrance.initialAmountEncumbered == 20 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId3
    And retry until validatePOL3(response)
    When method GET
    Then status 200

    # 11.2 Verify Order #2 POL4 - FundA+FundB, 2 Encumbrances, $12.50 Each, Unreleased
    * print '11.2 Verify Order #2 POL4 - FundA+FundB, 2 Encumbrances, $12.50 Each, Unreleased'
    * def validatePOL4 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 12.5 &&
                        t.encumbrance.status == 'Unreleased' &&
                        t.encumbrance.initialAmountEncumbered == 12.5 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId4
    And retry until validatePOL4(response)
    When method GET
    Then status 200

    # 12. Verify Order #3 (One-Time, reEncumber=false) Encumbrances In FY2 - 5 Encumbrances (1+2+2), All Released, $0
    # POL5: FundB (1), POL6: FundA+FundB (2), POL7: FundA+FundB (2)
    * print '12. Verify Order #3 Total Encumbrances In FY2 - All Released And $0'
    * def validateOrder3 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId3
    And retry until validateOrder3(response)
    When method GET
    Then status 200

    # 12.1 Verify Order #3 POL5 - FundB, 1 Encumbrance, Released, $0
    * print '12.1 Verify Order #3 POL5 - FundB, 1 Encumbrance, Released, $0'
    * def validatePOL5 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdB &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId5
    And retry until validatePOL5(response)
    When method GET
    Then status 200

    # 12.1.1 Verify Order #3 POL5 - Rollover Adjustment Is -$30.00
    * print '12.1.1 Verify Order #3 POL5 - Rollover Adjustment Is -$30.00'
    * def validatePOL5RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -30;
      }
      """
    Given path 'orders/order-lines', poLineId5
    And retry until validatePOL5RolloverAdj(response)
    When method GET
    Then status 200

    # 12.2 Verify Order #3 POL6 - FundA+FundB, 2 Encumbrances, Released, $0
    * print '12.2 Verify Order #3 POL6 - FundA+FundB, 2 Encumbrances, Released, $0'
    * def validatePOL6 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId6
    And retry until validatePOL6(response)
    When method GET
    Then status 200

    # 12.2.1 Verify Order #3 POL6 - Rollover Adjustment Is -$35.00
    * print '12.2.1 Verify Order #3 POL6 - Rollover Adjustment Is -$35.00'
    * def validatePOL6RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -35;
      }
      """
    Given path 'orders/order-lines', poLineId6
    And retry until validatePOL6RolloverAdj(response)
    When method GET
    Then status 200

    # 12.3 Verify Order #3 POL7 - FundA+FundB Amount $20 Each, 2 Encumbrances, Released, $0
    * print '12.3 Verify Order #3 POL7 - FundA+FundB, 2 Encumbrances, Released, $0'
    * def validatePOL7 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId7
    And retry until validatePOL7(response)
    When method GET
    Then status 200

    # 12.3.1 Verify Order #3 POL7 - Rollover Adjustment Is -$40.00
    * print '12.3.1 Verify Order #3 POL7 - Rollover Adjustment Is -$40.00'
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

    # 13. Verify Order #4 (One-Time, reEncumber=true) Encumbrances In FY2 - 2 Encumbrances, $25 Each, Unreleased
    # POL8: FundA+FundB 50/50 $50 -> $25 each
    * print '13. Verify Order #4 Total Encumbrances In FY2 - 2 Unreleased, $25 Each'
    * def validateOrder4 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 25 &&
                        t.encumbrance.status == 'Unreleased' &&
                        t.encumbrance.initialAmountEncumbered == 25 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdB; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId4
    And retry until validateOrder4(response)
    When method GET
    Then status 200

    # 14. Verify Fund A Budget In FY2 - Encumbered $57.50 (20 + 12.50 + 25 from Orders 2+4), Available $942.50
    # Order2/POL3: FundA $20, Order2/POL4: FundA $12.50, Order4/POL8: FundA $25
    * print '14. Verify Fund A Budget In FY2 - Encumbered $57.50, Available $942.50'
    * def validateBudgetFundA =
      """
      function(b) {
        return b.encumbered == 57.5 &&
               b.awaitingPayment == 0 &&
               b.expenditures == 0 &&
               b.available == 942.5;
      }
      """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdA + ' AND fiscalYearId==' + fyId2
    And retry until validateBudgetFundA(response.budgets[0])
    When method GET
    Then status 200

    # 15. Verify Fund B Budget In FY2 - Encumbered $37.50 (12.50 + 25 from Orders 2+4), Available $962.50
    # Order2/POL4: FundB $12.50, Order4/POL8: FundB $25
    * print '15. Verify Fund B Budget In FY2 - Encumbered $37.50, Available $962.50'
    * def validateBudgetFundB =
      """
      function(b) {
        return b.encumbered == 37.5 &&
               b.awaitingPayment == 0 &&
               b.expenditures == 0 &&
               b.available == 962.5;
      }
      """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdB + ' AND fiscalYearId==' + fyId2
    And retry until validateBudgetFundB(response.budgets[0])
    When method GET
    Then status 200
