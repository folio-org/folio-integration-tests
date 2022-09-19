Feature: Ledger fiscal year rollover issues MODFISTO-309 and MODFISTO-311

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testfinance'}

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

    * def rolloverLedger1 = callonce uuid3
    * def rolloverLedger2 = callonce uuid4
    * def rolloverLedger3 = callonce uuid5
    * def rolloverLedger4 = callonce uuid6

    * def books = callonce uuid7
    * def disks = callonce uuid8

    * def firstHist = callonce uuid9
    * def secondHist = callonce uuid10
    * def thirdHist = callonce uuid11
    * def forthHist = callonce uuid12
    * def fifthHist = callonce uuid13
    * def sixthHist = callonce uuid14
    * def firstHist2022 = callonce uuid17
    * def secondHist2022 = callonce uuid18
    * def thirdHist2022 = callonce uuid19
    * def forthHist2022 = callonce uuid20
    * def fifthHist2022 = callonce uuid21
    * def sixthHist2022 = callonce uuid22


    * def encumberRemaining1 = callonce uuid26
    * def encumberRemaining2 = callonce uuid27
    * def encumberRemaining3 = callonce uuid28
    * def encumberRemaining4 = callonce uuid29
    * def encumberRemaining5 = callonce uuid30
    * def encumberRemaining6 = callonce uuid31
    * def encumberRemaining7 = callonce uuid32
    * def encumberRemaining8 = callonce uuid33
    * def encumberRemainingLine11 = callonce uuid34
    * def encumberRemainingLine21 = callonce uuid35
    * def encumberRemainingLine31 = callonce uuid36
    * def encumberRemainingLine41 = callonce uuid37
    * def encumberRemainingLine12 = callonce uuid38
    * def encumberRemainingLine22 = callonce uuid39
    * def encumberRemainingLine32 = callonce uuid40
    * def encumberRemainingLine42 = callonce uuid41
    * def encumberRemainingLine51 = callonce uuid42
    * def encumberRemainingLine61 = callonce uuid43
    * def encumberRemainingLine71 = callonce uuid44
    * def encumberRemainingLine81 = callonce uuid45
    * def encumberRemainingLine52 = callonce uuid86
    * def encumberRemainingLine62 = callonce uuid87
    * def encumberRemainingLine72 = callonce uuid88
    * def encumberRemainingLine82 = callonce uuid89
    * def encumberRemaining9 = callonce uuid90
    * def encumberRemaining10 = callonce uuid91
    * def encumberRemaining11 = callonce uuid92
    * def encumberRemaining12 = callonce uuid93
    * def encumberRemainingLine091 = callonce uuid94
    * def encumberRemainingLine101 = callonce uuid95
    * def encumberRemainingLine111 = callonce uuid96
    * def encumberRemainingLine121 = callonce uuid97


    * def expendedHigherLine = callonce uuid46
    * def expendedLowerLine = callonce uuid47
    * def orderClosedLine = callonce uuid48
    * def noReEncumberLine = callonce uuid49
    * def crossLedgerLine = callonce uuid50

    * def encumbranceInvoiceId = callonce uuid51
    * def noEncumbranceInvoiceId = callonce uuid52


    * def encumberRemaining2 = callonce uuid53
    * def encumberRemainingLine2 = callonce uuid54

    * def rolloverId1 = callonce uuid58
    * def rolloverId2 = callonce uuid59
    * def rolloverId3 = callonce uuid60
    * def rolloverId4 = callonce uuid61
    * def groupId1 = callonce uuid77
    * def groupId2 = callonce uuid78


    * def iLine1 = callonce uuid71
    * def iLine2 = callonce uuid72
    * def iLine3 = callonce uuid73
    * def iLine4 = callonce uuid74
    * def iLine5 = callonce uuid75
    * def iLine6 = callonce uuid76
    * def iLine7 = callonce uuid77
    * def iLine8 = callonce uuid78
    * def iLine9 = callonce uuid79
    * def iLine10 = callonce uuid80
    * def iLine11 = callonce uuid81
    * def iLine12 = callonce uuid82

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

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
      | ledgerId          |
      | rolloverLedger1   |
      | rolloverLedger2   |
      | rolloverLedger3   |
      | rolloverLedger4   |

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
      | groupId2 |

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
      | fundId     | ledgerId        | fundCode      | fundTypeId | status     |
      | firstHist  | rolloverLedger1 | 'HIST1'       | books      | 'Active'   |
      | secondHist | rolloverLedger2 | 'HIST2'       | books      | 'Active'   |
      | thirdHist  | rolloverLedger2 | 'HIST3'       | null       | 'Active'   |
      | forthHist  | rolloverLedger3 | 'HIST4'       | books      | 'Active'   |
      | fifthHist  | rolloverLedger4 | 'HIST5'       | books      | 'Active'   |
      | sixthHist  | rolloverLedger4 | 'HIST6'       | null       | 'Active'   |

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
      | id               | fundId       | fiscalYearId     | allocated  | allowableExpenditure | allowableEncumbrance | expenseClasses                                            | groups                       |
      | firstHist2022    | firstHist    | fromFiscalYearId | 120        | 200                  | 200                  | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] | ['#(groupId1)']              |
      | secondHist2022   | secondHist   | fromFiscalYearId | 120        | 200                  | 200                  | null                                                      | ['#(groupId1)']              |
      | thirdHist2022    | thirdHist    | fromFiscalYearId | 120        | 200                  | 200                  | null                                                      | ['#(groupId2)']              |
      | forthHist2022    | forthHist    | fromFiscalYearId | 40         | 50                   | 50                   | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] | ['#(groupId2)']              |
      | fifthHist2022    | fifthHist    | fromFiscalYearId | 120        | 200                  | 200                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |
      | sixthHist2022    | sixthHist    | fromFiscalYearId | 120        | 200                  | 200                  | [#(globalPrnExpenseClassId)]                              | ['#(groupId2)']              |

  Scenario Outline: Create open orders with 2 lines distribution
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId1 = <poLineId1>
    * def poLineId2 = <poLineId2>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2022-12-12T00:00:00.000+00:00"} : null

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
          "id" : "#(poLineId1)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(firstHist)",
              "expenseClassId": "#(globalElecExpenseClassId)",
              "distributionType": "percentage",
              "value": 50
            },
            {
              "fundId": "#(secondHist)",
              "distributionType": "percentage",
              "value": 50
            }
          ],
          "orderFormat": "Physical Resource",
          "physical": {
            "createInventory": "None"
          },
          "purchaseOrderId": "#(orderId)",
          "source": "User",
          "titleOrPackage": "#(poLineId)"
        },
        {
          "id" : "#(poLineId2)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(secondHist)",
              "distributionType": "percentage",
              "value": 50
            },
            {
              "fundId": "#(fifthHist)",
              "distributionType": "percentage",
              "value": 50
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
      | orderId            | poLineId1               | poLineId2               | orderType  | subscription | reEncumber | amount |
      | encumberRemaining1 | encumberRemainingLine11 | encumberRemainingLine12 | 'One-Time' | false        | true       | 0      |
      | encumberRemaining2 | encumberRemainingLine21 | encumberRemainingLine22 | 'One-Time' | false        | true       | 10     |
      | encumberRemaining3 | encumberRemainingLine31 | encumberRemainingLine32 | 'Ongoing'  | true         | true       | 0      |
      | encumberRemaining4 | encumberRemainingLine41 | encumberRemainingLine42 | 'Ongoing'  | false        | true       | 10     |

  Scenario Outline: Create open orders with 2 lines distribution
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId1 = <poLineId1>
    * def poLineId2 = <poLineId2>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2022-12-12T00:00:00.000+00:00"} : null

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
          "id" : "#(poLineId1)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(fifthHist)",
              "expenseClassId": "#(globalElecExpenseClassId)",
              "distributionType": "percentage",
              "value": 50
            },
            {
              "fundId": "#(firstHist)",
              "distributionType": "percentage",
              "value": 50
            }
          ],
          "orderFormat": "Physical Resource",
          "physical": {
            "createInventory": "None"
          },
          "purchaseOrderId": "#(orderId)",
          "source": "User",
          "titleOrPackage": "#(poLineId)"
        },
        {
          "id" : "#(poLineId2)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(sixthHist)",
              "distributionType": "percentage",
              "value": 50
            },
            {
              "fundId": "#(fifthHist)",
              "distributionType": "percentage",
              "value": 40
            },
            {
              "fundId": "#(forthHist)",
              "distributionType": "percentage",
              "value": 10
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
      | orderId            | poLineId1               | poLineId2               | orderType  | subscription | reEncumber | amount |
      | encumberRemaining5 | encumberRemainingLine51 | encumberRemainingLine52 | 'One-Time' | true         | true       | 0      |
      | encumberRemaining6 | encumberRemainingLine61 | encumberRemainingLine62 | 'One-Time' | false        | true       | 10     |
      | encumberRemaining7 | encumberRemainingLine71 | encumberRemainingLine72 | 'Ongoing'  | true         | true       | 0      |
      | encumberRemaining8 | encumberRemainingLine81 | encumberRemainingLine82 | 'Ongoing'  | true         | true       | 100    |

  Scenario Outline: Create open orders with 2 lines distribution
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId1 = <poLineId1>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2022-12-12T00:00:00.000+00:00"} : null

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
          "id" : "#(poLineId1)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "<amount>",
            "quantityPhysical": 1,
            "currency": "USD"
          },
          "fundDistribution": [
            {
              "fundId": "#(firstHist)",
              "expenseClassId": "#(globalElecExpenseClassId)",
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
      | orderId             | poLineId1                | orderType  | subscription | reEncumber | amount |
      | encumberRemaining9  | encumberRemainingLine091 | 'One-Time' | false        | true       | 0      |
      | encumberRemaining10 | encumberRemainingLine101 | 'One-Time' | false        | true       | 10     |
      | encumberRemaining11 | encumberRemainingLine111 | 'Ongoing'  | false        | true       | 0      |
      | encumberRemaining12 | encumberRemainingLine121 | 'Ongoing'  | true         | true       | 10     |

  Scenario Outline: prepare invoice-transactions-summary with <invoiceId>, <transactionNum>

    * def invoiceId = <invoiceId>

    Given path 'finance/invoice-transaction-summaries'
    And request
    """
      {
        "id": '#(invoiceId)',
        "numPendingPayments": <transactionNum>,
        "numPaymentsCredits": <transactionNum>
      }

    """
    When method POST
    Then status 201

    Examples:
      | invoiceId              | transactionNum |
      | encumbranceInvoiceId   | 8              |

  Scenario Outline: prepare pending payments with <fromFundId>, <encumbranceId>, <amount>

    * def fromFundId = <fromFundId>
    * def poLineId = <poLineId>
    * def invoiceId = <invoiceId>
    * def invoiceLineId = <invoiceLineId>

    Given path 'finance/transactions'
    And param query = 'fromFundId==' + fromFundId + ' AND encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    * def encumbranceId = karate.sizeOf(response.transactions) > 0 ? response.transactions[0].id :null


    Given path 'finance/pending-payments'
    And request
    """
      {
        "amount": <amount>,
        "currency": "USD",
        "description": "Rollover test payment",
        "fiscalYearId": "#(fromFiscalYearId)",
        "source": "Invoice",
        "fromFundId": "#(fromFundId)",
        "transactionType": "Pending payment",
        "awaitingPayment": {
          "encumbranceId": "#(encumbranceId)",
          "releaseEncumbrance": <release>
        },
        "sourceInvoiceId": "#(invoiceId)",
        "sourceInvoiceLineId": "#(invoiceLineId)"
      }
    """
    When method POST
    Then status 201

    Examples:
      | fromFundId       | poLineId                | amount | release | invoiceId              | invoiceLineId |
      | firstHist        | encumberRemainingLine11 | 10     | false   | encumbranceInvoiceId   | iLine1        |
      | secondHist       | encumberRemainingLine21 | 20     | false   | encumbranceInvoiceId   | iLine2        |
      | thirdHist        | encumberRemainingLine31 | 20     | false   | encumbranceInvoiceId   | iLine3        |
      | firstHist        | encumberRemainingLine41 | 20     | false   | encumbranceInvoiceId   | iLine4        |
      | thirdHist        | encumberRemainingLine22 | 0      | false   | encumbranceInvoiceId   | iLine6        |
      | firstHist        | encumberRemainingLine32 | 10     | false   | encumbranceInvoiceId   | iLine7        |
      | secondHist       | encumberRemainingLine42 | 0      | false   | encumbranceInvoiceId   | iLine8        |

  Scenario Outline: prepare payments with <fromFundId>, <amount>
    * def fromFundId = <fromFundId>
    * def poLineId = <poLineId>
    * def invoiceId = <invoiceId>
    * def invoiceLineId = <invoiceLineId>

    Given path 'finance/transactions'
    And param query = 'fromFundId==' + fromFundId + ' AND encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    * def encumbranceId = karate.sizeOf(response.transactions) > 0 ? response.transactions[0].id :null

    Given path 'finance/payments'
    And request
    """
      {
        "amount": <amount>,
        "currency": "USD",
        "description": "Rollover test payment",
        "fiscalYearId": "#(fromFiscalYearId)",
        "source": "Invoice",
        "fromFundId": "#(fromFundId)",
        "transactionType": "Payment",
        "paymentEncumbranceId": "#(encumbranceId)",
        "sourceInvoiceId": "#(invoiceId)",
        "sourceInvoiceLineId": "#(invoiceLineId)"
      }
    """
    When method POST
    Then status 201

    Examples:
      | fromFundId       | poLineId                | amount  | invoiceId              | invoiceLineId |
      | firstHist        | encumberRemainingLine11 | 10      | encumbranceInvoiceId   | iLine1        |


  Scenario: Start rollover for ledger 1
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId1)",
        "ledgerId": "#(rolloverLedger1)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": false,
        "restrictExpenditures": false,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": false,
            "adjustAllocation": 10,
            "rolloverAvailable": true,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Expended",
            "increaseBy": 5
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Expended",
            "increaseBy": 5
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
    * call pause 1000

  Scenario: Start rollover for ledger 2
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId2)",
        "ledgerId": "#(rolloverLedger2)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": false,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": false,
            "adjustAllocation": 10,
            "rolloverAvailable": true,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "InitialAmount",
            "increaseBy": 5
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Expended",
            "increaseBy": 5
          },
          {
            "orderType": "One-time",
            "basedOn": "InitialAmount",
            "increaseBy": 0
          }
        ]
      }
    """
    When method POST
    Then status 201
    * call pause 1000

  Scenario: Start rollover for ledger 3
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId3)",
        "ledgerId": "#(rolloverLedger3)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "setAllowances": true,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": false,
            "adjustAllocation": 10,
            "rolloverAvailable": true,
            "setAllowances": true,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Expended",
            "increaseBy": 5
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Expended",
            "increaseBy": 5
          },
          {
            "orderType": "One-time",
            "basedOn": "InitialAmount",
            "increaseBy": 10
          }
        ]
      }
    """
    When method POST
    Then status 201
    * call pause 1000

  Scenario: Start rollover for ledger 4
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId4)",
        "ledgerId": "#(rolloverLedger4)",
        "fromFiscalYearId": "#(fromFiscalYearId)",
        "toFiscalYearId": "#(toFiscalYearId)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": true,
            "adjustAllocation": 10,
            "rolloverAvailable": true,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Remaining",
            "increaseBy": 10
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Remaining",
            "increaseBy": 10
          },
          {
            "orderType": "One-time",
            "basedOn": "Remaining",
            "increaseBy": 10
          }
        ]
      }
    """
    When method POST
    Then status 201
    * call pause 1000

  Scenario: Old budgets
    * print 'Check old budgets'
    Given path 'finance/budgets'
    And param query = 'fiscalYearId==' + fromFiscalYearId
    When method GET
    Then status 200
    And match $.totalRecords == 6

  Scenario: New budgets were created
    * print 'Check new budgets'
    Given path 'finance/budgets'
    And param query = 'fiscalYearId==' + toFiscalYearId
    When method GET
    Then status 200
    And match $.totalRecords == 6

  Scenario: Check rollover transfers after rollovers

    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND transactionType=="Rollover transfer"'
    When method GET
    Then status 200
    And match $.totalRecords == 6

  Scenario Outline: Check rollover transfers by fund
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND transactionType=="Rollover transfer"'
    When method GET
    Then status 200
    And match $.totalRecords == 1

    Examples:
      | fundId     |
      | firstHist  |
      | secondHist |
      | thirdHist  |
      | forthHist  |
      | fifthHist  |
      | sixthHist  |
