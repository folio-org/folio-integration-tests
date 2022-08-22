Feature: Verify calculation of the Ledger totals for the fiscal year

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_finance'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
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

    * def ledgerWithBudgets1 = callonce uuid7
    * def ledgerWithBudgets2 = callonce uuid8
    * def ledgerWithoutBudgets = callonce uuid9

    * def nonExistingFiscalYear = callonce uuid10

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
      | ledgerWithBudgets1   |
      | ledgerWithBudgets2   |
      | ledgerWithoutBudgets |

  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def ledgerId = <ledgerId>
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': #(ledgerId) }
    Given path 'finance-storage/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "initialAllocation": 0.0,
      "allocationTo": 0.0,
      "allocationFrom": 0.0,
      "encumbered": <encumbered>,
      "awaitingPayment": <awaitingPayment>,
      "expenditures": <expenditures>,
      "netTransfers": 0.0,
      "allowableEncumbrance": 150.0,
      "allowableExpenditure": 150.0
    }
    """
    When method POST
    Then status 201

    Given path 'finance-storage/transactions'
    And request
    """
    {
        "amount": <initialAllocation>,
        "currency": "USD",
        "description": "To allocation",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "toFundId": "#(fundId)",
        "transactionType": "Allocation"
    }
    """
    When method POST
    Then status 201

    #fund1 & fund3 contains same ledgerId(ledgerWithBudgets1), so allocations between fund1 & fund3 will affect allocationTo & allocationFrom Values of ledgerId.
    #For Example:- if we allocate '10' to fund3 from fund1 then allocationTo & allocationFrom Values of ledgerId (ledgerWithBudgets1) would be '10'.
    Examples:
      | fundId  | budgetId  | ledgerId           | initialAllocation | encumbered | awaitingPayment | expenditures |
      | fundId1 | budgetId1 | ledgerWithBudgets1 | 10000             | 231.34     | 763.23          | 242          |
      | fundId2 | budgetId2 | ledgerWithBudgets2 | 24500             | 25000      | 0               | 0            |
      | fundId3 | budgetId3 | ledgerWithBudgets1 | 6601.91           | 0          | 2345            | 500          |

  Scenario: Get ledger with budgets when fiscalYear parameter is empty should return zero totals
    Given path 'finance/ledgers', ledgerWithBudgets1
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

  Scenario Outline: Get <ledgerId> with budgets when fiscalYear parameter is specified should return ledger with calculated totals
    Given path 'finance/ledgers', <ledgerId>
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200
    And match response.initialAllocation == <initialAllocation>
    And match response.allocationTo == 0.0
    And match response.allocationFrom == 0.0
    #allocated = initialAllocation.add(allocationTo).subtract(allocationFrom)
    And match response.allocated == <allocated>
    And match response.encumbered == <encumbered>
    And match response.awaitingPayment == <awaitingPayment>
    And match response.expenditures == <expenditures>
    # unavailable = encumbered.add(awaitingPayment).add(expended)
    And match response.unavailable == <unavailable>
    And match response.netTransfers == 0.0
     #totalFunding = allocated.add(netTransfers)
    And match response.totalFunding == <totalFunding>
    #available = totalFunding.subtract(unavailable).max(BigDecimal.ZERO)
    And match response.available == <available>
    #cashBalance = totalFunding.subtract(expended)
    And match response.cashBalance == response.totalFunding - response.expenditures
    #overEncumbered = encumbered.subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
    And match response.overEncumbrance == <overEncumbrance>
    #overExpended = expended.add(awaitingPayment).subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
    And match response.overExpended == <overExpended>

  Examples:
      | ledgerId           | initialAllocation | allocated | encumbered | awaitingPayment | expenditures | unavailable | totalFunding | available | overEncumbrance | overExpended |
      | ledgerWithBudgets1 | 16601.91          | 16601.91  | 231.34     | 3108.23         | 742          | 4081.57     | 16601.91     | 12520.34  |0.0              | 0.0          |
      | ledgerWithBudgets2 | 24500             | 24500     | 25000      | 0.0             | 0.0          | 25000       | 24500        | 0.0       |500.0            | 0.0          |


  Scenario Outline: Create allocation from <fromFundId> to <toFundId>
    * def toFundId = <toFundId>
    * def fromFundId = <fromFundId>
    Given path 'finance/allocations'
    And request
    """
    {
        "amount": <amount>,
        "currency": "USD",
        "description": "To allocation",
        "fiscalYearId": "#(globalFiscalYearId)",
        "source": "User",
        "fromFundId" : "#(fromFundId)",
        "toFundId": "#(toFundId)",
        "transactionType": "Allocation"
    }
    """
    When method POST
    Then status 201
    Examples:
      |fromFundId| toFundId | amount|
      |fundId1   | fundId2  | 420   |
      |fundId1   | fundId2  | 534   |
      |fundId3   | fundId1  | 31    |
      |fundId3   | fundId1  | 32    |

  Scenario Outline: Transfer money from <fromFundId> to <toFundId>
    * def toFundId = <toFundId>
    * def fromFundId = <fromFundId>
    Given path 'finance/transfers'
    And request
    """
    {
      "amount": <amount>,
      "currency": "USD",
      "fromFundId": "#(fromFundId)",
      "toFundId": "#(toFundId)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201
    Examples:
      |fromFundId| toFundId | amount|
      |fundId1   | fundId2  | 15    |
      |fundId1   | fundId2  | 16    |
      |fundId2   | fundId1  | 10    |
      |fundId3   | fundId1  | 33    |
      |fundId3   | fundId1  | 34    |

  Scenario Outline: Allocate only with <fromFundId>
    * def fromFundId = <fromFundId>
    Given path 'finance/allocations'
    And request
    """
    {
      "amount": <amount>,
      "currency": "USD",
      "fromFundId": "#(fromFundId)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Allocation",
      "source": "User"
    }
    """
    When method POST
    Then status 201
    Examples:
      |fromFundId| amount|
      |fundId1   | 25    |
      |fundId2   | 20    |


  Scenario Outline: Get <ledgerId> with budgets when fiscalYear parameter is specified and allocations are made should return ledger with calculated totals
    Given path 'finance/ledgers', <ledgerId>
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200
    And match response.initialAllocation == <initialAllocation>
    And match response.allocationTo == <allocationTo>
    And match response.allocationFrom == <allocationFrom>
    #allocated = initialAllocation.add(allocationTo).subtract(allocationFrom)
    And match response.allocated == <allocated>
    And match response.encumbered == <encumbered>
    And match response.awaitingPayment == <awaitingPayment>
    And match response.expenditures == <expenditures>
    # unavailable = encumbered.add(awaitingPayment).add(expended)
    And match response.unavailable == <unavailable>
    And match response.netTransfers == <netTransfers>
     #totalFunding = allocated.add(netTransfers)
    And match response.totalFunding == <totalFunding>
    #available = totalFunding.subtract(unavailable).max(BigDecimal.ZERO)
    And match response.available == <available>
    #cashBalance = totalFunding.subtract(expended)
    And match response.cashBalance == response.totalFunding - response.expenditures
    #overEncumbered = encumbered.subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
    And match response.overEncumbrance == <overEncumbrance>
    #overExpended = expended.add(awaitingPayment).subtract(totalFunding.max(BigDecimal.ZERO)).max(BigDecimal.ZERO)
    And match response.overExpended == <overExpended>

    Examples:
      | ledgerId           | initialAllocation | allocationFrom |allocationTo | netTransfers | allocated | encumbered | awaitingPayment | expenditures | unavailable | totalFunding | available | overEncumbrance | overExpended |
      | ledgerWithBudgets1 | 16601.91          |1042.0           |63.0          | -21.0        | 15622.91  | 231.34     | 3108.23         | 742          | 4081.57     | 15601.91     | 11520.34  |0.0              | 0.0          |
      | ledgerWithBudgets2 | 24500             |20.0            |954.0        | 21.0         | 25434.0   | 25000      | 0.0             | 0.0          | 25000.0     | 25455.0      | 455       |0.0              | 0.0          |



  Scenario: Get ledger with non existing fiscalYear in parameter
    Given path 'finance/ledgers', ledgerWithBudgets1
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
     And param query = 'id==(' + ledgerWithBudgets1 + ' OR ' + ledgerWithoutBudgets + ' OR ' + ledgerWithBudgets2 +')'
     When method GET
     Then status 200
     And match response.ledgers == '#[3]'
     * match response.totalRecords == 3
     * def ledger1 = karate.jsonPath(response, '$.ledgers[*][?(@.id == "' + ledgerWithBudgets1 + '")]')[0]
     * def ledger2 = karate.jsonPath(response, '$.ledgers[*][?(@.id == "' + ledgerWithoutBudgets + '")]')[0]
     * def ledger3 = karate.jsonPath(response, '$.ledgers[*][?(@.id == "' + ledgerWithBudgets2 + '")]')[0]

     And match ledger1.initialAllocation == 16601.91
     And match ledger1.allocationTo == 63.0
     And match ledger1.allocationFrom == 1042.0
     And match ledger1.allocated == 15622.91
     And match ledger1.encumbered == 231.34
     And match ledger1.awaitingPayment == 3108.23
     And match ledger1.expenditures == 742
     And match ledger1.unavailable == 4081.57
     And match ledger1.netTransfers == -21.0
     And match ledger1.totalFunding == 15601.91
     And match ledger1.available == 11520.34
     And match ledger1.cashBalance == ledger1.totalFunding - ledger1.expenditures
     And match ledger1.overEncumbrance == 0.0
     And match ledger1.overExpended == 0.0

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

     And match ledger3.initialAllocation == 24500.0
     And match ledger3.allocationTo == 954.0
     And match ledger3.allocationFrom == 20.0
     And match ledger3.allocated == 25434.0
     And match ledger3.encumbered == 25000.0
     And match ledger3.awaitingPayment == 0
     And match ledger3.expenditures == 0
     And match ledger3.unavailable == 25000.0
     And match ledger3.netTransfers == 21.0
     And match ledger3.totalFunding == 25455.0
     And match ledger3.available == 455.0
     And match ledger3.cashBalance == ledger3.totalFunding - ledger3.expenditures
     And match ledger3.overEncumbrance == 0
     And match ledger3.overExpended == 0


  Scenario: Get ledgers with empty fiscalYear parameter
    Given path 'finance/ledgers'
    And param query = 'id==(' + ledgerWithBudgets1 + ' OR ' + ledgerWithoutBudgets + ')'
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