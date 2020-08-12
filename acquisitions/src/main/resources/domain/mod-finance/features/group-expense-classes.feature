Feature: Group expense classes

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_finance5'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser
    * callonce variables

    * def fundIdWithoutExpenseClasses = callonce uuid1
    * def fundIdWithExpenseClassesWithoutTransactions = callonce uuid2
    * def fundIdWithExpenseClassesWithTransactions = callonce uuid3

    * def budgetIdWithoutExpenseClasses = callonce uuid4
    * def budgetIdWithExpenseClassesWithoutTransactions = callonce uuid5
    * def budgetIdWithExpenseClassesWithTransactions = callonce uuid6

    * def orderId = callonce uuid7
    * def invoiceId = callonce uuid8

    * def expenseClassId = callonce uuid9

    * def fundWithoutBudgetId = callonce uuid10
    * def groupWithoutBudgetsId = callonce uuid11
    * def groupWithoutExpenseClasses = callonce uuid12
    * def groupWithExpenseClasses = callonce uuid13

  Scenario Outline: prepare finance for group with <groupId>

    * def groupId = <groupId>

    Given path '/finance/groups'
    And request
      """
      {
        'id': '#(groupId)',
        'code': '#(groupId)',
        'name': '#(groupId)',
        'status': 'Active'
      }
      """
    When method POST
    Then status 201

    Examples:
      | groupId                    |
      | groupWithoutBudgetsId      |
      | groupWithoutExpenseClasses |
      | groupWithExpenseClasses    |

  Scenario Outline: prepare finances for fund and budget with <fundId>, <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>


    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

    Examples:
      | fundId                                           | budgetId                                      |
      | fundIdWithoutExpenseClasses                      | budgetIdWithoutExpenseClasses                 |
      | fundIdWithExpenseClassesWithoutTransactions      | budgetIdWithExpenseClassesWithoutTransactions |
      | fundIdWithExpenseClassesWithTransactions         | budgetIdWithExpenseClassesWithTransactions    |


    Scenario Outline: prepare finance for groupFundFiscalYear with <groupId>, <fundId>, <budgetId>
      * def groupId = <groupId>
      * def fundId = <fundId>
      * def budgetId = <budgetId>

      Given path '/finance/group-fund-fiscal-years'
      And request
      """
      {
        'groupId': '#(groupId)',
        'fundId': '#(fundId)',
        'fiscalYearId': '#(globalFiscalYearId)',
        'budgetId': '#(budgetId)'
      }
      """
      When method POST
      Then status 201

      Examples:
        | groupId                    | fundId                                      | budgetId                                      |
        | groupWithoutBudgetsId      | globalFundWithoutBudget                     | null                                          |
        | groupWithoutExpenseClasses | fundIdWithoutExpenseClasses                 | budgetIdWithoutExpenseClasses                 |
        | groupWithExpenseClasses    | fundIdWithExpenseClassesWithoutTransactions | budgetIdWithExpenseClassesWithoutTransactions |
        | groupWithExpenseClasses    | fundIdWithExpenseClassesWithTransactions    | budgetIdWithExpenseClassesWithTransactions    |

  Scenario: prepare create expense class

    Given path '/finance/expense-classes'
    And request
    """
    {
      "id": "#(expenseClassId)",
      "name": "#(expenseClassId)"
    }
    """
    When method POST
    Then status 201

    Scenario Outline: prepare budget expense class with <budgetId>, <expenseClassId>
      * def budgetId = <budgetId>
      * def expenseClassId = <expenseClassId>

      Given path '/finance-storage/budget-expense-classes'
      And request
      """
      {
        "budgetId": "#(budgetId)",
        "expenseClassId": "#(expenseClassId)"
      }
      """
      When method POST
      Then status 201

      Examples:
        | budgetId                                      | expenseClassId            |
        | budgetIdWithExpenseClassesWithoutTransactions | expenseClassId            |
        | budgetIdWithExpenseClassesWithoutTransactions | globalElecExpenseClassId  |
        | budgetIdWithExpenseClassesWithTransactions    | globalElecExpenseClassId  |
        | budgetIdWithExpenseClassesWithTransactions    | globalPrnExpenseClassId   |


  Scenario: create invoice transaction summaries

    Given path '/finance-storage/invoice-transaction-summaries'
    And request
    """
    {
      "id": "#(invoiceId)",
      "numPendingPayments": "3",
      "numPaymentsCredits": "3"
    }
    """
    When method POST
    Then status 201


  Scenario Outline: create transaction with expenseClassId <expenseClassId>, amount <amount>, transactionType <transactionType>

    * def amount = <amount>
    * def transactionType = <transactionType>
    * def expenseClassId = <expenseClassId>

    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount': #(amount), 'expenseClassId': #(expenseClassId), 'orderId': #(orderId), 'invoiceId': #(invoiceId)}

    Examples:
      |  amount     | transactionType  | expenseClassId           |
      | 100         | "Payment"        | globalPrnExpenseClassId  |
      | 20          | "Credit"         | globalPrnExpenseClassId  |
      | 120         | "Payment"        | globalElecExpenseClassId |

  Scenario: Get group expense classes totals without budgets
    Given path '/finance/groups/', groupWithoutBudgetsId, '/expense-classes-totals'
    And param fiscalYearId = globalFiscalYearId
    When method GET
    Then status 200
    And match response.groupExpenseClassTotals == '#[0]'
    And match response.totalRecords == 0

  Scenario: Get group expense classes totals with budgets, without expense classes
    Given path '/finance/groups/', groupWithoutExpenseClasses, '/expense-classes-totals'
    And param fiscalYearId = globalFiscalYearId
    When method GET
    Then status 200
    And match response.groupExpenseClassTotals == '#[0]'
    And match response.totalRecords == 0


  Scenario: Get group expense classes totals with budgets, with expense classes
    Given path '/finance/groups/', groupWithExpenseClasses, '/expense-classes-totals'
    And param fiscalYearId = globalFiscalYearId
    When method GET
    Then status 200
    And match response.groupExpenseClassTotals == '#[3]'
    And match response.totalRecords == 3
    * def expenseClass1Totals = karate.jsonPath(response, "$.groupExpenseClassTotals[*][?(@.expenseClassName == 'Print')]")
    * def expenseClass2Totals = karate.jsonPath(response, "$.groupExpenseClassTotals[*][?(@.expenseClassName == 'Electronic')]")
    * def expenseClass3Totals = karate.jsonPath(response, "$.groupExpenseClassTotals[*][?(@.expenseClassName == @.id)]")
    And match expenseClass1Totals[0] contains { "expended": 80.0, "percentageExpended": 40.0 }
    And match expenseClass2Totals[0] contains { "expended": 120.0, "percentageExpended": 60.0 }
    And match expenseClass3Totals[0] contains { "expended": 0.0, "percentageExpended": 0.0 }