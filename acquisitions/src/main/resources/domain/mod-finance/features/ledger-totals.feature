Feature: Ledger totals

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

    * def ledgerWithBudgets = callonce uuid7
    * def ledgerWithoutBudgets = callonce uuid8

    * def nonExistingFiscalYear = callonce uuid9


  Scenario Outline: prepare finances for ledger with <ledgerId>
    * def ledgerId = <ledgerId>

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

    Examples:
      | ledgerId             |
      | ledgerWithBudgets    |
      | ledgerWithoutBudgets |

  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerWithBudgets) }
    Given path 'finance-storage/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
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

    Examples:
      | fundId  | budgetId  | initialAllocation | allocationTo | allocationFrom | netTransfers | encumbered | awaitingPayment | expenditures |
      | fundId1 | budgetId1 | 10000             | 9000         | 1000.01        | 100.01       | 231.34     | 763.23          | 242          |
      | fundId2 | budgetId2 | 24500             | 499.98       | 10000.01       | 9999.99      | 25000      | 0               | 0            |
      | fundId3 | budgetId3 | 3001.91           | 1001.52      | 2000.39        | 0            | 0          | 2345            | 500          |

  Scenario: Get ledger with budgets when fiscalYear parameter is empty should return zero totals
    Given path 'finance/ledgers', ledgerWithBudgets
    When method GET
    Then status 200
    And match response.initialAllocation == '#notpresent'
    And match response.allocationTo == '#notpresent'
    And match response.allocationFrom == '#notpresent'
    And match response.allocated == '#notpresent'
    And match response.encumbered == '#notpresent'
    And match response.awaitingPayment == '#notpresent'
    And match response.expenditures == '#notpresent'
    And match response.unavailable == '#notpresent'
    And match response.netTransfers == '#notpresent'
    And match response.totalFunding == '#notpresent'
    And match response.available == '#notpresent'
    And match response.cashBalance == '#notpresent'
    And match response.overEncumbrance == '#notpresent'
    And match response.overExpended == '#notpresent'

  Scenario: Get ledger with budgets when fiscalYear parameter is specified should return ledger with calculated totals
    Given path 'finance/ledgers', ledgerWithBudgets
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200
    And match response.initialAllocation == 37501.91
    And match response.allocationTo == 10501.5
    And match response.allocationFrom == 13000.41
    And match response.allocated == 35003
    And match response.encumbered == 25231.34
    And match response.awaitingPayment == 3108.23
    And match response.expenditures == 742
    And match response.unavailable == 29081.57
    And match response.netTransfers == 10100
    And match response.totalFunding == 45103
    And match response.available == 16863.43
    And match response.cashBalance == 44361
    And match response.overEncumbrance == 0.04
    And match response.overExpended == 841.96



  Scenario: Get ledger with non existing fiscalYear in parameter
    Given path 'finance/ledgers', ledgerWithBudgets
    And param fiscalYear = nonExistingFiscalYear
    When method GET
    Then status 400
    And response.errors[0].code == "fiscalYearNotFound"

  Scenario: Get ledger without budgets when fiscalYear parameter is specified
    Given path 'finance/ledgers', ledgerWithoutBudgets
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200
    And match response.initialAllocation == 0
    And match response.allocationTo == 0
    And match response.allocationFrom == 0
    And match response.allocated == 0
    And match response.encumbered == 0
    And match response.awaitingPayment == 0
    And match response.expenditures == 0
    And match response.unavailable == 0
    And match response.netTransfers == 0
    And match response.totalFunding == 0
    And match response.available == 0
    And match response.cashBalance == 0
    And match response.overEncumbrance == 0
    And match response.overExpended == 0

   Scenario: Get ledgers with specified fiscalYear parameter
     Given path 'finance/ledgers'
     And param fiscalYear = globalFiscalYearId
     And param query = 'id==(' + ledgerWithBudgets + ' OR ' + ledgerWithoutBudgets + ')'
     When method GET
     Then status 200
     And match response.ledgers == '#[2]'
     * match response.totalRecords == 2
     * def ledger1 = karate.jsonPath(response, '$.ledgers[*][?(@.id == "' + ledgerWithBudgets + '")]')[0]
     * def ledger2 = karate.jsonPath(response, '$.ledgers[*][?(@.id == "' + ledgerWithoutBudgets + '")]')[0]
     And match ledger1.initialAllocation == 37501.91
     And match ledger1.allocationTo == 10501.5
     And match ledger1.allocationFrom == 13000.41
     And match ledger1.allocated == 35003
     And match ledger1.encumbered == 25231.34
     And match ledger1.awaitingPayment == 3108.23
     And match ledger1.expenditures == 742
     And match ledger1.unavailable == 29081.57
     And match ledger1.netTransfers == 10100
     And match ledger1.totalFunding == 45103
     And match ledger1.available == 16863.43
     And match ledger1.cashBalance == 44361
     And match ledger1.overEncumbrance == 0.04
     And match ledger1.overExpended == 841.96
     And match ledger2.allocated == 0
     And match ledger2.initialAllocation == 0
     And match ledger2.allocationTo == 0
     And match ledger2.allocationFrom == 0
     And match ledger2.allocated == 0
     And match ledger2.encumbered == 0
     And match ledger2.awaitingPayment == 0
     And match ledger2.expenditures == 0
     And match ledger2.unavailable == 0
     And match ledger2.netTransfers == 0
     And match ledger2.totalFunding == 0
     And match ledger2.available == 0
     And match ledger2.cashBalance == 0
     And match ledger2.overEncumbrance == 0
     And match ledger2.overExpended == 0

  Scenario: Get ledgers with empty fiscalYear parameter
    Given path 'finance/ledgers'
    And param query = 'id==(' + ledgerWithBudgets + ' OR ' + ledgerWithoutBudgets + ')'
    When method GET
    Then status 200
    And match response.ledgers == '#[2]'
    * match response.totalRecords == 2
    * match each response.ledgers contains
    """
    {
      allocated: '#notpresent',
      available: '#notpresent',
      unavailable: '#notpresent',
      netTransfers: '#notpresent',
      initialAllocation:  '#notpresent',
      allocationTo:  '#notpresent',
      allocationFrom:  '#notpresent',
      allocated:  '#notpresent',
      encumbered:  '#notpresent',
      awaitingPayment:  '#notpresent',
      expenditures:  '#notpresent',
      unavailable:  '#notpresent',
      netTransfers:  '#notpresent',
      totalFunding:  '#notpresent',
      available:  '#notpresent',
      cashBalance:  '#notpresent',
      overEncumbrance:  '#notpresent',
      overExpended:  '#notpresent'
    }
    """