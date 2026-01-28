# For MODORDERS-1388
Feature: Rollover orders using different ledgers

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

  @Positive
  Scenario: Rollover open orders with 2 lines using different ledgers
    * def series = call random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId1 = call uuid
    * def ledgerId2 = call uuid
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def budgetId3 = call uuid
    * def budgetId4 = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid
    * def rolloverId1 = call uuid
    * def rolloverId2 = call uuid

    # 1. Create fiscal years and associated ledgers
    * print '1. Create fiscal years and associated ledgers'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: '#(series + "0001")', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: '#(series + "0002")', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: '#(series)' }
    * def v = call createLedger { id: #(ledgerId1), fiscalYearId: #(fyId1) }
    * def v = call createLedger { id: #(ledgerId2), fiscalYearId: #(fyId1) }

    # 2. Create funds and budgets
    * print '2. Create funds and budgets'
    * def v = call createFund { id: #(fundId1), code: #(fundId1), ledgerId: #(ledgerId1) }
    * def v = call createFund { id: #(fundId2), code: #(fundId2), ledgerId: #(ledgerId2) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId1), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId2), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId3), fundId: #(fundId1), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId4), fundId: #(fundId2), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }

    # 3. Create the orders and lines (one with reEncumber:false, the other with reEncumber:true)
    * print '3. Create the orders and lines (one with reEncumber:false, the other with reEncumber:true)'
    * def v = call createOrder { id: #(orderId1), orderType: 'One-Time', reEncumber: false }
    * def v = call createOrderLine { id: #(poLineId1), orderId: #(orderId1), fundId: #(fundId1) }
    * def v = call createOrderLine { id: #(poLineId2), orderId: #(orderId1), fundId: #(fundId2) }
    * def v = call createOrder { id: #(orderId2), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId3), orderId: #(orderId2), fundId: #(fundId1) }
    * def v = call createOrderLine { id: #(poLineId4), orderId: #(orderId2), fundId: #(fundId2) }

    # 4. Open the orders
    * print '4. Open the orders'
    * def v = call openOrder { orderId: #(orderId1) }
    * def v = call openOrder { orderId: #(orderId2) }

    # 5. Rollover the 2 ledgers
    * print '5. Rollover the 2 ledgers'
    * def budgetsRollover = [ { rolloverAllocation: false, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false } ]
    * def encumbrancesRollover = [ { orderType: 'One-time', basedOn: 'Remaining', increaseBy: 0 } ]
    * table rollovers
      | id          | ledgerId  | fromFiscalYearId | toFiscalYearId | budgetsRollover | encumbrancesRollover |
      | rolloverId1 | ledgerId1 | fyId1            | fyId2          | budgetsRollover | encumbrancesRollover |
      | rolloverId2 | ledgerId2 | fyId1            | fyId2          | budgetsRollover | encumbrancesRollover |
    * def v = call rollover rollovers

    # 6. Check rollover statuses
    * print '6. Check rollover statuses'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Error']

    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']

    # 7. Check rollover errors
    * print '7. Check rollover errors'
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match each $.ledgerFiscalYearRolloverErrors[*].errorMessage contains 'Part of the encumbrances belong to the ledger, which has not been rollovered'

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 8. Get encumbrance links
    * print '8. Get encumbrance links'
    Given path 'orders/order-lines'
    And param query = 'purchaseOrderId==' + orderId1
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def encumbrancesIds1 = $.poLines[*].fundDistribution[0].encumbrance

    Given path 'orders/order-lines'
    And param query = 'purchaseOrderId==' + orderId2
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def encumbrancesIds2 = $.poLines[*].fundDistribution[0].encumbrance

    # 9. Check encumbrance transactions in FY2
    * print '9. Check encumbrance transactions in FY2'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId1
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.transactions[*].id contains only encumbrancesIds1
    And match each $.transactions[*].amount == 0

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId2
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.transactions[*].id contains only encumbrancesIds2
    And match each $.transactions[*].amount == 1


  @Positive
  Scenario: Rollover open orders with 2 lines, one using different ledgers
    * def series = call random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId1 = call uuid
    * def ledgerId2 = call uuid
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def budgetId3 = call uuid
    * def budgetId4 = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid
    * def rolloverId1 = call uuid
    * def rolloverId2 = call uuid

    # 1. Create fiscal years and associated ledgers
    * print '1. Create fiscal years and associated ledgers'
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: '#(series + "0001")', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: '#(series + "0002")', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: '#(series)' }
    * def v = call createLedger { id: #(ledgerId1), fiscalYearId: #(fyId1) }
    * def v = call createLedger { id: #(ledgerId2), fiscalYearId: #(fyId1) }

    # 2. Create funds and budgets
    * print '2. Create funds and budgets'
    * def v = call createFund { id: #(fundId1), code: #(fundId1), ledgerId: #(ledgerId1) }
    * def v = call createFund { id: #(fundId2), code: #(fundId2), ledgerId: #(ledgerId2) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId1), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId2), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId3), fundId: #(fundId1), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId4), fundId: #(fundId2), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }

    # 3. Create the orders and lines (one with reEncumber:false, the other with reEncumber:true)
    * print '3. Create the orders and lines (one with reEncumber:false, the other with reEncumber:true)'
    * def v = call createOrder { id: #(orderId1), orderType: 'One-Time', reEncumber: false }
    * def v = call createOrderLine { id: #(poLineId1), orderId: #(orderId1), fundId: #(fundId1) }
    * table fundDistributionTable1
      | fundId  | code    | distributionType | value |
      | fundId1 | 'fund1' | 'percentage'     | 50    |
      | fundId2 | 'fund2' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: #(poLineId2), orderId: #(orderId1), fundDistribution: #(fundDistributionTable1) }

    * def v = call createOrder { id: #(orderId2), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId3), orderId: #(orderId2), fundId: #(fundId1) }
    * table fundDistributionTable2
      | fundId  | code    | distributionType | value |
      | fundId1 | 'fund1' | 'percentage'     | 50    |
      | fundId2 | 'fund2' | 'percentage'     | 50    |
    * def v = call createOrderLine { id: #(poLineId4), orderId: #(orderId2), fundDistribution: #(fundDistributionTable2) }

    # 4. Open the orders
    * print '4. Open the orders'
    * def v = call openOrder { orderId: #(orderId1) }
    * def v = call openOrder { orderId: #(orderId2) }

    # 5. Rollover the 2 ledgers
    * print '5. Rollover the 2 ledgers'
    * def budgetsRollover = [ { rolloverAllocation: false, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false } ]
    * def encumbrancesRollover = [ { orderType: 'One-time', basedOn: 'Remaining', increaseBy: 0 } ]
    * table rollovers
      | id          | ledgerId  | fromFiscalYearId | toFiscalYearId | budgetsRollover | encumbrancesRollover |
      | rolloverId1 | ledgerId1 | fyId1            | fyId2          | budgetsRollover | encumbrancesRollover |
      | rolloverId2 | ledgerId2 | fyId1            | fyId2          | budgetsRollover | encumbrancesRollover |
    * def v = call rollover rollovers

    # 6. Check rollover statuses
    * print '6. Check rollover statuses'
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Error']

    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']

    # 7. Check rollover errors
    * print '7. Check rollover errors'
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match $.totalRecords == 4
    And match each $.ledgerFiscalYearRolloverErrors[*].errorMessage contains 'Part of the encumbrances belong to the ledger, which has not been rollovered'

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 8. Get encumbrance links
    * print '8. Get encumbrance links'
    Given path 'orders/order-lines'
    And param query = 'purchaseOrderId==' + orderId1
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def encumbrancesIds1 = $.poLines[*].fundDistribution[*].encumbrance

    Given path 'orders/order-lines'
    And param query = 'purchaseOrderId==' + orderId2
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def encumbrancesIds2 = $.poLines[*].fundDistribution[*].encumbrance

    # 9. Check encumbrance transactions in FY2
    * print '9. Check encumbrance transactions in FY2'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId1
    When method GET
    Then status 200
    And match $.totalRecords == 3
    And match $.transactions[*].id contains only encumbrancesIds1
    And match each $.transactions[*].amount == 0

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId2
    When method GET
    Then status 200
    And match $.totalRecords == 3
    And match $.transactions[*].id contains only encumbrancesIds2
    And match $.transactions[*].amount contains only [0.5,0.5,1.0]
