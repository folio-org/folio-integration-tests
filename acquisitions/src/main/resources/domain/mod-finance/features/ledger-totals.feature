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

    * def ledgerWithBudgets = '488a15cc-ddf8-435b-88cd-01548d77e9cb'
    * def ledgerWithoutBudgets = '0c828b2b-062a-4d77-bf6a-73387259c7d6'

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

  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>, <allocated>, <available>, <unavailable>, <netTransfers>
    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def allocated = <allocated>
    * def available = <available>
    * def unavailable = <unavailable>
    * def netTransfers = <netTransfers>
    
    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerWithBudgets) }
    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "allocated": #(allocated),
      "available": #(available),
      "unavailable": #(unavailable),
      "encumbered": #(unavailable),
      "netTransfers": #(netTransfers),
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": 100.0
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId  | budgetId  | allocated | available | unavailable | netTransfers |
      | fundId1 | budgetId1 | 10000     | 9000      | 1000.01     | 0.01         |
      | fundId2 | budgetId2 | 24500     | 24499.98  | 10000.01    | 9999.99      |
      | fundId3 | budgetId3 | 3001.91   | 1001.52   | 2000.39     | 0            |

  Scenario: Get ledger with budgets when fiscalYear parameter is empty should return zero totals
    Given path 'finance/ledgers', ledgerWithBudgets
    When method GET
    Then status 200
    And match response.allocated == '#notpresent'
    And match response.available == '#notpresent'
    And match response.unavailable == '#notpresent'
    And match response.netTransfers == 0

  Scenario: Get ledger with budgets when fiscalYear parameter is specified should return ledger with calculated totals
    Given path 'finance/ledgers', ledgerWithBudgets
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200
    And match response.allocated == 37501.91
    And match response.available == 34501.5
    And match response.unavailable == 13000.41
    And match response.netTransfers == 10000

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
    And match response.allocated == 0
    And match response.available == 0
    And match response.unavailable == 0
    And match response.netTransfers == 0

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
     And match ledger1.allocated == 37501.91
     And match ledger1.available == 34501.5
     And match ledger1.unavailable == 13000.41
     * match ledger1.netTransfers == 10000
     And match ledger2.allocated == 0
     * match ledger2.available == 0
     * match ledger2.unavailable == 0
     * match ledger2.netTransfers == 0

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
      netTransfers: 0
    }
    """