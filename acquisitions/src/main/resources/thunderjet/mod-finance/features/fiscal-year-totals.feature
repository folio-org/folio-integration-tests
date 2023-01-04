Feature: Fiscal year totals

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance4'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fiscalYearId = callonce uuid1
    * def ledgerId = callonce uuid2

    * def fundId1 = callonce uuid3
    * def fundId2 = callonce uuid4
    * def fundId3 = callonce uuid5

    * def budgetId1 = callonce uuid6
    * def budgetId2 = callonce uuid7
    * def budgetId3 = callonce uuid8

    * def codePrefix = callonce random_string
    * def year = callonce getCurrentYear



  Scenario: prepare fiscal year

    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": '#(fiscalYearId)',
      "name": '#(codePrefix + year)',
      "code": '#(codePrefix + year)',
      "periodStart": '#(year + "-01-01T00:00:00Z")',
      "periodEnd": '#(year + "-12-30T23:59:59Z")'
    }
    """
    When method POST
    Then status 201


  Scenario: prepare finances for ledger


    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(ledgerId)",
      "ledgerStatus": "Active",
      "name": "#(ledgerId)",
      "code": "#(ledgerId)",
      "fiscalYearOneId":"#(globalFiscalYearId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Get fiscal year without budgets when fiscalYear withFinancialSummary is true
    Given path 'finance/fiscal-years', fiscalYearId
    And param withFinancialSummary = true
    When method GET
    Then status 200
    And match response.financialSummary.initialAllocation == 0
    And match response.financialSummary.allocationTo == 0
    And match response.financialSummary.allocationFrom == 0
    And match response.financialSummary.allocated == 0
    And match response.financialSummary.encumbered == 0
    And match response.financialSummary.awaitingPayment == 0
    And match response.financialSummary.expenditures == 0
    And match response.financialSummary.unavailable == 0
    And match response.financialSummary.totalFunding == 0
    And match response.financialSummary.available == 0
    And match response.financialSummary.cashBalance == 0
    And match response.financialSummary.overEncumbrance == 0
    And match response.financialSummary.overExpended == 0


  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerId) }
    Given path 'finance-storage/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(fiscalYearId)",
      "initialAllocation": <initialAllocation>,
      "allocationTo": <allocationTo>,
      "allocationFrom": <allocationFrom>,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPayment>,
      "expenditures": <expenditures>,
      "netTransfers": <netTransfers>,
      "allowableEncumbrance": 150.0,
      "allowableExpenditure": 150.0
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId  | budgetId  | initialAllocation | allocationTo | allocationFrom | netTransfers | encumbered | awaitingPayment | expenditures |
      | fundId1 | budgetId1 | 10000             | 9000         | 1000.01        | 100.01       | 231.34     | 763.23          | 242          |
      | fundId2 | budgetId2 | 24500             | 499.98       | 10000.01       | 9999.99      | 25000      | 0               | 0            |
      | fundId3 | budgetId3 | 3001.91           | 1001.52      | 2000.39        | 0            | 0          | 2345            | 500          |

  Scenario: Get fiscal year when withFinancialSummary parameter is empty should not return financialSummary
    Given path 'finance/fiscal-years', fiscalYearId
    When method GET
    Then status 200
    And match response.financialSummary == '#notpresent'

  Scenario: Get fiscal year with budgets when fiscalYear parameter is specified should return ledger with calculated totals
    Given path 'finance/fiscal-years', fiscalYearId
    And param withFinancialSummary = true
    When method GET
    Then status 200
    And match response.financialSummary.initialAllocation == 37501.91
    And match response.financialSummary.allocationTo == 10501.5
    And match response.financialSummary.allocationFrom == 13000.41
    And match response.financialSummary.allocated == 35003
    And match response.financialSummary.encumbered == 25231.34
    And match response.financialSummary.awaitingPayment == 3108.23
    And match response.financialSummary.expenditures == 742
    And match response.financialSummary.unavailable == 29081.57
    And match response.financialSummary.totalFunding == 45103
    And match response.financialSummary.available == 16021.43
    And match response.financialSummary.cashBalance == 44361
    And match response.financialSummary.overEncumbrance == 2345.04
    And match response.financialSummary.overExpended == 841.96
