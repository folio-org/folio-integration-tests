# For MODORDERS-1388, https://foliotest.testrail.io/index.php?/cases/view/987717
Feature: Rollover Three Ledgers With Expense Classes Twice

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

  @C987717
  @Positive
  Scenario: Encumbrances Are Rollovered Correctly When PO Lines Contain Fund Distributions Related To Three Different Ledgers And Same Fiscal Year
    # 1. Generate Unique Identifiers For This Test Scenario
    * print '1. Generate Unique Identifiers For This Test Scenario'
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def midYear = parseInt(fromYear) + 1
    * def toYear = parseInt(fromYear) + 2
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def fyId3 = call uuid
    * def ledgerId1 = call uuid
    * def ledgerId2 = call uuid
    * def ledgerId3 = call uuid
    * def fundIdA = call uuid
    * def fundIdB = call uuid
    * def fundIdC = call uuid
    * def budgetId1A = call uuid
    * def budgetId2A = call uuid
    * def budgetId3A = call uuid
    * def budgetId1B = call uuid
    * def budgetId2B = call uuid
    * def budgetId3B = call uuid
    * def budgetId1C = call uuid
    * def budgetId2C = call uuid
    * def budgetId3C = call uuid
    * def expenseClassId1 = call uuid
    * def expenseClassId2 = call uuid
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
    * def rolloverId1 = call uuid
    * def rolloverId2 = call uuid
    * def rolloverId3 = call uuid
    * def rolloverId4 = call uuid
    * def rolloverId5 = call uuid
    * def rolloverId6 = call uuid

    # 2. Create Three Fiscal Years And Three Ledgers
    * print '2. Create Three Fiscal Years And Three Ledgers'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = midYear + '-01-01T00:00:00Z'
    * def periodEnd2 = midYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }
    * def periodStart3 = toYear + '-01-01T00:00:00Z'
    * def periodEnd3 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId3)', code: '#(series + "0003")', periodStart: '#(periodStart3)', periodEnd: '#(periodEnd3)', series: '#(series)' }
    * def v = call createLedger { id: '#(ledgerId1)', fiscalYearId: '#(fyId1)' }
    * def v = call createLedger { id: '#(ledgerId2)', fiscalYearId: '#(fyId1)' }
    * def v = call createLedger { id: '#(ledgerId3)', fiscalYearId: '#(fyId1)' }

    # 3. Create Expense Classes
    * print '3. Create Expense Classes'
    * def v = call createExpenseClass { id: '#(expenseClassId1)', code: 'EC1', name: 'Electronic-EC1', externalAccountNumberExt: 'EC1' }
    * def v = call createExpenseClass { id: '#(expenseClassId2)', code: 'EC2', name: 'Print-EC2', externalAccountNumberExt: 'EC2' }

    # 4. Create Funds And Budgets With Expense Classes
    * print '4. Create Funds And Budgets With Expense Classes'
    * def v = call createFund { id: '#(fundIdA)', code: '#(fundIdA)', ledgerId: '#(ledgerId1)' }
    * def v = call createFund { id: '#(fundIdB)', code: '#(fundIdB)', ledgerId: '#(ledgerId2)' }
    * def v = call createFund { id: '#(fundIdC)', code: '#(fundIdC)', ledgerId: '#(ledgerId3)' }
    # FY1 budgets
    * def v = call createBudget { id: '#(budgetId1A)', fundId: '#(fundIdA)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudgetExpenseClass { budgetId: '#(budgetId1A)', expenseClassId: '#(expenseClassId1)' }
    * def v = call createBudgetExpenseClass { budgetId: '#(budgetId1A)', expenseClassId: '#(expenseClassId2)' }
    * def v = call createBudget { id: '#(budgetId1B)', fundId: '#(fundIdB)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudgetExpenseClass { budgetId: '#(budgetId1B)', expenseClassId: '#(expenseClassId1)' }
    * def v = call createBudgetExpenseClass { budgetId: '#(budgetId1B)', expenseClassId: '#(expenseClassId2)' }
    * def v = call createBudget { id: '#(budgetId1C)', fundId: '#(fundIdC)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    # FY2 budgets
    # Note: createBudget automatically copies budget-expense-class records from the fund's existing active budget,
    # so explicit createBudgetExpenseClass calls for FY2/FY3 budgets are not needed and would cause 400 duplicates.
    * def v = call createBudget { id: '#(budgetId2A)', fundId: '#(fundIdA)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2B)', fundId: '#(fundIdB)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2C)', fundId: '#(fundIdC)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }
    # FY3 budgets
    * def v = call createBudget { id: '#(budgetId3A)', fundId: '#(fundIdA)', fiscalYearId: '#(fyId3)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId3B)', fundId: '#(fundIdB)', fiscalYearId: '#(fyId3)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId3C)', fundId: '#(fundIdC)', fiscalYearId: '#(fyId3)', allocated: 1000, status: 'Active' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Create Ongoing Order #1 (reEncumber=false) With 3 PO Lines With Expense Classes
    * print '5. Create Ongoing Order #1 (reEncumber=false) With 3 PO Lines'
    * def ongoingConfig = { 'interval': 123, 'isSubscription': false }
    * def v = call createOrder { id: '#(orderId1)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)', reEncumber: false }
    * table fundDistributionOrder1Line1
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 100   | expenseClassId1  |
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId1)', fundDistribution: '#(fundDistributionOrder1Line1)', listUnitPrice: 10.00 }
    * table fundDistributionOrder1Line2
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 50    | expenseClassId1  |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    | expenseClassId1  |
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId1)', fundDistribution: '#(fundDistributionOrder1Line2)', listUnitPrice: 15.00 }
    * table fundDistributionOrder1Line3
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdA | '#(fundIdA)' | 'amount'         | 5     | expenseClassId1  |
      | fundIdB | '#(fundIdB)' | 'amount'         | 5     | expenseClassId1  |
      | fundIdC | '#(fundIdC)' | 'amount'         | 5     |                  |
    * def v = call createOrderLine { id: '#(poLineId3)', orderId: '#(orderId1)', fundDistribution: '#(fundDistributionOrder1Line3)', listUnitPrice: 15.00 }

    # 6. Create Ongoing Order #2 (reEncumber=false) With 2 PO Lines With Expense Classes
    * print '6. Create Ongoing Order #2 (reEncumber=false) With 2 PO Lines'
    * def v = call createOrder { id: '#(orderId2)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)', reEncumber: false }
    * table fundDistributionOrder2Line1
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdA | '#(fundIdA)' | 'percentage'     | 100   | expenseClassId1  |
    * def v = call createOrderLine { id: '#(poLineId4)', orderId: '#(orderId2)', fundDistribution: '#(fundDistributionOrder2Line1)', listUnitPrice: 20.00 }
    * table fundDistributionOrder2Line2
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdA | '#(fundIdA)' | 'amount'         | 8     | expenseClassId1  |
      | fundIdA | '#(fundIdA)' | 'amount'         | 8     | expenseClassId2  |
      | fundIdC | '#(fundIdC)' | 'amount'         | 8     |                  |
    * def v = call createOrderLine { id: '#(poLineId5)', orderId: '#(orderId2)', fundDistribution: '#(fundDistributionOrder2Line2)', listUnitPrice: 24.00 }

    # 7. Create Ongoing Order #3 (reEncumber=false) With 2 PO Lines With Expense Classes
    * print '7. Create Ongoing Order #3 (reEncumber=false) With 2 PO Lines'
    * def v = call createOrder { id: '#(orderId3)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)', reEncumber: false }
    * table fundDistributionOrder3Line1
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 100   | expenseClassId1  |
    * def v = call createOrderLine { id: '#(poLineId6)', orderId: '#(orderId3)', fundDistribution: '#(fundDistributionOrder3Line1)', listUnitPrice: 30.00 }
    * table fundDistributionOrder3Line2
      | fundId  | code         | distributionType | value | expenseClassId   |
      | fundIdB | '#(fundIdB)' | 'percentage'     | 50    | expenseClassId2  |
      | fundIdC | '#(fundIdC)' | 'percentage'     | 50    |                  |
    * def v = call createOrderLine { id: '#(poLineId7)', orderId: '#(orderId3)', fundDistribution: '#(fundDistributionOrder3Line2)', listUnitPrice: 35.00 }

    # 8. Open All Orders
    * print '8. Open All Orders'
    * def v = call openOrder { orderId: '#(orderId1)' }
    * def v = call openOrder { orderId: '#(orderId2)' }
    * def v = call openOrder { orderId: '#(orderId3)' }

    # 9. First Rollover: All Three Ledgers FY1 To FY2 - No Encumbrances Rolled
    * print '9. First Rollover: All Three Ledgers FY1 To FY2 - No Encumbrances Rolled'
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
        "encumbrancesRollover": []
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
        "encumbrancesRollover": []
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
        "encumbrancesRollover": []
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

    # 9.1 Verify Rollover 1 (Ledger1 FY1->FY2) - Expected Error With Benign Order Warnings
    # Reason: POL2 (FundA+FundB) and POL3 (FundA+FundB+FundC) and POL5 (FundA+FundC) span Ledger2/Ledger3 not yet rolled
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

    # 9.2 Verify Rollover 2 (Ledger2 FY1->FY2) - Expected Error With Benign Order Warnings
    # Reason: POL3 (FundA+FundB+FundC) and POL7 (FundB+FundC) span Ledger3 not yet rolled
    * print '9.2 Verify Rollover 2 Ledger2 FY1->FY2 - Expected Error With Benign Order Warnings'
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

    # 9.3 Verify Rollover 3 (Ledger3 FY1->FY2) - Expected Success, No Warnings
    # Reason: Ledger3 is last - all other ledgers already rolled, no cross-ledger warnings
    * print '9.3 Verify Rollover 3 Ledger3 FY1->FY2 - Expected Success, No Warnings'
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

    # 12. Second Rollover: All Three Ledgers FY2 To FY3 - No Encumbrances Rolled
    * print '12. Second Rollover: All Three Ledgers FY2 To FY3 - No Encumbrances Rolled'
    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId4)",
        "ledgerId": "#(ledgerId1)",
        "fromFiscalYearId": "#(fyId2)",
        "toFiscalYearId": "#(fyId3)",
        "restrictEncumbrance": true,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }],
        "encumbrancesRollover": []
      }
      """
    When method POST
    Then status 201
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId4
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId5)",
        "ledgerId": "#(ledgerId2)",
        "fromFiscalYearId": "#(fyId2)",
        "toFiscalYearId": "#(fyId3)",
        "restrictEncumbrance": true,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }],
        "encumbrancesRollover": []
      }
      """
    When method POST
    Then status 201
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId5
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId6)",
        "ledgerId": "#(ledgerId3)",
        "fromFiscalYearId": "#(fyId2)",
        "toFiscalYearId": "#(fyId3)",
        "restrictEncumbrance": true,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }],
        "encumbrancesRollover": []
      }
      """
    When method POST
    Then status 201
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId6
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    # 12.1 Verify Rollover 4 (Ledger1 FY2->FY3) - Expected Error With Benign Order Warnings
    # Reason: Same cross-ledger POLs as Rollover 1 - Ledger2/Ledger3 not yet rolled
    * print '12.1 Verify Rollover 4 Ledger1 FY2->FY3 - Expected Error With Benign Order Warnings'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId4
    And retry until validateErrorWithWarnings(response)
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId4
    And retry until validateBenignWarnings(response)
    When method GET
    Then status 200

    # 12.2 Verify Rollover 5 (Ledger2 FY2->FY3) - Expected Error With Benign Order Warnings
    # Reason: Same cross-ledger POLs as Rollover 2 - Ledger3 not yet rolled
    * print '12.2 Verify Rollover 5 Ledger2 FY2->FY3 - Expected Error With Benign Order Warnings'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId5
    And retry until validateErrorWithWarnings(response)
    When method GET
    Then status 200

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId5
    And retry until validateBenignWarnings(response)
    When method GET
    Then status 200

    # 12.3 Verify Rollover 6 (Ledger3 FY2->FY3) - Expected Success, No Warnings
    # Reason: Ledger3 is last - all other ledgers already rolled, no cross-ledger warnings
    * print '12.3 Verify Rollover 6 Ledger3 FY2->FY3 - Expected Success, No Warnings'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId6
    And retry until validateRolloverSuccess(response)
    When method GET
    Then status 200

    * def v = call backdateFY { id: '#(fyId2)' }
    * def v = call backdateFY { id: '#(fyId3)' }

    # 14. Verify All Encumbrances In FY3 For All Orders Are $0, Released, And Have Zero Initial Amount
    * print '14. Verify All Encumbrances In FY3 Are $0, Released, And Initial Encumbrance Is $0'
    * def isAllReleasedAndZero =
      """
      function(r) {
        return r.transactions.every(function(t) {
          return t.amount == 0 &&
                 t.encumbrance.status == 'Released' &&
                 t.encumbrance.initialAmountEncumbered == 0 &&
                 t.encumbrance.amountAwaitingPayment == 0 &&
                 t.encumbrance.amountExpended == 0;
        });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3
    And retry until isAllReleasedAndZero(response)
    When method GET
    Then status 200

    # 15. Verify Order #1 Encumbrances In FY3 - 6 Encumbrances (1+2+3), All Released, $0
    * print '15. Verify Order #1 Total Encumbrances In FY3 - All Released And $0'
    * def validateOrder1 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId1
    And retry until validateOrder1(response)
    When method GET
    Then status 200

    # 15.1 Verify Order #1 POL1 - FundA With Expense Class #1, 1 Encumbrance
    * print '15.1 Verify Order #1 POL1 - FundA EC1, 1 Encumbrance, Released, $0'
    * def validatePOL1 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdA &&
               t.expenseClassId == expenseClassId1 &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId1
    And retry until validatePOL1(response)
    When method GET
    Then status 200

    # 15.1.1 Verify Order #1 POL1 - Rollover Adjustment Is -$10.00
    * print '15.1.1 Verify Order #1 POL1 - Rollover Adjustment Is -$10.00'
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

    # 15.2 Verify Order #1 POL2 - FundA EC1 + FundB EC1, 2 Encumbrances
    * print '15.2 Verify Order #1 POL2 - FundA EC1 + FundB EC1, 2 Encumbrances, Released, $0'
    * def validatePOL2 =
      """
      function(r) {
        return r.totalRecords == 2 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.expenseClassId == expenseClassId1 &&
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId2
    And retry until validatePOL2(response)
    When method GET
    Then status 200

    # 15.2.1 Verify Order #1 POL2 - Rollover Adjustment Is -$15.00
    * print '15.2.1 Verify Order #1 POL2 - Rollover Adjustment Is -$15.00'
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

    # 15.3 Verify Order #1 POL3 - FundA EC1, Released, $0
    * print '15.3 Verify Order #1 POL3 FundA - EC1, Released, $0'
    * def validatePOL3FundA =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdA &&
               t.expenseClassId == expenseClassId1 &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId3 + ' AND fromFundId==' + fundIdA
    And retry until validatePOL3FundA(response)
    When method GET
    Then status 200

    # 15.4 Verify Order #1 POL3 - FundB EC1, Released, $0
    * print '15.4 Verify Order #1 POL3 FundB - EC1, Released, $0'
    * def validatePOL3FundB =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdB &&
               t.expenseClassId == expenseClassId1 &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId3 + ' AND fromFundId==' + fundIdB
    And retry until validatePOL3FundB(response)
    When method GET
    Then status 200

    # 15.5 Verify Order #1 POL3 - FundC No Expense Class, Released, $0
    * print '15.5 Verify Order #1 POL3 FundC - No EC, Released, $0'
    * def validatePOL3FundC =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdC &&
               !t.expenseClassId &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId3 + ' AND fromFundId==' + fundIdC
    And retry until validatePOL3FundC(response)
    When method GET
    Then status 200

    # 15.5.1 Verify Order #1 POL3 - Rollover Adjustment Is -$15.00
    * print '15.5.1 Verify Order #1 POL3 - Rollover Adjustment Is -$15.00'
    * def validatePOL3RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -15;
      }
      """
    Given path 'orders/order-lines', poLineId3
    And retry until validatePOL3RolloverAdj(response)
    When method GET
    Then status 200

    # 16. Verify Order #2 Encumbrances In FY3 - 4 Encumbrances (1+3), All Released And $0
    * print '16. Verify Order #2 Total Encumbrances In FY3 - All Released And $0'
    * def validateOrder2 =
      """
      function(r) {
        return r.totalRecords == 4 &&
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId2
    And retry until validateOrder2(response)
    When method GET
    Then status 200

    # 16.1 Verify Order #2 POL4 - FundA EC1, 1 Encumbrance
    * print '16.1 Verify Order #2 POL4 - FundA EC1, 1 Encumbrance, Released, $0'
    * def validatePOL4 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdA &&
               t.expenseClassId == expenseClassId1 &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId4
    And retry until validatePOL4(response)
    When method GET
    Then status 200

    # 16.1.1 Verify Order #2 POL4 - Rollover Adjustment Is -$20.00
    * print '16.1.1 Verify Order #2 POL4 - Rollover Adjustment Is -$20.00'
    * def validatePOL4RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -20;
      }
      """
    Given path 'orders/order-lines', poLineId4
    And retry until validatePOL4RolloverAdj(response)
    When method GET
    Then status 200

    # 16.2 Verify Order #2 POL5 - FundA EC1, FundA EC2 And FundC No EC, 3 Encumbrances
    * print '16.2 Verify Order #2 POL5 - FundA EC1 + FundA EC2 + FundC No-EC, 3 Encumbrances, Released, $0'
    * def validatePOL5 =
      """
      function(r) {
        return r.totalRecords == 3 &&
               r.transactions.every(function(t) {
                 return t.amount == 0 &&
                        t.encumbrance.status == 'Released' &&
                        t.encumbrance.initialAmountEncumbered == 0 &&
                        t.encumbrance.amountAwaitingPayment == 0 &&
                        t.encumbrance.amountExpended == 0;
               }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA && t.expenseClassId == expenseClassId1; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdA && t.expenseClassId == expenseClassId2; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdC && !t.expenseClassId; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId5
    And retry until validatePOL5(response)
    When method GET
    Then status 200

    # 16.2.1 Verify Order #2 POL5 - Rollover Adjustment Is -$24.00
    * print '16.2.1 Verify Order #2 POL5 - Rollover Adjustment Is -$24.00'
    * def validatePOL5RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -24;
      }
      """
    Given path 'orders/order-lines', poLineId5
    And retry until validatePOL5RolloverAdj(response)
    When method GET
    Then status 200

    # 17. Verify Order #3 Encumbrances In FY3 - 3 Encumbrances (1+2), All Released And $0
    * print '17. Verify Order #3 Total Encumbrances In FY3 - All Released And $0'
    * def validateOrder3 =
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
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId3
    And retry until validateOrder3(response)
    When method GET
    Then status 200

    # 17.1 Verify Order #3 POL6 - FundB EC1, 1 Encumbrance
    * print '17.1 Verify Order #3 POL6 - FundB EC1, 1 Encumbrance, Released, $0'
    * def validatePOL6 =
      """
      function(r) {
        var t = r.transactions[0];
        return r.totalRecords == 1 &&
               t.amount == 0 &&
               t.fromFundId == fundIdB &&
               t.expenseClassId == expenseClassId1 &&
               t.encumbrance.status == 'Released' &&
               t.encumbrance.initialAmountEncumbered == 0 &&
               t.encumbrance.amountAwaitingPayment == 0 &&
               t.encumbrance.amountExpended == 0;
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId6
    And retry until validatePOL6(response)
    When method GET
    Then status 200

    # 17.1.1 Verify Order #3 POL6 - Rollover Adjustment Is -$30.00
    * print '17.1.1 Verify Order #3 POL6 - Rollover Adjustment Is -$30.00'
    * def validatePOL6RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -30;
      }
      """
    Given path 'orders/order-lines', poLineId6
    And retry until validatePOL6RolloverAdj(response)
    When method GET
    Then status 200

    # 17.2 Verify Order #3 POL7 - FundB EC2 And FundC No EC, 2 Encumbrances
    * print '17.2 Verify Order #3 POL7 - FundB EC2 + FundC No-EC, 2 Encumbrances, Released, $0'
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
               r.transactions.some(function(t) { return t.fromFundId == fundIdB && t.expenseClassId == expenseClassId2; }) &&
               r.transactions.some(function(t) { return t.fromFundId == fundIdC && !t.expenseClassId; });
      }
      """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId3 + ' AND encumbrance.sourcePoLineId==' + poLineId7
    And retry until validatePOL7(response)
    When method GET
    Then status 200

    # 17.2.1 Verify Order #3 POL7 - Rollover Adjustment Is -$35.00
    * print '17.2.1 Verify Order #3 POL7 - Rollover Adjustment Is -$35.00'
    * def validatePOL7RolloverAdj =
      """
      function(r) {
        return r.cost.fyroAdjustmentAmount == -35;
      }
      """
    Given path 'orders/order-lines', poLineId7
    And retry until validatePOL7RolloverAdj(response)
    When method GET
    Then status 200

    # 18. Verify FY3 Budget Amounts For All Funds - Encumbered $0, No Expenditures, Available Equals Allocated
    * print '18. Verify FY3 Budget For FundA - Encumbered=0, No Expenditures'
    * def validateBudgetFY3 =
      """
      function(b) {
        return b.encumbered == 0 &&
               b.expenditures == 0 &&
               b.awaitingPayment == 0 &&
               b.available == 1000;
      }
      """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdA + ' AND fiscalYearId==' + fyId3
    And retry until validateBudgetFY3(response.budgets[0])
    When method GET
    Then status 200

    * print '18.1 Verify FY3 Budget For FundB - Encumbered=0, No Expenditures'
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdB + ' AND fiscalYearId==' + fyId3
    And retry until validateBudgetFY3(response.budgets[0])
    When method GET
    Then status 200

    * print '18.2 Verify FY3 Budget For FundC - Encumbered=0, No Expenditures'
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundIdC + ' AND fiscalYearId==' + fyId3
    And retry until validateBudgetFY3(response.budgets[0])
    When method GET
    Then status 200
