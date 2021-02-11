Feature: Group fiscal year totals

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_finance4'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def fundId3 = callonce uuid3

    * def budgetId1 = callonce uuid4
    * def budgetId2 = callonce uuid5
    * def budgetId3 = callonce uuid6

    * def groupWithBudgets = callonce uuid7
    * def groupWithoutBudgets = callonce uuid8

    * def nonExistingFiscalYear = callonce uuid9


  Scenario Outline: prepare finances for group with <groupId>
    * def groupId = <groupId>

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

    Examples:
      | groupId             |
      | groupWithBudgets    |
      | groupWithoutBudgets |

  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': #(globalLedgerId) }
    Given path 'finance-storage/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId":"#(globalFiscalYearId)",
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

    Given path 'finance-storage/group-fund-fiscal-years'
    And request
    """
    {
      "budgetId": "#(budgetId)",
      "groupId": "#(groupWithBudgets)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "fundId": "#(fundId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId  | budgetId  | initialAllocation | allocationTo | allocationFrom | netTransfers | encumbered | awaitingPayment | expenditures |
      | fundId1 | budgetId1 | 10000             | 9000         | 1000.01        | 100.01       | 231.34     | 763.23          | 242          |
      | fundId2 | budgetId2 | 24500             | 499.98       | 10000.01       | 9999.99      | 25000      | 0               | 0            |
      | fundId3 | budgetId3 | 3001.91           | 1001.52      | 2000.39        | 0            | 0          | 2345            | 500          |


   Scenario: Get groups by fiscalYearId
     Given path 'finance/group-fiscal-year-summaries'
     And param query = 'fiscalYearId==' + globalFiscalYearId
     When method GET
     Then status 200
     And match response.groupFiscalYearSummaries == '#[1]'
     * match response.totalRecords == 1
     * def groupFySummary1 = karate.jsonPath(response, '$.groupFiscalYearSummaries[*][?(@.groupId == "' + groupWithBudgets + '")]')[0]
     And match groupFySummary1.initialAllocation == 37501.91
     And match groupFySummary1.allocationTo == 10501.5
     And match groupFySummary1.allocationFrom == 13000.41
     And match groupFySummary1.allocated == 35003
     And match groupFySummary1.encumbered == 25231.34
     And match groupFySummary1.awaitingPayment == 3108.23
     And match groupFySummary1.expenditures == 742
     And match groupFySummary1.unavailable == 29081.57
     And match groupFySummary1.netTransfers == 10100
     And match groupFySummary1.totalFunding == 45103
     And match groupFySummary1.available == 16863.43
     And match groupFySummary1.cashBalance == 44361
     And match groupFySummary1.overEncumbrance == 0.04
     And match groupFySummary1.overExpended == 841.96
