Feature: Should tests budget total amounts calculation

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testfinance1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * def headersUser = headersAdmin

    * configure headers = headersAdmin
    * callonce variables

    * def fiscalYearId = callonce uuid1
    * def ledgerId = callonce uuid2

    * def fundId1 = callonce uuid3
    * def fundId2 = callonce uuid4
    * def fundId3 = callonce uuid5
    * def fundId4 = callonce uuid6
    * def fundId5 = callonce uuid7
    * def fundId6 = callonce uuid8
    * def fundId7 = callonce uuid9
    * def fundId8 = callonce uuid10
    * def fundId9 = callonce uuid11

    * def budgetId1 = callonce uuid12
    * def budgetId2 = callonce uuid13
    * def budgetId3 = callonce uuid14
    * def budgetId4 = callonce uuid15
    * def budgetId5 = callonce uuid16
    * def budgetId6 = callonce uuid17
    * def budgetId7 = callonce uuid18
    * def budgetId8 = callonce uuid19
    * def budgetId9 = callonce uuid20

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


  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerId) }
    Given path 'finance-storage/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId":"#(fiscalYearId)",
      "initialAllocation": <initialAllocation>,
      "allocationTo": <allocationTo>,
      "allocationFrom": <allocationFrom>,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPayment>,
      "expenditures": <expenditures>,
      "netTransfers": <netTransfers>,
      "allowableEncumbrance": 110.0,
      "allowableExpenditure": 110.0
    }
    """
    When method POST
    Then status 201

  Examples:
    | fundId  | budgetId  | initialAllocation | allocationTo | allocationFrom | netTransfers |expenditures | awaitingPayment | encumbered |
    | fundId1 | budgetId1 | 1500              | 300          | 0              | 200          | 1500        | 500             | 200        |
    | fundId2 | budgetId2 | 1500              | 400          | 100            | 200          | 1500        | 400             | 100        |
    | fundId3 | budgetId3 | 1500              | 350          | 50             | 200          | 1500        | 600             | 200        |
    | fundId4 | budgetId4 | 1500              | 300          | 0              | 200          | 1000        | 100             | 200        |
    | fundId5 | budgetId5 | 1500              | 300          | 0              | 200          | 1000        | 1000            | 200        |
    | fundId6 | budgetId6 | 1500              | 0            | 0              | 0            | 1000        | 1000            | 0          |
    | fundId7 | budgetId7 | 1000              | 0            | 0              | 0            | 200         | 300             | 1000       |
    | fundId8 | budgetId8 | 1000              | 0            | 500            | 0            | 0           | -100            | 1000       |
    | fundId9 | budgetId9 | 500               | 0            | 1000           | 0            | 100         | 0               | 500        |


  Scenario Outline: Verify budget <budgetId> amount totals
    Given path 'finance/budgets', <budgetId>
    * configure headers = headersUser
    When method GET
    Then status 200
    And match response.unavailable == <expUnavailable>
    And match response.totalFunding == <expTotalFunding>
    And match response.available == <expAvailable>
    And match response.cashBalance == <expCashBalance>
    And match response.overEncumbrance == <expOverEncumbrance>
    And match response.overExpended == <expOverExpended>
  Examples:
    | budgetId  | expTotalFunding | expOverExpended | expOverEncumbrance | expCashBalance | expAvailable| expUnavailable |
    | budgetId1 | 2000            | 0               | 200                | 500            | -200        | 2200           |
    | budgetId2 | 2000            | 0               | 0                  | 500            | 0           | 2000           |
    | budgetId3 | 2000            | 100             | 200                | 500            | -300        | 2300           |
    | budgetId4 | 2000            | 0               | 0                  | 1000           | 700         | 1300           |
    | budgetId5 | 2000            | 0               | 200                | 1000           | -200        | 2200           |
    | budgetId6 | 1500            | 500             | 0                  | 500            | -500        | 2000           |
    | budgetId7 | 1000            | 0               | 500                | 800            | -500        | 1500           |
    | budgetId8 | 500             | 0               | 400                | 500            | -400        | 900            |
    | budgetId9 | -500            | 100             | 500                | -600           | -1100       | 600            |

