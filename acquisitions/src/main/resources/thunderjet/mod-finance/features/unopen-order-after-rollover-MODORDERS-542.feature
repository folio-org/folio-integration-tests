@parallel=false
Feature: Ledger fiscal year rollover issue MODORDERS-542

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fromFiscalYearId = callonce uuid1
    * def toFiscalYearId = callonce uuid2

    * def rolloverLedger = callonce uuid3
    * def noRolloverLedger = callonce uuid4

    * def books = callonce uuid5

    * def fundHist = callonce uuid9
    * def budgetHist2020 = callonce uuid17


    * def encumberRemaining1 = callonce uuid26
    * def encumberRemainingLine1 = callonce uuid32


    * def expendedHigherLine = callonce uuid33
    * def expendedLowerLine = callonce uuid34
    * def orderClosedLine = callonce uuid35
    * def noReEncumberLine = callonce uuid36
    * def crossLedgerLine = callonce uuid37

    * def encumbranceInvoiceId = callonce uuid46
    * def noEncumbranceInvoiceId = callonce uuid47


    * def encumberRemaining2 = callonce uuid48
    * def encumberRemainingLine2 = callonce uuid49

    * def rolloverId = callonce uuid59
    * def groupId1 = callonce uuid60

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

  Scenario: Update po line limit
    * configure headers = headersAdmin
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
      | fiscalYearId     | code     |
      | fromFiscalYearId | fromYear |
      | toFiscalYearId   | toYear   |

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
      "fiscalYearOneId":"#(fromFiscalYearId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | ledgerId         |
      | rolloverLedger   |
      | noRolloverLedger |

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


  Scenario Outline: Create groups
    * def code = call uuid
    * def groupId = <group>
    Given path '/finance/groups'
    And request
    """
    {
      "id": "#(groupId)",
      "code": "#(code)",
      "description": "#(code)",
      "name": "#(code)",
      "status": "Active"
    }
    """
    When method POST
    Then status 201
    Examples:
      | group    |
      | groupId1 |

  Scenario Outline: prepare fund with <fundId>, <ledgerId> for rollover
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
      | fundId    | ledgerId         | fundCode     | fundTypeId | status     |
      | fundHist  | rolloverLedger   | 'HIST'       | null       | 'Active'   |


  Scenario Outline: prepare budget with <fundId>, <fiscalYearId> for rollover
    * def id = <id>
    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def allocated = <allocated>
    * def expenseClasses = <expenseClasses>

    Given path 'finance/budgets'

    * def budget =
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
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

    * def fundRS = $
    * set fundRS.groupIds = <groups>

    Given path 'finance/funds', fundId
    When request fundRS
    And method PUT
    Then status 204

    Examples:
      | id               | fundId       | fiscalYearId     | allocated | allowableExpenditure | allowableEncumbrance | expenseClasses                                            | groups                       |
      | budgetHist2020   | fundHist     | fromFiscalYearId | 60        | 100                  | 100                  | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] | ['#(groupId1)']              |

  Scenario Outline: Create open orders with 2 lines distribution
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": '#(orderId)',
      "vendor": '#(globalVendorId)',
      "workflowStatus": "Open",
      "orderType": <orderType>,
      "reEncumber": <reEncumber>,
      "poLines": [
        {
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(fundHist)",
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
      | orderId            | poLineId               | fundId   | orderType  | reEncumber | amount |
      | encumberRemaining1 | encumberRemainingLine1 | fundHist | 'One-Time' | true       | 0      |
      | encumberRemaining2 | encumberRemainingLine2 | fundHist | 'One-Time' | true       | 10     |



  Scenario: Start rollover for ledger
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(rolloverLedger)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
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


  Scenario: Wait for rollover to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


  Scenario: Delete rollover with Success status
    Given path '/finance-storage/ledger-rollovers', rolloverId
    When method DELETE
    Then status 204


  Scenario Outline: Change fiscal year <fiscalYearId> period to the previous year
    # this is needed to change the current fiscal year and start operating in the new fiscal year
    * def fiscalYearId = <fiscalYearId>
    * def code = <code>

    Given path 'finance/fiscal-years', fiscalYearId
    When method GET
    Then status 200
    * def fy = $
    * def newYear = code - 1
    * set fy.periodStart = newYear + '-01-01T00:00:00Z'
    * set fy.periodEnd = newYear + '-12-30T23:59:59Z'
    Given path 'finance/fiscal-years', fiscalYearId
    And request fy
    When method PUT
    Then status 204

    Examples:
      | fiscalYearId     | code     |
      | fromFiscalYearId | fromYear |
      | toFiscalYearId   | toYear   |


  Scenario: Unopen order
    # get the old budget
    Given path 'finance/budgets', budgetHist2020
    When method GET
    Then status 200

    * configure headers = headersAdmin
    Given path 'orders/composite-orders', encumberRemaining2
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = "Pending"

    Given path 'orders/composite-orders', encumberRemaining2
    And request order
    And header X-Okapi-Permissions = 'orders.item.unopen'
    When method PUT
    Then status 204
    * configure headers = headersUser

    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + encumberRemaining2
    When method GET
    Then status 200
    And match $.transactions == '#[2]'


    # check the old budget has not changed
    Given path 'finance/budgets', budgetHist2020
    When method GET
    Then status 200
    And match $.allocated == 60
    And match $.available == 50
    And match $.encumbered == 10
