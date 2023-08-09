Feature: Ledger fiscal year sequential rollovers (skip previous year encumbrance)

  # 1) create 3 sequential fiscal years: fiscalYearId1, fiscalYearId2, fiscalYearId3. fiscalYearId1 contains current date
  # 3) rollover fiscalYearId1 -> fiscalYearId2
  # 3) change fiscalYear for encumbrance from fiscalYearId1 to fiscalYearId2
  # 4) update fiscalYearId1 to end before current date and fiscalYearId2 to include current date (to make it current fiscal year)
  # 6) rollover fiscalYearId2 -> fiscalYearId3

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testfinance1'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain'  }

    * configure headers = headersAdmin

    * callonce variables

    * def fiscalYearId1 = callonce uuid1
    * def fiscalYearId2 = callonce uuid2
    * def fiscalYearId3 = callonce uuid3

    * def rolloverLedger1 = callonce uuid4

    * def books = callonce uuid5

    * def latin = callonce uuid6

    * def latin2020 = callonce uuid7

    * def encumberRemaining = callonce uuid8

    * def encumberRemainingLine = callonce uuid9

    * def rolloverId1 = callonce uuid10
    * def rolloverId2 = callonce uuid11

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def toYear2 = parseInt(toYear) + 1
    * def updatedFirstSecondYearEnd = callonce getYesterday
    * def updatedSecondFiscalYearStart = callonce getCurrentDate

  Scenario: Update po line limit
    Given path 'configurations/entries'
    And param query = 'configName==poLines-limit'
    When method GET
    Then status 200
    * def config = $.configs[0]
    * set config.value = '999'
    * def configId = $.configs[0].id

    Given path 'configurations/entries', configId
    And request config
    When method PUT
    Then status 204


  Scenario Outline: prepare fiscal year with <fiscalYearId> for rollover
    * def fiscalYearId = <fiscalYearId>
    * def code = <code>

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
      | fiscalYearId  | code     |
      | fiscalYearId1 | fromYear |
      | fiscalYearId2 | toYear   |
      | fiscalYearId3 | toYear2  |

  Scenario Outline: prepare ledger with <ledgerId> for rollover
    * def ledgerId = <ledgerId>

    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(ledgerId)",
      "ledgerStatus": "Active",
      "name": "#(ledgerId)",
      "code": "#(ledgerId)",
      "fiscalYearOneId":"#(fiscalYearId1)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | ledgerId        |
      | rolloverLedger1 |

  Scenario Outline: prepare fund types with <fundTypeId>, <name> for rollover
    * def fundTypeId = <fundTypeId>
    * def name = <name>

    Given path 'finance/fund-types'
    And request
    """
    {
      "id": "#(fundTypeId)",
      "name": "#(codePrefix + name)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundTypeId | name         |
      | books      | 'Books'      |

  Scenario Outline: prepare fund with <fundId>, <ledgerId> for rollover
    * configure headers = headersAdmin
    * def fundId = <fundId>
    * def ledgerId = <ledgerId>
    * def fundCode = <fundCode>
    * def fundTypeId = <fundTypeId>

    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId)",
      "code": "#(codePrefix + fundCode)",
      "description": "Fund #(codePrefix + fundCode) for rollover API Tests",
      "externalAccountNo": "#(fundId)",
      "fundStatus": <status>,
      "ledgerId": "#(ledgerId)",
      "name": "Fund #(codePrefix + fundCode) for rollover API Tests",
      "fundTypeId": "#(fundTypeId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId         | ledgerId        | fundCode     | fundTypeId | status     |
      | latin          | rolloverLedger1 | 'LATIN'      | books      | 'Active'   |

  Scenario Outline: prepare budget with <fundId>, <fiscalYearId> for rollover
    * def id = <id>
    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def allocated = <allocated>
    * def expenseClasses = <expenseClasses>
    * def budgetStatus = <budgetStatus>

    Given path 'finance/budgets'

    * def budget =
    """
    {
      "id": "#(id)",
      "budgetStatus": "#(budgetStatus)",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": #(allocated)
    }
    """

    * if (<allowableEncumbrance> != null) karate.set('budget', '$.allowableEncumbrance', <allowableEncumbrance>)
    * if (<allowableExpenditure> != null) karate.set('budget', '$.allowableExpenditure', <allowableExpenditure>)
    * set budget.statusExpenseClasses = karate.map(expenseClasses, function(exp){return {'expenseClassId': exp}})

    And request budget
    When method POST
    Then status 201

    Given path 'finance/funds', fundId
    And method GET
    Then status 200

    Examples:
      | id               | fundId         | fiscalYearId  | allocated | allowableExpenditure | allowableEncumbrance | expenseClasses                                            | budgetStatus |
      | latin2020        | latin          | fiscalYearId1 | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] | 'Active'     |

  Scenario Outline: Create open orders with 1 fund distribution
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2022-12-03T00:00:00.000+00:00"} : null

    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": '#(orderId)',
      "vendor": '#(globalVendorId)',
      "workflowStatus": "Open",
      "orderType": <orderType>,
      "reEncumber": <reEncumber>,
      "ongoing": #(ongoing),
      "compositePoLines": [
        {
          "id": "#(poLineId)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(fundId)",
              "distributionType": "percentage",
              "value": 100
            }
          ],
          "orderFormat": "Physical Resource",
          "physical": {
            "createInventory": "None"
          },
          "purchaseOrderId": "#(orderId)",
          "source": "User",
          "titleOrPackage": "#(poLineId)"
        }
      ]

    }
    """
    When method POST
    Then status 201

    Examples:
      | orderId           | poLineId              | fundId       | orderType  | subscription | reEncumber | amount |
      | encumberRemaining | encumberRemainingLine | latin        | 'One-Time' | false        | true       | 10     |

  Scenario: Start first rollover for ledger 1
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId1)",
        "ledgerId": "#(rolloverLedger1)",
        "fromFiscalYearId": "#(fiscalYearId1)",
        "toFiscalYearId": "#(fiscalYearId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": false,
        "rolloverType": "Commit",
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": true,
            "adjustAllocation": 10,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Remaining",
            "increaseBy": 0
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Remaining",
            "increaseBy": 0
          },
          {
            "orderType": "One-time",
            "basedOn": "Remaining",
            "increaseBy": 0
          }
        ]
      }
    """
    When method POST
    Then status 201


  Scenario: Wait for first rollover for ledger 1 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

  Scenario Outline: Check that budget <id> status is <status> after rollover
    * configure headers = headersAdmin

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id               | status    |
      | latin2020        | 'Active'  |

  Scenario Outline: Check new budgets after rollover
    * def fundId = <fundId>

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId2
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.budgets[0].id

    Given path 'finance/budgets', budget_id
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.unavailable == <unavailable>
    And match response.netTransfers == <netTransfers>
    And match response.encumbered == <encumbered>

    * def allowableEncumbrance = response.allowableEncumbrance
    * def allowableExpenditure = response.allowableExpenditure

    And match allowableEncumbrance == <allowableEncumbrance>
    And match allowableExpenditure == <allowableExpenditure>
    And match response.statusExpenseClasses[*].expenseClassId contains only <expenseClasses>

    Examples:
      | fundId      | allocated | available | unavailable | netTransfers | encumbered | allowableEncumbrance | allowableExpenditure | expenseClasses                                            |
      | latin       | 1100      | 1090      | 10          | 0            | 10         | 100.0                | 100.0                | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] |

  Scenario: Check rollover 1 logs
    Given path 'finance/ledger-rollovers-logs', rolloverId1
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Commit'

  Scenario: Check rollover 1 statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'

  Scenario: update fiscal year 1 end to be before current date
    Given path 'finance/fiscal-years', fiscalYearId1
    And request
    """
    {
      "id": '#(fiscalYearId1)',
      "name": '#(codePrefix + fromYear)',
      "code": '#(codePrefix + fromYear)',
      "periodStart": '#(fromYear + "-01-01T00:00:00Z")',
      "periodEnd": '#(updatedFirstSecondYearEnd + "T23:59:59Z")',
      "_version": 1
    }
    """
    When method PUT
    Then status 204

  Scenario: update fiscal year 2 start to include current date
    Given path 'finance/fiscal-years', fiscalYearId2
    And request
    """
    {
      "id": '#(fiscalYearId2)',
      "name": '#(codePrefix + toYear)',
      "code": '#(codePrefix + toYear)',
      "periodStart": '#(updatedSecondFiscalYearStart + "T00:00:00Z")',
      "periodEnd": '#(toYear + "-12-30T23:59:59Z")',
      "_version": 1
    }
    """
    When method PUT
    Then status 204

  Scenario: Change fiscal year of encumbrance from previous to current year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId1 + ' AND encumbrance.sourcePoLineId==' + encumberRemainingLine
    When method GET
    Then status 200
    * def encumbrance = $.transactions[0]
    * set encumbrance.fiscalYearId = fiscalYearId2

    * configure headers = headersAdmin
    Given path 'finance/order-transaction-summaries', encumberRemaining
    And request
    """
    {
      "id": "#(encumberRemaining)",
      "numTransactions": 1
    }
    """
    When method PUT
    Then status 204

    Given path 'finance/encumbrances', encumbrance.id
    And request encumbrance
    When method PUT
    Then status 204

  Scenario: Start second rollover for ledger 1
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId2)",
        "ledgerId": "#(rolloverLedger1)",
        "fromFiscalYearId": "#(fiscalYearId2)",
        "toFiscalYearId": "#(fiscalYearId3)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": true,
            "adjustAllocation": 10,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Remaining",
            "increaseBy": 0
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Remaining",
            "increaseBy": 0
          },
          {
            "orderType": "One-time",
            "basedOn": "Remaining",
            "increaseBy": 0
          }
        ]
      }
    """
    When method POST
    Then status 201

  Scenario: Wait for second rollover for ledger 1 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

  Scenario Outline: Check that budget <id> status is <status> after rollover
    * configure headers = headersAdmin

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id               | status    |
      | latin2020        | 'Active'  |

  Scenario: Check rollover 2 logs
    Given path 'finance/ledger-rollovers-logs', rolloverId2
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Commit'

  Scenario: Check rollover 2 statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'

  Scenario Outline: Check new budgets after rollover
    * def fundId = <fundId>

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId3
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.budgets[0].id

    Given path 'finance/budgets', budget_id
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.unavailable == <unavailable>
    And match response.netTransfers == <netTransfers>
    And match response.encumbered == <encumbered>

    * def allowableEncumbrance = response.allowableEncumbrance
    * def allowableExpenditure = response.allowableExpenditure

    And match allowableEncumbrance == <allowableEncumbrance>
    And match allowableExpenditure == <allowableExpenditure>
    And match response.statusExpenseClasses[*].expenseClassId contains only <expenseClasses>

    Examples:
      | fundId      | allocated | available | unavailable | netTransfers | encumbered | allowableEncumbrance | allowableExpenditure | expenseClasses                                            |
      | latin       | 1210      | 1200      | 10          | 0            | 10         | 100.0                | 100.0                | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] |

  Scenario: Check expected number of encumbrances for new fiscal year
    * configure headers = headersAdmin
    Given path 'finance-storage/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId3 + ' AND transactionType==Encumbrance'
    When method GET
    Then status 200
    And match response.transactions == '#[1]'
