Feature: Expense classes validation upon invoice approval

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_invoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * callonce variables

    * def currentFyId = callonce uuid1
    * def prevFyId = callonce uuid2

    * def ledgerId = callonce uuid3

    * def currentlyAssignedFundId = callonce uuid4
    * def previouslyAssignedFundId = callonce uuid5

    * def currentWithClassesBudgetId = callonce uuid6
    * def prevWithClassesBudgetId = callonce uuid7
    * def currentNoClassesBudgetId = callonce uuid8
    * def prevWithClassesBudgetId2 = callonce uuid9

    * def codePrefix = callonce random_string

    * def currentYear = callonce getCurrentYear
    * def prevYear = parseInt(currentYear) - 1

  Scenario Outline: Create fiscal year for <code>

    * def fiscalYearId = <id>
    * def code = <code>

    * configure headers = headersAdmin
    Given path 'finance/fiscal-years'
    And request
    """
    {
      "id": '#(fiscalYearId)',
      "name": '#(codePrefix + code)',
      "code": '#(codePrefix + code)',
      "periodStart": '#(code + "-01-01T00:00:00Z")',
      "periodEnd": '#(code + "-12-30T23:59:59Z")'
    }
    """
    When method POST
    Then status 201

    Examples:
      | id          | code        |
      | currentFyId | currentYear |
      | prevFyId    | prevYear    |

  Scenario: Create ledger

    * configure headers = headersAdmin
    Given path 'finance/ledgers'
    And request
    """
    {
      "id": '#(ledgerId)',
      "name": '#(ledgerId)',
      "code": '#(ledgerId)',
      "ledgerStatus": 'Active',
      "fiscalYearOneId": '#(prevFyId)',
      "restrictEncumbrance": false,
      "restrictExpenditures": false
    }
    """
    When method POST
    Then status 201


  Scenario Outline: Create fund <id>
    * def fundId = <id>

    * configure headers = headersAdmin
    Given path 'finance/funds'
    And request
    """
    {
      "fund": {
        "id": "#(fundId)",
        "code": "#(fundId)",
        "description": "Fund for orders API Tests",
        "externalAccountNo": "1111111111111111111111111",
        "fundStatus": "Active",
        "ledgerId": "#(ledgerId)",
        "name": "Fund for API Tests"
      }

     }
    """
    When method POST
    Then status 201

    Examples:
    | id                       |
    | currentlyAssignedFundId  |
    | previouslyAssignedFundId |

  Scenario Outline: Create budget for <fundId>, <fiscalYearId>, <status>
    * def budgetId = <id>
    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def status = <status>
    * configure headers = headersAdmin
    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId": "#(fiscalYearId)",
      "budgetStatus": "#(status)",
      "allowableExpenditure": 100,
      "allowableEncumbrance": 100,
      "allocated": 10000
    }
    """
    When method POST
    Then status 201
    Examples:
    | id                         | fundId                   | fiscalYearId | status     |
    | currentWithClassesBudgetId | currentlyAssignedFundId  | currentFyId  | 'Active'   |
    | prevWithClassesBudgetId    | currentlyAssignedFundId  | prevFyId     | 'Inactive' |
    | currentNoClassesBudgetId   | previouslyAssignedFundId | currentFyId  | 'Active'   |
    | prevWithClassesBudgetId2   | previouslyAssignedFundId | prevFyId     | 'Inactive' |


  Scenario Outline: Assign expense classes to budgets for <budgetId>, <expenseClassId>, <status>

    * def budgetId = <budgetId>
    * def expenseClassId = <expenseClassId>

    * configure headers = headersAdmin

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
      | budgetId                     | expenseClassId           | status     |
      | currentWithClassesBudgetId   | globalElecExpenseClassId | "Active"   |
      | currentWithClassesBudgetId   | globalPrnExpenseClassId  | "Inactive" |
      | prevWithClassesBudgetId2     | globalElecExpenseClassId | "Active"   |
      | prevWithClassesBudgetId      | globalElecExpenseClassId | "Active"   |

  Scenario Outline: Check invoice approval with fundDistribution in adjustment for <fundId>, <expenseClassId>

    * def fundId = <fundId>
    * def expenseClassId = <expenseClassId>
    * configure headers = headersUser

    Given path 'invoice/invoices'
    And request
    """
    {
      "adjustments": [
        {
          "description": "Shipping",
          "exportToAccounting" : false,
          "type": "Amount",
          "value": 4.50,
          "prorate": "Not prorated",
          "relationToTotal": "In addition to",
          "fundDistributions": [
            {
              "fundId": "#(fundId)",
              "expenseClassId": "#(expenseClassId)",
              "distributionType": "percentage",
              "value": 100,

            }
          ]
        }
      ],
      "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
      "currency": "USD",
      "invoiceDate": "2020-10-20T00:00:00.000+0000",
      "paymentMethod": "EFT",
      "status": "Reviewed",
      "source": "User",
      "vendorInvoiceNo": "YK75851",
      "vendorId": "c6dace5d-4574-411e-8ba1-036102fcdc9b"
    }
    """
    When method POST
    Then status 201
    * def invoiceId = $.id

    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "description": "Some description",
      "fundDistributions": [
        {
          "code": "USHIST",
          "fundId": "#(currentlyAssignedFundId)",
          "distributionType": "percentage",
          "value": 100
        }
      ],
      "invoiceId": '#(invoiceId)',
      "invoiceLineStatus": "Open",
      "quantity": 1,
      "releaseEncumbrance": false,
      "subTotal": 25.00
    }
    """
    When method POST
    Then status 201

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status <httpCode>
    * if (<httpCode> == 400) karate.match(<error>, response.errors[0].code)
    * if (<httpCode> == 400) karate.match(<fundId>, response.errors[0].parameters[0].value)
    * if (<httpCode> == 400) karate.match(<expenseClassId>, response.errors[0].parameters[1].value)

    Examples:
      | fundId                   | expenseClassId           | error                        | httpCode |
      | currentlyAssignedFundId  | globalElecExpenseClassId | null                         | 204      |
      | currentlyAssignedFundId  | globalPrnExpenseClassId  | 'inactiveExpenseClass'       | 400      |
      | previouslyAssignedFundId | globalElecExpenseClassId | 'budgetExpenseClassNotFound' | 400      |

  Scenario Outline: Check invoice approval with fundDistribution in invoice line for <fundId>, <expenseClassId>

    * def fundId = <fundId>
    * def expenseClassId = <expenseClassId>

    * configure headers = headersUser

    Given path 'invoice/invoices'
    And request
    """
    {
      "batchGroupId": "2a2cb998-1437-41d1-88ad-01930aaeadd5",
      "currency": "USD",
      "invoiceDate": "2020-10-20T00:00:00.000+0000",
      "paymentMethod": "EFT",
      "status": "Reviewed",
      "source": "User",
      "vendorInvoiceNo": "YK75851",
      "vendorId": "c6dace5d-4574-411e-8ba1-036102fcdc9b"
    }
    """
    When method POST
    Then status 201
    * def invoiceId = $.id

    Given path 'invoice/invoice-lines'
    And request
    """
    {
      "description": "Some description",
      "fundDistributions": [
        {
            "fundId": "#(fundId)",
            "expenseClassId": "#(expenseClassId)",
            "distributionType": "percentage",
            "value": 100
          }
      ],
      "invoiceId": '#(invoiceId)',
      "invoiceLineStatus": "Open",
      "quantity": 1,
      "releaseEncumbrance": false,
      "subTotal": 25.00
    }
    """
    When method POST
    Then status 201

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = "Approved"

    Given path 'invoice/invoices', invoiceId
    And request invoicePayload
    When method PUT
    Then status <httpCode>
    * if (<httpCode> == 400) karate.match(<error>, response.errors[0].code)
    * if (<httpCode> == 400) karate.match(<fundId>, response.errors[0].parameters[0].value)
    * if (<httpCode> == 400) karate.match(<expenseClassId>, response.errors[0].parameters[1].value)

    Examples:
      | fundId                   | expenseClassId           | error                        | httpCode |
      | currentlyAssignedFundId  | globalElecExpenseClassId | null                         | 204      |
      | currentlyAssignedFundId  | globalPrnExpenseClassId  | 'inactiveExpenseClass'       | 400      |
      | previouslyAssignedFundId | globalElecExpenseClassId | 'budgetExpenseClassNotFound' | 400      |