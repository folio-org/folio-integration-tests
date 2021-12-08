@parallel=false
Feature: Check re-encumber works correctly

  Background:
    * url baseUrl
    # uncomment below line for development
    # * callonce dev {tenant: 'test_orders12'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def fromFiscalYearId = callonce uuid1
    * def toFiscalYearId = callonce uuid2

    * def oneTimeOngoingRolloverLedger = callonce uuid3
    * def ongoingRolloverLedger = callonce uuid4
    * def subscriptionRollover = callonce uuid5
    * def noRolloverLedger = callonce uuid6
    * def initialAmountOngoingRolloverLedger = callonce uuid42

    * def oneTimeOngoingRollover = callonce uuid7
    * def ongoingRollover = callonce uuid8
    * def subscriptionRollover = callonce uuid9
    * def initialAmountOngoingRollover = callonce uuid43

    * def notRestrictedFundZeroAmount = callonce uuid10
    * def restrictedFundEnoughMoney = callonce uuid11
    * def restrictedFundNotEnoughMoney = callonce uuid12
    * def noRolloverFund = callonce uuid13
    * def nonExistentFund = callonce uuid14
    * def initialAmountEncumberedFund = callonce uuid44

    * def successOneLedgerOrder = callonce uuid15
    * def successTwoLedgersOrder = callonce uuid16
    * def failedTwoLedgersOrder = callonce uuid17
    * def noFunOrder = callonce uuid18
    * def adjustCostOrder = callonce uuid19
    * def notEnoughMoneyOrder = callonce uuid20
    * def successInitialAmountOrder = callonce uuid45

    * def successOneLedgerLine = callonce uuid21
    * def successTwoLedgersLine = callonce uuid22
    * def failedTwoLedgersLine1 = callonce uuid23
    * def failedTwoLedgersLine2 = callonce uuid24
    * def noFunLine = callonce uuid25
    * def adjustCostLine = callonce uuid26
    * def notEnoughMoneyLine = callonce uuid27
    * def successInitialAmountLine = callonce uuid46

    * def successOneLedgerEnc = callonce uuid28
    * def successTwoLedgersEnc1 = callonce uuid29
    * def successTwoLedgersEnc2 = callonce uuid30
    * def failedTwoLedgersEnc1 = callonce uuid31
    * def failedTwoLedgersEnc2 = callonce uuid32
    * def adjustCostEncFrom = callonce uuid33
    * def adjustCostEncTo = callonce uuid34
    * def notEnoughMoneyEnc = callonce uuid35
    * def nonExistentEnc = callonce uuid36
    * def successInitialAmountEnc = callonce uuid47

    * def missingPennyOrder = callonce uuid37
    * def missingPennyLine = callonce uuid38

    * def missingPennyEnc1 = callonce uuid39
    * def missingPennyEnc2 = callonce uuid40

    * def notRestrictedFund = callonce uuid41


    * def codePrefix = callonce random_string
    * def toYear = callonce getCurrentYear
    * def fromYear = parseInt(toYear) -1



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
      | ledgerId                           | restrictEncumbrance |
      | oneTimeOngoingRolloverLedger       | false               |
      | ongoingRolloverLedger              | true                |
      | subscriptionRollover               | true                |
      | noRolloverLedger                   | false               |
      | initialAmountOngoingRolloverLedger | true                |

  Scenario Outline: prepare finances for rollover with <rolloverId>
    * def rolloverId = <rolloverId>
    * def ledgerId = <ledgerId>
    * def oneTime = {"orderType": 'One-time', "basedOn": <basedOn>, "increaseBy": <increaseBy>}
    * def ongoing = {"orderType": 'Ongoing', "basedOn": <basedOn>, "increaseBy": <increaseBy>}
    * def subscription = {"orderType": 'Ongoing-Subscription', "basedOn": <basedOn>, "increaseBy": <increaseBy>}
    * def initialAmountOngoing = {"orderType": 'Ongoing', "basedOn": <basedOn>, "increaseBy": <increaseBy>}

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
        "encumbrancesRollover": <encumbrancesRollover>
      }
    """
    When method POST
    Then status 201

    Examples:
      | rolloverId                  | ledgerId                          | encumbrancesRollover      | basedOn          | increaseBy |
      | oneTimeOngoingRollover      | oneTimeOngoingRolloverLedger      | [#(oneTime), #(ongoing)]  | 'Remaining'      | 10         |
      | ongoingRollover             | ongoingRolloverLedger             | [#(oneTime)]              | 'Expended'       | 0          |
      | subscriptionRollover        | subscriptionRollover              | [#(subscription)]         | 'Expended'       | 20         |
      | initialAmountOngoingRollover| initialAmountOngoingRolloverLedger| [#(initialAmountOngoing)] | 'InitialAmount'  | 0          |

  Scenario Outline: prepare finances for funds with <fundId>
    * configure headers = headersAdmin
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
      | fundId                       | ledgerId                           |
      | notRestrictedFundZeroAmount  | oneTimeOngoingRolloverLedger       |
      | notRestrictedFund            | oneTimeOngoingRolloverLedger       |
      | restrictedFundEnoughMoney    | ongoingRolloverLedger              |
      | restrictedFundNotEnoughMoney | subscriptionRollover               |
      | noRolloverFund               | noRolloverLedger                   |
      | initialAmountEncumberedFund  | initialAmountOngoingRolloverLedger |

  Scenario Outline: prepare finances for budget with <fundId> and <fiscalYearId>

    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>

    Given path 'finance/budgets'
    And request
    """
    {
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(fundId + fiscalYearId)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": <allocated>,
      "allowableEncumbrance": <allowableEncumbrance>,
      "allowableExpenditure": 100.0
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId                       | fiscalYearId     | allocated | allowableEncumbrance |
      | notRestrictedFundZeroAmount  | fromFiscalYearId | 1000000   | 100                  |
      | restrictedFundEnoughMoney    | fromFiscalYearId | 1000000   | 100                  |
      | restrictedFundNotEnoughMoney | fromFiscalYearId | 1000000   | 100                  |
      | notRestrictedFundZeroAmount  | toFiscalYearId   | 0         | null                 |
      | restrictedFundEnoughMoney    | toFiscalYearId   | 1000000   | 150                  |
      | restrictedFundNotEnoughMoney | toFiscalYearId   | 1000      | 100                  |
      | noRolloverFund               | fromFiscalYearId | 100000    | 100                  |
      | noRolloverFund               | toFiscalYearId   | 100000    | 100                  |
      | notRestrictedFund            | fromFiscalYearId | 100000    | null                 |
      | notRestrictedFund            | toFiscalYearId   | 100000    | null                 |
      | initialAmountEncumberedFund  | fromFiscalYearId | 1000000   | 100                  |
      | initialAmountEncumberedFund  | toFiscalYearId   | 1000000   | 150                  |


  Scenario Outline: prepare order with orderId <orderId>
    * def orderId = <orderId>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>} : null

    * configure headers = headersAdmin
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
      | orderId                    | orderType  | subscription |
      | successOneLedgerOrder      | 'One-Time' | null         |
      | successTwoLedgersOrder     | 'One-Time' | null         |
      | failedTwoLedgersOrder      | 'Ongoing'  | false        |
      | noFunOrder                 | 'Ongoing'  | false        |
      | adjustCostOrder            | 'Ongoing'  | true         |
      | notEnoughMoneyOrder        | 'Ongoing'  | true         |
      | missingPennyOrder          | 'One-Time' | null         |
      | successInitialAmountOrder  | 'Ongoing'  | null         |

  Scenario Outline: prepare order lines with orderLineId <poLineId>
    * configure headers = headersAdmin
    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fund1Id = <fund1Id>
    * def fund2Id = <fund2Id>
    * def encumbrance1Id = <encumbrance1Id>
    * def encumbrance2Id = <encumbrance2Id>
    * def fundDistributions = [{"fundId": "#(fund1Id)", "encumbrance": "#(encumbrance1Id)", "distributionType": "percentage", "value": <value1>}]
    * def void = fund2Id == null ? null : karate.appendTo(fundDistributions, {"fundId": fund2Id, "encumbrance": encumbrance2Id, "distributionType": "percentage", "value": <value2>})

    Given path 'orders-storage/po-lines'
    And request
    """
    {
      "id": "#(poLineId)",
      "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
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
      | poLineId                  | orderId                     | fund1Id                      | encumbrance1Id           | value1 | fund2Id                   | encumbrance2Id        | value2 | amount |
      | successOneLedgerLine      | successOneLedgerOrder       | notRestrictedFundZeroAmount  | successOneLedgerEnc      | 100    | null                      | null                  | null   | 100    |
      | successTwoLedgersLine     | successTwoLedgersOrder      | notRestrictedFundZeroAmount  | successTwoLedgersEnc1    | 50     | restrictedFundEnoughMoney | successTwoLedgersEnc2 | 50     | 350    |
      | failedTwoLedgersLine1     | failedTwoLedgersOrder       | restrictedFundEnoughMoney    | failedTwoLedgersEnc1     | 100    | null                      | null                  | null   | 1000   |
      | failedTwoLedgersLine2     | failedTwoLedgersOrder       | noRolloverFund               | failedTwoLedgersEnc2     | 100    | null                      | null                  | null   | 500    |
      | noFunLine                 | noFunOrder                  | nonExistentFund              | nonExistentEnc           | 100    | null                      | null                  | null   | 100    |
      | adjustCostLine            | adjustCostOrder             | restrictedFundNotEnoughMoney | adjustCostEncFrom        | 100    | null                      | null                  | null   | 5000   |
      | notEnoughMoneyLine        | notEnoughMoneyOrder         | restrictedFundNotEnoughMoney | notEnoughMoneyEnc        | 100    | null                      | null                  | null   | 4000   |
      | missingPennyLine          | missingPennyOrder           | notRestrictedFundZeroAmount  | missingPennyEnc1         | 50     | notRestrictedFund         | missingPennyEnc2      | 50     | 1.1    |
      | successInitialAmountLine  | successInitialAmountOrder   | initialAmountEncumberedFund  | successInitialAmountEnc  | 100    | null                      | null                  | null   | 100    |

  Scenario Outline: prepare finances for orders transaction summary with <orderId>
    * configure headers = headersAdmin
    * def orderId = <orderId>

    Given path 'finance-storage/order-transaction-summaries'
    And request
    """
    {
      "id": "#(orderId)",
      "numTransactions": <numTransactions>
    }
    """
    When method POST
    Then status 201

    Examples:
      | orderId                   | numTransactions |
      | successOneLedgerOrder     | 1               |
      | successTwoLedgersOrder    | 2               |
      | failedTwoLedgersOrder     | 2               |
      | adjustCostOrder           | 2               |
      | notEnoughMoneyOrder       | 1               |
      | missingPennyOrder         | 2               |
      | successInitialAmountOrder | 1               |

  Scenario Outline: prepare finances for transactions with <transactionId>
    * configure headers = headersAdmin
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
          "initialAmountEncumbered": #(<amount> + <expended>),
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
      | transactionId             | fromFundId                   | fiscalYearId     | orderId                   | lineId                    | amount | expended |
      | successOneLedgerEnc       | notRestrictedFundZeroAmount  | fromFiscalYearId | successOneLedgerOrder     | successOneLedgerLine      | 100    | 0        |
      | successTwoLedgersEnc1     | notRestrictedFundZeroAmount  | fromFiscalYearId | successTwoLedgersOrder    | successTwoLedgersLine     | 175    | 0        |
      | successTwoLedgersEnc2     | restrictedFundEnoughMoney    | fromFiscalYearId | successTwoLedgersOrder    | successTwoLedgersLine     | 175    | 0        |
      | failedTwoLedgersEnc1      | restrictedFundEnoughMoney    | fromFiscalYearId | failedTwoLedgersOrder     | failedTwoLedgersLine1     | 300    | 700      |
      | failedTwoLedgersEnc2      | noRolloverFund               | fromFiscalYearId | failedTwoLedgersOrder     | failedTwoLedgersLine2     | 0      | 500      |
      | adjustCostEncFrom         | restrictedFundNotEnoughMoney | fromFiscalYearId | adjustCostOrder           | adjustCostLine            | 4500   | 500      |
      | adjustCostEncTo           | restrictedFundNotEnoughMoney | toFiscalYearId   | adjustCostOrder           | adjustCostLine            | 600    | 0        |
      | notEnoughMoneyEnc         | restrictedFundNotEnoughMoney | fromFiscalYearId | notEnoughMoneyOrder       | notEnoughMoneyLine        | 0      | 4000     |
      | missingPennyEnc1          | notRestrictedFundZeroAmount  | fromFiscalYearId | missingPennyOrder         | missingPennyLine          | 0.55   | 0        |
      | missingPennyEnc2          | notRestrictedFund            | fromFiscalYearId | missingPennyOrder         | missingPennyLine          | 0.55   | 0        |
      | successInitialAmountEnc   | initialAmountEncumberedFund  | fromFiscalYearId | successInitialAmountOrder | successInitialAmountLine  | 100    | 0        |


  Scenario Outline: create rollover errors with rolloverId <rolloverId> for re-encumber
    * configure headers = headersAdmin

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
      | rolloverId                   | orderId                   | poLineId                  | fundId                       |
      | oneTimeOngoingRollover       | successOneLedgerOrder     | successOneLedgerLine      | notRestrictedFundZeroAmount  |
      | ongoingRollover              | successTwoLedgersOrder    | successTwoLedgersLine     | restrictedFundEnoughMoney    |
      | ongoingRollover              | failedTwoLedgersOrder     | failedTwoLedgersLine1     | restrictedFundEnoughMoney    |
      | subscriptionRollover         | notEnoughMoneyOrder       | notEnoughMoneyLine        | restrictedFundNotEnoughMoney |
      | initialAmountOngoingRollover | successInitialAmountOrder | successInitialAmountLine  | initialAmountEncumberedFund  |

  Scenario Outline: re-encumber orders with orderId <orderId>
    * configure headers = headersUser

    * def orderId = <orderId>

    Given path 'orders/composite-orders', orderId, 're-encumber'
    And request ""
    When method POST
    Then status <httpCode>
    * if (<httpCode> != 204) karate.match(<errorCode>, response.errors[0].code)

    Examples:
      | orderId                     | errorCode              | httpCode |
      | successOneLedgerOrder       | null                   | 204      |
      | successTwoLedgersOrder      | null                   | 204      |
      | failedTwoLedgersOrder       | 'rolloverNotCompleted' | 400      |
      | noFunOrder                  | 'fundsNotFound'        | 404      |
      | adjustCostOrder             | null                   | 204      |
      | notEnoughMoneyOrder         | 'fundCannotBePaid'     | 422      |
      | missingPennyOrder           | null                   | 204      |
      | successInitialAmountOrder   | null                   | 204      |

  Scenario Outline: check encumbrances and orderLine <poLineId> after re-encumber

    * def poLineId = <poLineId>

    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePoLineId==' + poLineId + ' AND fiscalYearId==' + toFiscalYearId
    When method GET
    Then status 200
    * match $.totalRecords == <number>
    * def newEncumbrance1 = <number> > 0 ? response.transactions[0] : {}
    * def newEncumbrance2 = <number> > 1 ? response.transactions[1] : {}
    * match newEncumbrance1.amount == <amount1>
    * match newEncumbrance2.amount == <amount2>
    * def encumbrance1Id = <encumbrance1Id> == 'newEncumbrance1' ? newEncumbrance1.id : <encumbrance1Id>
    * def encumbrance2Id = <encumbrance2Id> == 'newEncumbrance2' ? newEncumbrance2.id : <encumbrance2Id>

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * match karate.jsonPath(response, "$.fundDistribution[?(@.encumbrance=='"+encumbrance1Id+"')]") == '#[1]'
    * match karate.jsonPath(response, "$.fundDistribution[?(@.encumbrance=='"+encumbrance2Id+"')]") == <encumbrance2Id> ? '#[1]' : '#[0]'
    * match $.cost.fyroAdjustmentAmount == <fyroAdjustmentAmount>

    Examples:
      | poLineId                  | encumbrance1Id        | encumbrance2Id        | fyroAdjustmentAmount | amount1       | amount2       | number |
      | successOneLedgerLine      | 'newEncumbrance1'     | null                  | 10                   | 110           | '#notpresent' | 1      |
      | successTwoLedgersLine     | 'newEncumbrance1'     | 'newEncumbrance2'     | -157.5               | 96.25         | 96.25         | 2      |
      | failedTwoLedgersLine1     | failedTwoLedgersEnc1  | null                  | '#notpresent'        | '#notpresent' | '#notpresent' | 0      |
      | failedTwoLedgersLine2     | failedTwoLedgersEnc2  | null                  | '#notpresent'        | '#notpresent' | '#notpresent' | 0      |
      | noFunLine                 | nonExistentEnc        | null                  | '#notpresent'        | '#notpresent' | '#notpresent' | 0      |
      | adjustCostLine            | adjustCostEncTo       | null                  | -4400                | 600           | '#notpresent' | 1      |
      | notEnoughMoneyLine        | notEnoughMoneyEnc     | null                  | '#notpresent'        | '#notpresent' | '#notpresent' | 0      |
      | missingPennyLine          | 'newEncumbrance1'     | 'newEncumbrance2'     | 0.11                 | 0.6           | 0.61          | 2      |
      | successInitialAmountLine  | 'newEncumbrance1'     | null                  | 0                    | 100           | '#notpresent' | 1      |

  Scenario Outline: check rollover errors after re-encumbrance
    * configure headers = headersAdmin
    * def rolloverId = <rolloverId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And param query = "ledgerRolloverId==" + rolloverId
    When method GET
    Then status 200
    * match $.totalRecords == <number>

    Examples:
      | rolloverId                          | number |
      | oneTimeOngoingRollover              | 0      |
      | ongoingRollover                     | 1      |
      | subscriptionRollover                | 1      |
      | initialAmountOngoingRollover        | 0      |

