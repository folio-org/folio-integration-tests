Feature: Make transfer transaction and verify budget updates

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance'}
    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * call variables

    * def ledgerIdFirst = call uuid1
    * def ledgerIdSecond = call uuid2

    * def fundIdFirst = call uuid3
    * def fundIdSecond = call uuid4
    * def fundIdThird = call uuid5

    * def budgetIdFirst = call uuid6
    * def budgetIdSecond = call uuid7
    * def budgetIdThird = call uuid8

  Scenario Outline: Setup ledger
    * def ledgerId = <ledgerId>
    * call createLedger { 'id': '#(ledgerId)', restrictExpenditures: false, restrictEncumbrance: false }

    Examples:
      | ledgerId       |
      | ledgerIdFirst  |
      | ledgerIdSecond |

  Scenario Outline: Setup fund and budgets
    * def fundId = <fundId>
    * def ledgerId = <ledgerId>
    * def amount = <amount>
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(ledgerId)'}

    * def budgetId = <budgetId>
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId':'#(fundId)', 'allocated': '#(amount)'}
    Examples:
      | fundId       | budgetId       | ledgerId       | amount |
      | fundIdFirst  | budgetIdFirst  | ledgerIdFirst  | 1000   |
      | fundIdSecond | budgetIdSecond | ledgerIdFirst  | 500    |
      | fundIdThird  | budgetIdThird  | ledgerIdSecond | 200    |

  Scenario Outline: check budget after create
    * def fundId = <fundId>
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.allocated == <allocated>
    And match budget.available == <available>
    And match budget.expenditures == <expenditures>
    And match budget.encumbered == <encumbered>
    And match budget.awaitingPayment == <awaitingPayment>
    And match budget.unavailable == <unavailable>

    Examples:
      | fundId       | allocated | available | expenditures | encumbered | awaitingPayment | unavailable |
      | fundIdFirst  | 1000      | 1000      | 0            | 0          | 0               | 0           |
      | fundIdSecond | 500       | 500       | 0            | 0          | 0               | 0           |
      | fundIdThird  | 200       | 200       | 0            | 0          | 0               | 0           |

  Scenario Outline: check ledger summary after create
    * def ledgerId = <ledgerId>
    Given path 'finance/ledgers', ledgerId
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.netTransfers == <netTransfers>
    And match response.unavailable == <unavailable>

    Examples:
      | ledgerId       | allocated | available | netTransfers | unavailable |
      | ledgerIdFirst  | 1500      | 1500      | 0            | 0           |
      | ledgerIdSecond | 200       | 200       | 0            | 0           |

  Scenario: Verfiy transfering money from first budget to other budget
    * print '## Transfer money from first budget to second with negative number which is allowed'
    * def transferId = call uuid
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(transferId)",
        "amount": "1001",
        "currency": "USD",
        "fromFundId": "#(fundIdFirst)",
        "toFundId": "#(fundIdSecond)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "transactionType": "Transfer",
        "source": "User"
      }]
    }
    """
    When method POST
    Then status 204

    * print '## Transfer money from first budget to second budget'
    * def transferId = call uuid
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(transferId)",
        "amount": "25",
        "currency": "USD",
        "fromFundId": "#(fundIdFirst)",
        "toFundId": "#(fundIdSecond)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "transactionType": "Transfer",
        "source": "User"
      }]
    }
    """
    When method POST
    Then status 204

  Scenario Outline: check budget after first transaction
    * def fundId = <fundId>
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.allocated == <allocated>
    And match budget.available == <available>
    And match budget.expenditures == <expenditures>
    And match budget.encumbered == <encumbered>
    And match budget.netTransfers == <netTransfers>
    And match budget.awaitingPayment == <awaitingPayment>
    And match budget.unavailable == <unavailable>

    Examples:
      | fundId       | allocated | available | expenditures | encumbered | netTransfers | awaitingPayment | unavailable |
      | fundIdFirst  | 1000      | -26       | 0            | 0          | -1026        | 0               | 0           |
      | fundIdSecond | 500       | 1526      | 0            | 0          | 1026         | 0               | 0           |
      | fundIdThird  | 200       | 200       | 0            | 0          | 0            | 0               | 0           |

  Scenario Outline: check ledger summary after first transaction
    * def ledgerId = <ledgerId>
    Given path 'finance/ledgers', ledgerId
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.netTransfers == <netTransfers>
    And match response.unavailable == <unavailable>

    Examples:
      | ledgerId       | allocated | available | netTransfers | unavailable |
      | ledgerIdFirst  | 1500      | 1500      | 0            | 0           |
      | ledgerIdSecond | 200       | 200       | 0            | 0           |

  Scenario: Transfer money from first budget to third
    * def transferId = call uuid
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(transferId)",
        "amount": "25",
        "currency": "USD",
        "fromFundId": "#(fundIdFirst)",
        "toFundId": "#(fundIdThird)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "transactionType": "Transfer",
        "source": "User"
      }]
    }
    """
    When method POST
    Then status 204

  Scenario Outline: check budget after second transaction
    * def fundId = <fundId>
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.allocated == <allocated>
    And match budget.available == <available>
    And match budget.expenditures == <expenditures>
    And match budget.encumbered == <encumbered>
    And match budget.netTransfers == <netTransfers>
    And match budget.awaitingPayment == <awaitingPayment>
    And match budget.unavailable == <unavailable>

    Examples:
      | fundId       | allocated | available | expenditures | encumbered | netTransfers | awaitingPayment | unavailable |
      | fundIdFirst  | 1000      | -51       | 0            | 0          | -1051        | 0               | 0           |
      | fundIdSecond | 500       | 1526      | 0            | 0          | 1026         | 0               | 0           |
      | fundIdThird  | 200       | 225       | 0            | 0          | 25           | 0               | 0           |


  Scenario Outline: check ledger summary after second transaction
    * def ledgerId = <ledgerId>
    Given path 'finance/ledgers', ledgerId
    And param fiscalYear = globalFiscalYearId
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.netTransfers == <netTransfers>
    And match response.unavailable == <unavailable>

    Examples:
      | ledgerId       | allocated | available | netTransfers | unavailable |
      | ledgerIdFirst  | 1500      | 1475      | -25          | 0           |
      | ledgerIdSecond | 200       | 225       | 25           | 0           |
