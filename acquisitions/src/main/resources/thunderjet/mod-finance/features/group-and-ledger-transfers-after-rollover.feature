# For https://issues.folio.org/browse/MODFIN-299
@parallel=false
Feature: Group and ledger transfers after rollover

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * configure headers = headersUser

    * callonce variables
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = callonce uuid1
    * def fyId2 = callonce uuid2
    * def ledgerId1 = callonce uuid3
    * def ledgerId2 = callonce uuid4
    * def fundId1 = callonce uuid5
    * def fundId2 = callonce uuid6
    * def fundId3 = callonce uuid7
    * def f1Y1BudgetId = callonce uuid8
    * def f1Y2BudgetId = callonce uuid9
    * def f2Y1BudgetId = callonce uuid10
    * def f2Y2BudgetId = callonce uuid11
    * def f3Y1BudgetId = callonce uuid12
    * def f3Y2BudgetId = callonce uuid13
    * def groupId = callonce uuid14
    * def rolloverId = callonce uuid15

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')


  Scenario: Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: 'TESTFY0011', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: 'TESTFY' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: 'TESTFY0012', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: 'TESTFY' }
    * def v = call createLedger { id: #(ledgerId1), fiscalYearId: #(fyId1) }
    * def v = call createLedger { id: #(ledgerId2), fiscalYearId: #(fyId1) }


  Scenario: Create funds and budgets
    * def v = call createFund { id: #(fundId1), code: #(fundId1), ledgerId: #(ledgerId1) }
    * def v = call createFund { id: #(fundId2), code: #(fundId2), ledgerId: #(ledgerId1) }
    * def v = call createFund { id: #(fundId3), code: #(fundId3), ledgerId: #(ledgerId2) }
    * def v = call createBudget { id: #(f1Y1BudgetId), fundId: #(fundId1), fiscalYearId: #(fyId1), allocated: 100, status: 'Active' }
    * def v = call createBudget { id: #(f1Y2BudgetId), fundId: #(fundId1), fiscalYearId: #(fyId2), allocated: 100, status: 'Active' }
    * def v = call createBudget { id: #(f2Y1BudgetId), fundId: #(fundId2), fiscalYearId: #(fyId1), allocated: 100, status: 'Active' }
    * def v = call createBudget { id: #(f2Y2BudgetId), fundId: #(fundId2), fiscalYearId: #(fyId2), allocated: 100, status: 'Active' }
    * def v = call createBudget { id: #(f3Y1BudgetId), fundId: #(fundId3), fiscalYearId: #(fyId1), allocated: 100, status: 'Active' }
    * def v = call createBudget { id: #(f3Y2BudgetId), fundId: #(fundId3), fiscalYearId: #(fyId2), allocated: 100, status: 'Active' }


  Scenario: Create a group
    Given path 'finance/groups'
    And request
    """
    {
      "id": "#(groupId)",
      "status": "Active",
      "name": "#(groupId)",
      "code": "#(groupId)"
    }
    """
    When method POST
    Then status 201


  Scenario Outline: Associate fund 1 to group in both fiscal years
    * def budgetId = <budgetId>
    * def groupId = <groupId>
    * def fiscalYearId = <fiscalYearId>
    * def fundId = <fundId>

    Given path 'finance/group-fund-fiscal-years'
    And request
    """
    {
      "budgetId": "#(budgetId)",
      "groupId": '#(groupId)',
      "fiscalYearId": "#(fiscalYearId)",
      "fundId": "#(fundId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | budgetId     | groupId  | fiscalYearId | fundId  |
      | f1Y1BudgetId | groupId  | fyId1        | fundId1 |
      | f1Y2BudgetId | groupId  | fyId2        | fundId1 |


  Scenario: Transfer from fund 1 (ledger 1) to fund 2 (ledger 1) in FY 1
    Given path 'finance/transfers'
    And request
    """
    {
      "amount": 10,
      "currency": "USD",
      "fromFundId": "#(fundId1)",
      "toFundId": "#(fundId2)",
      "fiscalYearId": "#(fyId1)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201


  Scenario: Transfer from fund 3 (ledger 2) to fund 1 (ledger 1) in FY 1
    Given path 'finance/transfers'
    And request
    """
    {
      "amount": 5,
      "currency": "USD",
      "fromFundId": "#(fundId3)",
      "toFundId": "#(fundId1)",
      "fiscalYearId": "#(fyId1)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201


  Scenario: Check group summary net transfers after transfer
    Given path 'finance/group-fiscal-year-summaries'
    And param query = 'fiscalYearId==' + fyId1
    When method GET
    Then status 200
    And match $.groupFiscalYearSummaries[0].netTransfers ==  -5.0


  Scenario: Check ledger 1 net transfers after transfer
    Given path 'finance/ledgers', ledgerId1
    And param fiscalYear = fyId1
    When method GET
    Then status 200
    And match $.netTransfers ==  5


  Scenario: Start rollover with rolloverAvailable
    Given path 'finance/ledger-rollovers',
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId1)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "rolloverBudgetValue": "Available",
            "setAllowances": false,
            "adjustAllocation": 0,
            "addAvailableTo": "Available",
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": []
      }
    """
    When method POST
    Then status 201


  Scenario: Wait for rollover to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


  Scenario: Check rollover status
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


  Scenario: Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  Scenario: Check group summary net transfer after rollover
    Given path 'finance/group-fiscal-year-summaries'
    And param query = 'fiscalYearId==' + fyId2
    When method GET
    Then status 200
    And match $.groupFiscalYearSummaries[0].netTransfers == 95.0


  Scenario: Check ledger 1 net transfer after rollover
    Given path 'finance/ledgers', ledgerId1
    And param fiscalYear = fyId2
    When method GET
    Then status 200
    And match $.netTransfers == 205.0
