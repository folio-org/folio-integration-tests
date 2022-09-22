Feature: Make transfer transaction and verify budget updates

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def ledgerIdFirst = callonce uuid1
    * def ledgerIdSecond = callonce uuid2

    * def fundIdFirst = callonce uuid3
    * def fundIdSecond = callonce uuid4
    * def fundIdThird = callonce uuid5

    * def budgetIdFirst = callonce uuid6
    * def budgetIdSecond = callonce uuid7
    * def budgetIdThird = callonce uuid8

  Scenario Outline: Setup ledger
    * def ledgerId = <ledgerId>
    * call createLedger { 'id': '#(ledgerId)'}

    Examples:
      | ledgerId       |
      | ledgerIdFirst  |
      | ledgerIdSecond |

  Scenario Outline: Setup fund and budgets
    * def fundId = <fundId>
    * def ledgerId = <ledgerId>
    * def amount = <amount>
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(ledgerId)'}

    * def budgetId = <budgetId>
    * call createBudget { 'id': '#(budgetId)', 'fundId':'#(fundId)', 'allocated': '#(amount)'}
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

  Scenario: Transfer money from first budget to second with not enough money error
    Given path 'finance/transfers'
    And request
    """
    {
      "amount": "1001",
      "currency": "USD",
      "fromFundId": "#(fundIdFirst)",
      "toFundId": "#(fundIdSecond)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 400
    And match $.errors[0].code == 'notEnoughMoneyForTransferError'


  Scenario: Transfer money from first budget to second
    Given path 'finance-storage/transactions'
    And request
    """
    {
      "amount": "25",
      "currency": "USD",
      "fromFundId": "#(fundIdFirst)",
      "toFundId": "#(fundIdSecond)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201

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
      | fundIdFirst  | 1000      | 975       | 0            | 0          | -25          | 0               | 0           |
      | fundIdSecond | 500       | 525       | 0            | 0          | 25           | 0               | 0           |
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
    Given path 'finance-storage/transactions'
    And request
    """
    {
      "amount": "25",
      "currency": "USD",
      "fromFundId": "#(fundIdFirst)",
      "toFundId": "#(fundIdThird)",
      "fiscalYearId": "#(globalFiscalYearId)",
      "transactionType": "Transfer",
      "source": "User"
    }
    """
    When method POST
    Then status 201

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
      | fundIdFirst  | 1000      | 950       | 0            | 0          | -50          | 0               | 0           |
      | fundIdSecond | 500       | 525       | 0            | 0          | 25           | 0               | 0           |
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
