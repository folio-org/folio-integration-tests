Feature: Budge's totals (available, unavailable, encumbered) is updated when encumbrance's amount is changed but status has not been changed

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
    * def fundIdWithPaymentCredits = callonce uuid4

    * def budgetIdWithoutExpenseClasses = callonce uuid5
    * def budgetIdWithExpenseClassesWithoutTransactions = callonce uuid6
    * def budgetIdWithExpenseClassesWithTransactions = callonce uuid7
    * def budgetIdWithPaymentCredits = callonce uuid8
    * def budgetIdNonExisting = callonce uuid9

    * def orderId = callonce uuid10
    * def pendingPaymentInvoiceId = callonce uuid11
    * def paymentCreditInvoiceId = callonce uuid12

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 99999999}

    Examples:
      | fundId                                           | budgetId                                            |
      | fundIdWithoutExpenseClasses                      | budgetIdWithoutExpenseClasses                       |
      | fundIdWithExpenseClassesWithoutTransactions      | budgetIdWithExpenseClassesWithoutTransactions       |
      | fundIdWithExpenseClassesWithTransactions         | budgetIdWithExpenseClassesWithTransactions          |
      | fundIdWithPaymentCredits                         | budgetIdWithPaymentCredits                          |

  Scenario Outline: create budgetExpense class relation with expenseClassId <expenseClassId> and budget <budgetId>
    * def budgetId = <budgetId>
    * def expenseClassId = <expenseClassId>

    Given path 'finance-storage/budget-expense-classes'
    And request
    """
    {
      "budgetId": "#(budgetId)",
      "expenseClassId": "#(expenseClassId)",
      "status": <status>
    }
    """
    When method POST
    Then status 201

    Examples:
      | budgetId                                             | expenseClassId           | status     |
      | budgetIdWithExpenseClassesWithoutTransactions        | globalElecExpenseClassId | "Active"   |
      | budgetIdWithExpenseClassesWithoutTransactions        | globalPrnExpenseClassId  | "Inactive" |
      | budgetIdWithExpenseClassesWithTransactions           | globalElecExpenseClassId | "Active"   |
      | budgetIdWithPaymentCredits                           | globalPrnExpenseClassId  | "Active"    |
      | budgetIdWithPaymentCredits                           | globalElecExpenseClassId | "Active"    |

  Scenario: create order transaction summary

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

  Scenario Outline: create invoice transaction summaries <invoiceId>
    * def invoiceId = <invoiceId>

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

    Examples:
    | invoiceId               |
    | pendingPaymentInvoiceId |
    | paymentCreditInvoiceId  |

  Scenario Outline: create transaction with fundId <fundId>, expenseClassId <expenseClassId>, amount <amount>, transactionType <transactionType>, invoiceId <invoiceId>
    * def fundId = <fundId>
    * def amount = <amount>
    * def transactionType = <transactionType>
    * def expenseClassId = <expenseClassId>
    * def invoiceId = <invoiceId>

    * call createTransaction { 'fundId': '#(fundId)', 'amount': #(amount), 'expenseClassId': #(expenseClassId), 'orderId': #(orderId), 'invoiceId': #(invoiceId)}

    Examples:
      | fundId                                       |  amount     | transactionType  | expenseClassId           | invoiceId               |
      | fundIdWithExpenseClassesWithTransactions     | 11.0        | "Encumbrance"    | globalElecExpenseClassId | null                    |
      | fundIdWithExpenseClassesWithTransactions     | 54.11       | "Encumbrance"    | globalElecExpenseClassId | null                    |
      | fundIdWithExpenseClassesWithTransactions     | 1004.11     | "Encumbrance"    | null                     | null                    |
      | fundIdWithExpenseClassesWithTransactions     | 12          | "Pending payment"| globalElecExpenseClassId | pendingPaymentInvoiceId |
      | fundIdWithExpenseClassesWithTransactions     | -11.4       | "Pending payment"| globalElecExpenseClassId | pendingPaymentInvoiceId |
      | fundIdWithExpenseClassesWithTransactions     | 1102        | "Pending payment"| null                     | pendingPaymentInvoiceId |
      | fundIdWithPaymentCredits                     | 100         | "Payment"        | globalPrnExpenseClassId  | paymentCreditInvoiceId  |
      | fundIdWithPaymentCredits                     | 20          | "Credit"         | globalPrnExpenseClassId  | paymentCreditInvoiceId  |
      | fundIdWithPaymentCredits                     | 120         | "Payment"        | globalElecExpenseClassId | paymentCreditInvoiceId  |


  Scenario: Get expense class totals for budget without expense classes

    Given path '/finance/budgets/', budgetIdWithoutExpenseClasses, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[0]'
    And match response.totalRecords == 0

  Scenario: Get expense class totals for budget with expense classes and without transactions

    Given path '/finance/budgets/', budgetIdWithExpenseClassesWithoutTransactions, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[2]'
    And match response.totalRecords == 2
    And match each response.budgetExpenseClassTotals contains {"encumbered": 0.00, "awaitingPayment": 0.00, "expended": 0.00, "percentageExpended": 0.00}

  Scenario: Get expense class totals for budget with expense classes and with transactions

    Given path '/finance/budgets/', budgetIdWithExpenseClassesWithTransactions, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[1]'
    And match response.totalRecords == 1
    And match each response.budgetExpenseClassTotals contains {"encumbered": 65.11, "awaitingPayment": 0.6, "expended": 0.00, "percentageExpended": "#notpresent"}

  Scenario: Get expense class totals for budget with expense classes and with payment and credit transactions

    Given path '/finance/budgets/', budgetIdWithPaymentCredits, 'expense-classes-totals'
    When method GET
    Then status 200
    And match response.budgetExpenseClassTotals == '#[2]'
    And match response.totalRecords == 2
    * def expenseClass1Totals = karate.jsonPath(response, "$.budgetExpenseClassTotals[*][?(@.expenseClassName == 'Print')]")
    * def expenseClass2Totals = karate.jsonPath(response, "$.budgetExpenseClassTotals[*][?(@.expenseClassName == 'Electronic')]")
    And match expenseClass1Totals[0] contains { "expended": 80.0, "percentageExpended": 40.0 }
    And match expenseClass2Totals[0] contains { "expended": 120.0, "percentageExpended": 60.0 }
