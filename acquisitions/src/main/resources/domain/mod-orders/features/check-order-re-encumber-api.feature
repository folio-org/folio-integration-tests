Feature: Check needReEncumber flag populated correctly

  Background:
    * url baseUrl
    # uncomment below line for development
    # * callonce dev {tenant: 'test_orders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
    * def plannedFiscalYearId = karate.get('plannedFiscalYearId', globalPlannedFiscalYearId)

    * def approvalsFundTypeId = karate.get('approvalsFundTypeId', globalFundType)

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def rolloverId = callonce uuid5
    * def rolloverErrorId = callonce uuid6

    * def fundId = callonce uuid7
    * def budgetId = callonce uuid8

  Scenario Outline: prepare finances for fiscal year with <fiscalYearId> for re-encumber

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

  Scenario Outline: prepare finances for ledger with <ledgerId> for re-encumber
    * def ledgerId = <ledgerId>

    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(ledgerId)",
      "ledgerStatus": "Active",
      "name": "#(ledgerId)",
      "code": "#(ledgerId)",
      "fiscalYearOneId":"#(fromFiscalYearId)",
      "restrictEncumbrance": <restrictEncumbrance>
    }
    """
    When method POST
    Then status 201

    Examples:
      | ledgerId                    | restrictEncumbrance |
      | oneTimeRolloverLedger       | false               |
      | ongoingRolloverLedger       | true                |
      | subscriptionRollover        | true                |
      | noRolloverLedger            | false               |


  Scenario Outline: prepare finances for rollover with <rolloverId>
    * def rolloverId = <rolloverId>
    * def ledgerId = <ledgerId>

    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": false,
        "budgetsRollover": [
        ],
        "encumbrancesRollover": [
          {
            "orderType": <orderType>,
            "basedOn": <basedOn>,
            "increaseBy": <increaseBy>
          }
        ]
      }
    """

    Examples:
      | rolloverId           | ledgerId              | orderType              | basedOn     | increaseBy |
      | oneTimeRollover      | oneTimeRolloverLedger | 'One-time'             | 'Remaining' | 10         |
      | ongoingRollover      | ongoingRolloverLedger | 'Ongoing'              | 'Expended'  | 0          |
      | subscriptionRollover | subscriptionRollover  | 'Ongoing-Subscription' | 'Expended'  | 20         |

  Scenario Outline: prepare finances for funds with <fundId>

    * def fundId = <fundId>
    * def ledgerId = <ledgerId>

    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(fundId)",
      "code": "#(fundId)",
      "description": "Fund for re-encumber API Tests",
      "externalAccountNo": "#(fundId)",
      "fundStatus": "Active",
      "ledgerId": "#(ledgerId)",
      "name": "Fund for re-encumber API Tests"
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId                       | ledgerId              |
      | notRestrictedFundZeroAmount  | oneTimeRolloverLedger |
      | restrictedFundEnoughMoney    | ongoingRolloverLedger |
      | restrictedFundNotEnoughMoney | subscriptionRollover  |
      | noRolloverFund               | noRolloverLedger      |

  Scenario Outline: prepare finances for budget with <budgetId>

    * def fundId = <fundId>
    * def budgetId = <budgetId>
    * def fiscalYearId = <fiscalYearId>

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(budgetId)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": <allocated>,
      "allowableEncumbrance": <allowableEncumbrance>,
      "allowableExpenditure": 100.0
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId                       | budgetId                       | fiscalYearId     | allocated | allowableEncumbrance |
      | notRestrictedFundZeroAmount  | fromBudget2                    | fromFiscalYearId | 1000000   | 100                  |
      | restrictedFundEnoughMoney    | fromBudget4                    | fromFiscalYearId | 1000000   | 100                  |
      | restrictedFundNotEnoughMoney | fromBudget6                    | fromFiscalYearId | 1000000   | 100                  |
      | notRestrictedFundZeroAmount  | notRestrictedBudgetZeroAmount  | toFiscalYearId   | 0         | null                 |
      | restrictedFundEnoughMoney    | restrictedBudgetEnoughMoney    | toFiscalYearId   | 1000000   | 150                  |
      | restrictedFundNotEnoughMoney | restrictedBudgetNotEnoughMoney | toFiscalYearId   | 1000      | 100                  |
      | noRolloverFund               | fromBudget7                    | fromFiscalYearId | 100000    | 100                  |
      | noRolloverFund               | noRolloverBudget               | toFiscalYearId   | 100000    | 100                  |


  Scenario Outline: prepare order with orderId <orderId>
    * def orderId = <orderId>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>} : null

    Given path 'orders-storage/purchase-orders'
    And request
    """
    {
      "id": '#(orderId)',
      "vendor": '#(globalVendorId)',
      "workflowStatus": "Open",
      "orderType": <orderType>,
      "reEncumber": true,
      "ongoing": #(ongoing)
    }
    """
    When method POST
    Then status 201

    Examples:
      | orderId                 | orderType  | subscription |
      | successOneLedgerOrder   | 'One-Time' | null         |
      | successTwoLedgersOrder  | 'One-Time' | null         |
      | failedTwoLedgersOrder   | 'Ongoing'  | false        |
      | noFunOrder              | 'Ongoing'  | false        |
      | adjustCostOrder         | 'Ongoing'  | true         |
      | notEnoughMoneyOrder     | 'Ongoing'  | true         |

  Scenario Outline: prepare order lines with orderLineId <orderLineId>
    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fund1Id = <fund1Id>
    * def fund2Id = <fund2Id>
    * def encumbrance1Id = <encumbrance1Id>
    * def encumbrance2Id = <encumbrance2Id>
    * def fundDistributions = [{"fundId": "#(fund1Id)", "encumbrance": "#(encumbrance1Id)", "distributionType": "percentage", "value": <value1>}]
    * set fundDistributions[1] = #(fund2Id) == null ? null : {"fundId": "#(fund2Id)", "encumbrance": "#(encumbrance2Id)", "distributionType": "percentage", "value": <value2>}

    Given path 'orders-storage/po-lines'
    And request
    """
    {
      "id": "#(poLineId)",
      "acquisitionMethod": "Purchase",
      "cost": {
        "listUnitPrice": "<amount>",
        "quantityPhysical": 1,
        "currency": "USD"
      },
      "fundDistribution": #(fundDistributions),
      "orderFormat": "Physical Resource",
      "physical": {
        "createInventory": "None"
      },
      "purchaseOrderId": "#(orderId)",
      "source": "User",
      "titleOrPackage": "#(poLineId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | poLineId              | orderId                | fund1Id                      | encumbrance1Id        | value1 | fund2Id                   | encumbrance2Id        | value2 | amount |
      | successOneLedgerLine  | successOneLedgerOrder  | notRestrictedFundZeroAmount  | successOneLedgerEnc   | 100    | null                      | null                  | null   | 100    |
      | successTwoLedgersLine | successTwoLedgersOrder | notRestrictedFundZeroAmount  | successTwoLedgersEnc1 | 50     | restrictedFundEnoughMoney | successTwoLedgersEnc2 | 50     | 350    |
      | failedTwoLedgersLine1 | failedTwoLedgersOrder  | restrictedFundEnoughMoney    | failedTwoLedgersEnc1  | 100    | null                      | null                  | null   | 1000   |
      | failedTwoLedgersLine2 | failedTwoLedgersOrder  | noRolloverFund               | failedTwoLedgersEnc2  | 100    | null                      | null                  | null   | 500    |
      | noFunLine             | noFunOrder             | nonExistentFund              | nonExistentEnc        | 100    | null                      | null                  | null   | 100    |
      | adjustCostLine        | adjustCostOrder        | restrictedFundNotEnoughMoney | adjustCostEncFrom     | 100    | null                      | null                  | null   | 5000   |
      | notEnoughMoneyLine    | notEnoughMoneyOrder    | restrictedFundNotEnoughMoney | notEnoughMoneyEnc     | 100    | null                      | null                  | null   | 4000   |

  Scenario Outline: prepare finances for orders transaction summary with <orderId>

    * def orderId = <orderId>

    Given path 'finance-storage/order-transaction-summaries'
    And request
    """
    {
      "id": "#(orderId)",
      "numTransactions": <numTransactions>
    }
    """

    Examples:
      | orderId                | numTransactions |
      | successOneLedgerOrder  | 1               |
      | successTwoLedgersOrder | 2               |
      | failedTwoLedgersOrder  | 2               |
      | adjustCostOrder        | 2               |
      | notEnoughMoneyOrder    | 1               |

  Scenario Outline: prepare finance for transactions with <transactionId>
    * def transactionId = <transactionId>
    * def fiscalYearId = <fiscalYearId>
    * def fromFundId = <fromFundId>
    * def orderId = <orderId>
    * def lineId = <lineId>

    Given path 'finance-storage/transactions'
    And request
    """
      {
        "id": "#(transactionId)",
        "amount": <amount>,
        "currency": "USD",
        "description": "Rollover test",
        "fiscalYearId": "#(fiscalYearId)",
        "source": "PoLine",
        "fromFundId": "#(fromFundId)",
        "transactionType": "Encumbrance",
        "encumbrance" :
        {
          "initialAmountEncumbered": <amount> + <expended>,
          "amountExpended": <expended>,
          "status": "Unreleased",
          "orderStatus": 'Open',
          "orderType": 'Ongoing',
          "subscription": true,
          "reEncumber": true,
          "sourcePurchaseOrderId": '#(orderId)',
          "sourcePoLineId": '#(lineId)'
        }
      }
    """
    When method POST
    Then status 201

    Examples:
      | transactionId         | fromFundId                   | fiscalYearId     | orderId                | lineId                | amount | expended |
      | successOneLedgerEnc   | notRestrictedFundZeroAmount  | fromFiscalYearId | successOneLedgerOrder  | successOneLedgerLine  | 100    | 0        |
      | successTwoLedgersEnc1 | notRestrictedFundZeroAmount  | fromFiscalYearId | successTwoLedgersOrder | successTwoLedgersLine | 175    | 0        |
      | successTwoLedgersEnc2 | restrictedFundEnoughMoney    | fromFiscalYearId | successTwoLedgersOrder | successTwoLedgersLine | 175    | 0        |
      | failedTwoLedgersEnc1  | restrictedFundEnoughMoney    | fromFiscalYearId | failedTwoLedgersOrder  | failedTwoLedgersLine1 | 300    | 700      |
      | failedTwoLedgersEnc2  | noRolloverFund               | fromFiscalYearId | failedTwoLedgersOrder  | failedTwoLedgersLine2 | 0      | 500      |
      | adjustCostEncFrom     | restrictedFundNotEnoughMoney | fromFiscalYearId | adjustCostOrder        | adjustCostLine        | 4500   | 500      |
      | adjustCostEncTo       | restrictedFundNotEnoughMoney | toFiscalYearId   | adjustCostOrder        | adjustCostLine        | 600    | 0        |
      | notEnoughMoneyEnc     | restrictedFundNotEnoughMoney | fromFiscalYearId | notEnoughMoneyOrder    | notEnoughMoneyLine    | 0      | 4000     |

  Scenario Outline: create rollover errors with rolloverId <rolloverId> for re-encumber

    * def rolloverId = <rolloverId>
    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And request
    """
      {
        "ledgerRolloverId": "#(rolloverId)",
        "errorType": "Order",
        "failedAction": "Create Encumbrance",
        "errorMessage": "Not enough money available in the Fund to create encumbrance",
        "details": {
          "purchaseOrderId": "#(orderId)",
          "poLineId": "#(poLineId)",
          "amount": 1346.11,
          "fundId": "#(fundId)"
        }
      }
    """
    When method POST
    Then status 201

    Examples:
      | rolloverId            | orderId                | poLineId              | fundId                       |
      | oneTimeRollover       | successOneLedgerOrder  | successOneLedgerLine  | notRestrictedFundZeroAmount  |
      | ongoingRolloverLedger | successTwoLedgersOrder | successTwoLedgersLine | restrictedFundEnoughMoney    |
      | ongoingRolloverLedger | failedTwoLedgersOrder  | failedTwoLedgersLine1 | restrictedFundEnoughMoney    |
      | subscriptionRollover  | notEnoughMoneyOrder    | notEnoughMoneyLine    | restrictedFundNotEnoughMoney |

  Scenario Outline: re-encumber orders with orderId <orderId>

    * def orderId = <orderId>

    Given path 'orders/composite-orders', {id}, 're-encumber'
    When method POST
    Then status <status>
    * if (<httpCode> != 204) karate.match(<errorCode>, response.errors[0].code)

    Examples:
      | orderId                 | errorCode              | status |
      | successOneLedgerOrder   | null                   | 204    |
      | successTwoLedgersOrder  | null                   | 204    |
      | failedTwoLedgersOrder   | 'rolloverNotCompleted' | 400    |
      | noFunOrder              | 'fundsNotFound'        | 400    |
      | adjustCostOrder         | null                   | 204    |
      | notEnoughMoneyOrder     | 'fundCannotBePaid'     | 400    |


  Scenario Outline: check encumbrances and orderLines after re-encumber

    * def poLineId = <poLineId>
    * def encumbrance1Id = <encumbrance1Id>
    * def encumbrance2Id = <encumbrance2Id>

    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId + ' AND fiscalYearId==' + toFiscalYearId
    When method GET
    Then status 200
    * match $.totalRecords == <number>
    * match number > 0 ? $.transactions[0].amount == <amount> : $.transactions[0] == #null
    * match number > 0 ? $.transactions[0].encumbrance.initialAmountEncumbered == <amount> : $.transactions[0] == #null
    * def newEncumbrance = number > 0 ? $.transactions[0].id : null

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * match $.fundDistribution[0].encumbrance == encumbrance1Id
    * match encumbrance2Id == null ? true : $.fundDistribution[1].encumbrance == encumbrance2Id
    * match $.cost.poLineEstimatedPrice == <cost>

    Examples:
      | poLineId              | encumbrance1Id        | encumbrance2Id        | cost   | amount | number |
      | successOneLedgerLine  | newEncumbrance        | null                  | 100    | 100    | 1      |
      | successTwoLedgersLine | newEncumbrance        | successTwoLedgersEnc2 | 350    |        | 1      |
      | failedTwoLedgersLine1 | failedTwoLedgersEnc1  | null                  | 1000   |        | 0      |
      | failedTwoLedgersLine2 | failedTwoLedgersEnc2  | null                  | 500    |        | 0      |
      | noFunLine             | nonExistentEnc        | null                  | 100    |        | 0      |
      | adjustCostLine        | adjustCostEncTo       | null                  | 5000   |        | 1      |
      | notEnoughMoneyLine    | notEnoughMoneyEnc     | null                  | 4000   |        | 0      |


  Scenario Outline: check rollover errors after re-encumbrance

    * def rolloverId = <rolloverId>
    * def orderId = <orderId>

    Given path 'finance/ledger-rollovers-errors'
    And param query = "ledgerRolloverId==" + rolloverId + " AND details.purchaseOrderId==" + orderId
    When method GET
    Then status 200
    * match $.totalRecords == <number>

    Examples:
      | rolloverId            | orderId                | number |
      | oneTimeRollover       | successOneLedgerOrder  | 0      |
      | ongoingRolloverLedger | successTwoLedgersOrder | 0      |
      | ongoingRolloverLedger | failedTwoLedgersOrder  | 1      |
      | subscriptionRollover  | notEnoughMoneyOrder    | 1      |

