Feature: Budget expense classes

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_finance3'}
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

  Scenario Outline: prepare finances for fund with <fundId>
    * def fundId = <fundId>

    * call createFund { 'id': '#(fundId)'}

    Examples:
      | fundId                                           |
      | fundIdWithoutExpenseClasses                      |
      | fundIdWithExpenseClassesWithoutTransactions      |
      | fundIdWithExpenseClassesWithTransactions         |

  Scenario: create expense class

    Given path 'finance/expense-classes'
    And request
    """
    {
      "id": "#(expenseClassId)",
      "name": "Test",
      "code": "test"
    }
    """
    When method POST
    Then status 201

  Scenario: Create budget without expense classes and check expense class totals, then update with expense classes

    * call createBudget { 'id': '#(budgetIdWithoutExpenseClasses)', 'fundId': '#(fundIdWithoutExpenseClasses)', 'allocated': 100}

    Given path '/finance/budgets/', budgetIdWithoutExpenseClasses
    When method GET
    Then status 200
    And match response.statusExpenseClasses == '#[0]'
    * def budgetBody = $
    * set budgetBody.statusExpenseClasses = [{'expenseClassId': '#(expenseClassId)'}]

    Given path '/finance/budgets/', budgetIdWithoutExpenseClasses, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[0]'
    And match response.totalRecords == 0

    Given path '/finance/budgets/', budgetIdWithoutExpenseClasses
    And request budgetBody
    When method PUT
    Then status 204

    Given path '/finance/budgets/', budgetIdWithoutExpenseClasses
    When method GET
    Then status 200
    And match response.statusExpenseClasses == '#[1]'
    And  match response.statusExpenseClasses[0] == {'expenseClassId': '#(expenseClassId)', 'status': 'Active'}

    Given path '/finance/budgets/', budgetIdWithoutExpenseClasses, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[1]'
    And match response.totalRecords == 1
    And match each response.budgetExpenseClassTotals contains {"encumbered": 0.00, "awaitingPayment": 0.00, "expended": 0.00, "percentageExpended": 0.00}

    Given path '/finance-storage/budget-expense-classes'
    And param query = 'budgetId==' + budgetIdWithoutExpenseClasses
    When method GET
    Then status 200
    And match response.budgetExpenseClasses == '#[1]'
    And match response.budgetExpenseClasses[0] == {'id': '#string','budgetId': '#(budgetIdWithoutExpenseClasses)', 'expenseClassId': '#(expenseClassId)', 'status': 'Active', '_version': 1}

  Scenario: Create and update budget with expense classes and get expense class totals for created budget

    * def statusExpenseClassesForCreate = [{'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Inactive'}, {'expenseClassId': '#(globalPrnExpenseClassId)'}]
    * def statusExpenseClassesForUpdate = [{'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Active'}, {'expenseClassId': '#(expenseClassId)'}]
    * call createBudget { 'id': '#(budgetIdWithExpenseClassesWithoutTransactions)', 'fundId': '#(fundIdWithExpenseClassesWithoutTransactions)', 'allocated': 100, 'statusExpenseClasses': '#(statusExpenseClassesForCreate)'}

    Given path '/finance-storage/budget-expense-classes'
    And param query = 'budgetId==' + budgetIdWithExpenseClassesWithoutTransactions
    When method GET
    Then status 200
    And match response.budgetExpenseClasses == '#[2]'
    * def expected1 = { 'id': '#string', 'budgetId': '#(budgetIdWithExpenseClassesWithoutTransactions)', 'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Inactive', '_version': 1 }
    * def expected2 = { 'id': '#string', 'budgetId': '#(budgetIdWithExpenseClassesWithoutTransactions)', 'expenseClassId': '#(globalPrnExpenseClassId)', 'status': 'Active', '_version': 1 }
    And match response.budgetExpenseClasses contains expected1
    And match response.budgetExpenseClasses contains expected2

    Given path '/finance/budgets', budgetIdWithExpenseClassesWithoutTransactions
    When method GET
    Then status 200
    And response.statusExpenseClasses == '#[2]'
    * def expected1 = { 'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Inactive' }
    * def expected2 = { 'expenseClassId': '#(globalPrnExpenseClassId)', 'status': 'Active' }
    And match response.statusExpenseClasses contains expected1
    And match response.statusExpenseClasses contains expected2
    * def budgetBody = $
    * set budgetBody.statusExpenseClasses = statusExpenseClassesForUpdate

    Given path '/finance/budgets/', budgetIdWithExpenseClassesWithoutTransactions, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[2]'
    And match response.totalRecords == 2
    And match each response.budgetExpenseClassTotals contains {"encumbered": 0.00, "awaitingPayment": 0.00, "expended": 0.00, "percentageExpended": 0.00}

    Given path '/finance/budgets', budgetIdWithExpenseClassesWithoutTransactions
    And request budgetBody
    When method PUT
    Then status 204

    Given path '/finance-storage/budget-expense-classes'
    And param query = 'budgetId==' + budgetIdWithExpenseClassesWithoutTransactions
    When method GET
    Then status 200
    And match response.budgetExpenseClasses == '#[2]'
    * def expected1 = {'id': '#string','budgetId': '#(budgetIdWithExpenseClassesWithoutTransactions)', 'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Active', '_version': 2}
    * def expected2 = {'id': '#string','budgetId': '#(budgetIdWithExpenseClassesWithoutTransactions)', 'expenseClassId': '#(expenseClassId)', 'status': 'Active', '_version': 1}
    And match response.budgetExpenseClasses contains expected1
    And match response.budgetExpenseClasses contains expected2

    Given path '/finance/budgets', budgetIdWithExpenseClassesWithoutTransactions
    When method GET
    Then status 200
    And response.statusExpenseClasses == '#[2]'
    * def expected1 = {'expenseClassId': '#(globalElecExpenseClassId)', 'status': 'Active'}
    * def expected2 = {'expenseClassId': '#(expenseClassId)', 'status': 'Active'}
    And match response.statusExpenseClasses contains expected1
    And match response.statusExpenseClasses contains expected2

  Scenario: Create budget with expense classes and get expense class totals for budget with expense classes and with transactions

    * def statusExpenseClassesForCreate = [{'expenseClassId': '#(globalElecExpenseClassId)'}]
    * def statusExpenseClassesForUpdate = [{'expenseClassId': '#(globalElecExpenseClassId)'}, {'expenseClassId': '#(globalPrnExpenseClassId)'}]
    * call createBudget { 'id': '#(budgetIdWithExpenseClassesWithTransactions)', 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'allocated': 10000, 'statusExpenseClasses': '#(statusExpenseClassesForCreate)'}


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

    Given path 'finance-storage/invoice-transaction-summaries'
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

    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount': 11.0, 'expenseClassId': '#(globalElecExpenseClassId)', 'orderId': '#(orderId)', 'transactionType': 'Encumbrance'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  54.11, 'expenseClassId': '#(globalElecExpenseClassId)', 'orderId': '#(orderId)', 'transactionType': 'Encumbrance'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  1004.11, 'expenseClassId': null, 'orderId': '#(orderId)', 'transactionType': 'Encumbrance'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  12, 'expenseClassId': '#(globalElecExpenseClassId)', 'invoiceId': '#(invoiceId)', 'transactionType': 'Pending payment'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  -11.4, 'expenseClassId': '#(globalElecExpenseClassId)', 'invoiceId': '#(invoiceId)', 'transactionType': 'Pending payment'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  1102, 'expenseClassId': null, 'invoiceId': '#(invoiceId)', 'transactionType': 'Pending payment'}

    Given path '/finance/budgets/', budgetIdWithExpenseClassesWithTransactions, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[1]'
    And match response.totalRecords == 1
    And match each response.budgetExpenseClassTotals contains {"encumbered": 65.11, "awaitingPayment": 0.6, "expended": 0.00, "percentageExpended": "#notpresent"}

    Given path '/finance/budgets', budgetIdWithExpenseClassesWithTransactions
    When method GET
    Then status 200
    * def budgetBody = $
    * set budgetBody.statusExpenseClasses = statusExpenseClassesForUpdate


    Given path '/finance/budgets', budgetIdWithExpenseClassesWithTransactions
    And request budgetBody
    When method PUT
    Then status 204

    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  100, 'expenseClassId': '#(globalPrnExpenseClassId)', 'invoiceId': '#(invoiceId)', 'transactionType': 'Payment'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  20, 'expenseClassId': '#(globalPrnExpenseClassId)', 'invoiceId': '#(invoiceId)', 'transactionType': 'Credit'}
    * call createTransaction { 'fundId': '#(fundIdWithExpenseClassesWithTransactions)', 'amount':  120, 'expenseClassId': '#(globalElecExpenseClassId)', 'invoiceId': '#(invoiceId)', 'transactionType': 'Payment'}

    Given path '/finance/budgets/', budgetIdWithExpenseClassesWithTransactions, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[2]'
    And match response.totalRecords == 2
    * def expenseClass1Totals = karate.jsonPath(response, "$.budgetExpenseClassTotals[*][?(@.expenseClassName == 'Print')]")
    * def expenseClass2Totals = karate.jsonPath(response, "$.budgetExpenseClassTotals[*][?(@.expenseClassName == 'Electronic')]")
    And match expenseClass1Totals[0] contains { "expended": 80.0, "percentageExpended": 40.0 }
    And match expenseClass2Totals[0] contains { "expended": 120.0, "percentageExpended": 60.0 }

