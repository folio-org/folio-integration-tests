Feature: Ledger fiscal year rollover when "Close all current budgets" flag is true

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain'  }

    * configure headers = headersAdmin

    * callonce variables

    * def fromFiscalYearId = callonce uuid1
    * def toFiscalYearId = callonce uuid2

    * def rolloverLedger = callonce uuid3

    * def books = callonce uuid5

    * def rolloverId = callonce uuid59
    * def groupId1 = callonce uuid60

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

    * def taxFund = callonce uuid80

    * def taxBud1 = callonce uuid81
    * def taxBud2 = callonce uuid82

    * def reEncumberOrder = callonce uuid83
    * def reEncumberLine = callonce uuid84

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
      | fundId       | ledgerId         | fundCode     | fundTypeId | status     |
      | taxFund      | rolloverLedger   | 'TAX'        | books      | 'Active'   |


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

    * def fundRS = $
    * set fundRS.groupIds = <groups>

    Given path 'finance/funds', fundId
    When request fundRS
    And method PUT
    Then status 204

    Examples:
      | id               | fundId       | fiscalYearId     | allocated | allowableExpenditure | allowableEncumbrance | expenseClasses                                            | groups                       | budgetStatus |
      | taxBud1          | taxFund      | fromFiscalYearId | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Active'     |
      | taxBud2          | taxFund      | toFiscalYearId   | 500       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Planned'    |


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
      | reEncumberOrder   | reEncumberLine        | taxFund      | 'Ongoing'  | false        | true       | 150    |

  Scenario: Start rollover for ledger
    * configure headers = headersUser
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
        "rolloverType": "Preview",
        "budgetsRollover": [
          {
            "fundTypeId": "#(books)",
            "addAvailableTo": "Available"
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "InitialAmount"
          }
        ]
      }
    """
    When method POST
    Then status 201


  Scenario Outline: Check that budget <id> status is <status> after rollover, budget status should not be changed
    * configure headers = headersAdmin

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id               | status   |
      | taxBud1          | 'Active'  |
      | taxBud2          | 'Planned' |


  Scenario Outline: Check new budgets after rollover
    * def fundId = <fundId>

    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.ledgerFiscalYearRolloverBudgets[0].id

    Given path 'finance/ledger-rollovers-budgets', budget_id
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

    And match response.fundDetails.id == <fundId>
    And match response.fundDetails.code == codePrefix + <fundCode>
    And match response.fundDetails.fundStatus == <fundStatus>

    And match response.expenseClassDetails[0].expenseClassName == <expenseClassName>
    And match response.expenseClassDetails[0].expenseClassCode == <expenseClassCode>
    And match response.expenseClassDetails[0].expenseClassStatus == <expenseClassStatus>

    Examples:
      | fundId      | fundCode    | fundStatus  | allocated | available | unavailable | netTransfers | encumbered | allowableEncumbrance | allowableExpenditure | expenseClassName | expenseClassCode | expenseClassStatus |
      | taxFund     | 'TAX'       | 'Active'    | 500       | 350       | 150         | 0            | 150        | 100.0                | 100.0                | 'Electronic'     | 'Elec'           | 'Active'           |

  Scenario: Check rollover logs
    Given path 'finance/ledger-rollovers-logs', rolloverId
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Preview'

  Scenario: Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'

  Scenario: Change rollover status to In progress to check restriction
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    * def rolloverProgress = $.ledgerFiscalYearRolloverProgresses[0]
    * set rolloverProgress.ordersRolloverStatus = 'In Progress'

    Given path 'finance/ledger-rollovers-progress', rolloverProgress.id
    And request rolloverProgress
    When method PUT
    Then status 204

  Scenario: Delete rollover with In Progress status
    * configure headers = headersAdmin
    Given path '/finance-storage/ledger-rollovers', rolloverId
    When method DELETE
    Then status 422
    * match response == "Can't delete in progress rollover"

  Scenario: Change rollover status to Success to check restriction
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    * def rolloverProgress = $.ledgerFiscalYearRolloverProgresses[0]
    * set rolloverProgress.ordersRolloverStatus = 'Success'

    Given path 'finance/ledger-rollovers-progress', rolloverProgress.id
    And request rolloverProgress
    When method PUT
    Then status 204

  Scenario: Delete rollover with Success status
    * configure headers = headersAdmin
    Given path '/finance-storage/ledger-rollovers', rolloverId
    When method DELETE
    Then status 204
