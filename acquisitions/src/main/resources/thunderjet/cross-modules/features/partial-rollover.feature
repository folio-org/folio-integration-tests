# For https://issues.folio.org/browse/MODFISTO-298
@parallel=false
Feature: Partial rollover

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }
    * configure headers = headersUser

    * callonce variables
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = callonce uuid1
    * def fyId2 = callonce uuid2
    * def ledgerId = callonce uuid3
    * def fundId = callonce uuid4
    * def budgetId1 = callonce uuid5
    * def budgetId2 = callonce uuid6
    * def orderId1 = callonce uuid7
    * def orderId2 = callonce uuid8
    * def poLineId1 = callonce uuid9
    * def poLineId2 = callonce uuid10
    * def rolloverId = callonce uuid11

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')


  Scenario: Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: 'TESTFY0001', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: 'TESTFY' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: 'TESTFY0002', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: 'TESTFY' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fyId1) }


  Scenario: Create fund and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId), code: #(fundId), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }


  Scenario: Create orders and lines
    * def v = call createOrder { id: #(orderId1), orderType: 'One-Time', reEncumber: true }
    * def ongoing = { interval: 123, isSubscription: true, renewalDate: '2022-05-08T00:00:00.000+00:00' }
    * def v = call createOrder { id: #(orderId2), orderType: 'Ongoing', ongoing: #(ongoing), reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId1), orderId: #(orderId1), fundId: #(fundId) }
    * def v = call createOrderLine { id: #(poLineId2), orderId: #(orderId2), fundId: #(fundId) }


  Scenario: Open orders
    * def v = call openOrder { orderId: #(orderId1) }
    * def v = call openOrder { orderId: #(orderId2) }


  Scenario: Start rollover
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
        ]
      }
    """
    When method POST
    Then status 201
    * call pause 1000


  Scenario: Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


  Scenario: Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  Scenario: Check the new budget
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.encumbered == 0
    And match $.available == 1000
    And match $.unavailable == 0


  Scenario: Check encumbrances
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.transactions[0].amount == 0
    And match $.transactions[0].encumbrance.initialAmountEncumbered == 0
    And match $.transactions[1].amount == 0
    And match $.transactions[1].encumbrance.initialAmountEncumbered == 0
