# For MODFISTO-559
Feature: Rollover one order type

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

  @Positive
  Scenario: Rollover one order type
    * def codePrefix = callonce random_string
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
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def rolloverId = call uuid

    # 1. Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(codePrefix + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(codePrefix)' }

    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(codePrefix + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(codePrefix)' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }

    # 2. Create fund and budgets
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }

    # 3. Create order and order line
    * def ongoingObj = { "interval": 123, "isSubscription": false, "renewalDate": "2022-05-08T00:00:00.000+00:00" }
    * table orders
      | id       | orderId  | orderType  | reEncumber | ongoing    |
      | orderId1 | orderId1 | 'One-Time' | true       | null       |
      | orderId2 | orderId2 | 'Ongoing'  | true       | ongoingObj |
    * def v = call createOrder orders

    * table orderLines
      | id        | orderId  | listUnitPrice |
      | poLineId1 | orderId1 | 10.0          |
      | poLineId2 | orderId2 | 10.0          |
    * def v = call createOrderLine orderLines

    # 4. Open orders
    * def v = call openOrder orders

    # 5. Rollover ledger, rollover only encumbrances for ongoing orders
    * def budgetsRollover = [ { rolloverAllocation: false, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false } ]
    * def encumbrancesRollover = [ { orderType: 'Ongoing', basedOn: 'Remaining', increaseBy: 0 } ]
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 6. Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match each response.ledgerFiscalYearRolloverProgresses[*].budgetsClosingRolloverStatus == 'Success'
    And match each response.ledgerFiscalYearRolloverProgresses[*].ordersRolloverStatus == 'Success'
    And match each response.ledgerFiscalYearRolloverProgresses[*].financialRolloverStatus == 'Success'
    And match each response.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == 'Success'

    # 7. Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # 8. Check encumbrance transactions in the new fiscal year
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].encumbrance.status == 'Released'
    And match $.transactions[0].amount == 0.0
    * def encumbranceId1 = $.transactions[0].id

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2 + ' AND encumbrance.sourcePoLineId==' + poLineId2
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].encumbrance.status == 'Unreleased'
    And match $.transactions[0].amount == 10.0
    * def encumbranceId2 = $.transactions[0].id

    # 9. Check encumbrance links after rollover (POLs point to the new encumbrances)
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    And match $.fundDistribution[0].encumbrance == encumbranceId1

    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    And match $.fundDistribution[0].encumbrance == encumbranceId2
