Feature: Group expense classes

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'testfinance5'}
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
    * def fundIdWithExpenseClassesWithPaymentsCredits = callonce uuid3
    * def fundIdWithExpenseClassesWithTransactions = callonce uuid4

    * def budgetIdWithoutExpenseClasses = callonce uuid5
    * def budgetIdWithExpenseClassesWithoutTransactions = callonce uuid6
    * def budgetIdWithExpenseClassesWithPaymentsCredits = callonce uuid7
    * def budgetIdWithExpenseClassesWithTransactions = callonce uuid8

    * def orderId = callonce uuid9
    * def invoiceId = callonce uuid10
    * def invoice1Id = callonce uuid11

    * def expenseClassId = callonce uuid12

    * def fundWithoutBudgetId = callonce uuid13
    * def groupWithoutBudgetsId = callonce uuid14
    * def groupWithoutExpenseClasses = callonce uuid15
    * def groupWithExpenseClasses = callonce uuid16

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
      | fundIdWithExpenseClassesWithPaymentsCredits      | budgetIdWithExpenseClassesWithPaymentsCredits |
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
        | groupWithExpenseClasses    | fundIdWithExpenseClassesWithPaymentsCredits | budgetIdWithExpenseClassesWithPaymentsCredits |
        | groupWithExpenseClasses    | fundIdWithExpenseClassesWithTransactions    | budgetIdWithExpenseClassesWithTransactions    |

  Scenario: prepare create expense class

    Given path '/finance/expense-classes'
    And request
    """
    {
      "id": "#(expenseClassId)",
      "name": "#(expenseClassId)",
      "code": "#(expenseClassId)"
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
        | budgetIdWithExpenseClassesWithPaymentsCredits | globalElecExpenseClassId  |
        | budgetIdWithExpenseClassesWithPaymentsCredits | globalPrnExpenseClassId   |
        | budgetIdWithExpenseClassesWithTransactions    | globalElecExpenseClassId  |
        | budgetIdWithExpenseClassesWithTransactions    | globalPrnExpenseClassId   |


  Scenario: create transaction summaries

    Given path 'finance-storage/order-transaction-summaries'
    And request
    """
    {
      "id": "#(orderId)",
      "numTransactions": "3"
    }
    """
    When method POST
    Then status 201

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

    Given path '/finance-storage/invoice-transaction-summaries'
    And request
    """
    {
      "id": "#(invoice1Id)",
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
    * def invoiceId = <invoiceId>
    * def fundId = <fundId>

    * call createTransaction { 'fundId': '#(fundId)', 'amount': #(amount), 'expenseClassId': #(expenseClassId), 'orderId': #(orderId), 'invoiceId': #(invoiceId), 'poLineId': '#(uuid())'}

    Examples:
      |  amount     | fundId                                      | transactionType   | expenseClassId           | invoiceId  |
      | 100         | fundIdWithExpenseClassesWithPaymentsCredits |"Payment"         | globalPrnExpenseClassId   | invoiceId  |
      | 20          | fundIdWithExpenseClassesWithPaymentsCredits |"Credit"          | globalPrnExpenseClassId   | invoiceId  |
      | 120         | fundIdWithExpenseClassesWithPaymentsCredits |"Payment"         | globalElecExpenseClassId  | invoiceId  |
      | 1.12        | fundIdWithExpenseClassesWithTransactions    |"Pending payment" | globalElecExpenseClassId  | invoice1Id |
      | 9.99        | fundIdWithExpenseClassesWithTransactions    |"Pending payment" | globalElecExpenseClassId  | invoice1Id |
      | 12          | fundIdWithExpenseClassesWithTransactions    |"Pending payment" | globalPrnExpenseClassId   | invoice1Id |
      | 1130        | fundIdWithExpenseClassesWithTransactions    |"Encumbrance"     | globalPrnExpenseClassId   | invoice1Id |
      | 41          | fundIdWithExpenseClassesWithTransactions    |"Encumbrance"     | globalElecExpenseClassId  | invoice1Id |
      | 999         | fundIdWithExpenseClassesWithTransactions    |"Encumbrance"     | null                      | invoice1Id |

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
    And match expenseClass1Totals[0] contains { "encumbered": 1130, "awaitingPayment": 12, "expended": 80.0, "percentageExpended": 40.0 }
    And match expenseClass2Totals[0] contains { "encumbered": 41, "awaitingPayment": 11.11, "expended": 120.0, "percentageExpended": 60.0 }
    And match expenseClass3Totals[0] contains { "expended": 0.0, "percentageExpended": 0.0 }