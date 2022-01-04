Feature: Ledger fiscal year rollover pol and system currencies are different

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_finance1'}
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
    * def noRolloverLedger = callonce uuid4

    * def books = callonce uuid5
    * def serials = callonce uuid6
    * def gifts = callonce uuid7
    * def monographs = callonce uuid8

    * def hist = callonce uuid9
    * def latin = callonce uuid10
    * def law = callonce uuid11
    * def science = callonce uuid12
    * def giftsFund = callonce uuid13
    * def africanHist = callonce uuid14
    * def rollHist = callonce uuid15
    * def euroHist = callonce uuid16

    * def hist2020 = callonce uuid17
    * def latin2020 = callonce uuid18
    * def law2020 = callonce uuid19
    * def science2020 = callonce uuid20
    * def gift2020 = callonce uuid21
    * def africanHist2020 = callonce uuid22
    * def africanHist2021 = callonce uuid23
    * def rollHist2020 = callonce uuid24
    * def euroHist2020 = callonce uuid25

    * def encumberRemaining = callonce uuid26
    * def expendedHigher = callonce uuid27
    * def expendedLower = callonce uuid28
    * def orderClosed = callonce uuid29
    * def noReEncumber = callonce uuid30
    * def crossLedger = callonce uuid31

    * def encumberRemainingLine = callonce uuid32
    * def expendedHigherLine = callonce uuid33
    * def expendedLowerLine = callonce uuid34
    * def orderClosedLine = callonce uuid35
    * def noReEncumberLine = callonce uuid36
    * def crossLedgerLine = callonce uuid37

    * def encumbranceInvoiceId = callonce uuid46
    * def noEncumbranceInvoiceId = callonce uuid47

    * def iLine1 = callonce uuid48
    * def iLine2 = callonce uuid49
    * def iLine3 = callonce uuid50
    * def iLine4 = callonce uuid51
    * def iLine5 = callonce uuid52
    * def iLine6 = callonce uuid53
    * def iLine7 = callonce uuid54
    * def iLine8 = callonce uuid55
    * def iLine9 = callonce uuid56
    * def iLine10 = callonce uuid57
    * def iLine11 = callonce uuid58
    * def iLine12 = callonce uuid68

    * def rolloverId = callonce uuid59
    * def groupId1 = callonce uuid60
    * def groupId2 = callonce uuid61

    * def inactiveFund = callonce uuid62
    * def inactiveFund2020 = callonce uuid63
    * def noBudgetOrder = callonce uuid64
    * def noBudgetLine = callonce uuid65

    * def multiFundOrder = callonce uuid66
    * def multiFundLine = callonce uuid67


    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

    * def libFund1 = callonce uuid66
    * def libFund2 = callonce uuid67
    * def libFund3 = callonce uuid68

    * def libBud1 = callonce uuid69
    * def libBud2 = callonce uuid70
    * def libBud3 = callonce uuid71

    * def libOrder = callonce uuid72
    * def libOrderLine = callonce uuid73
    * def libOrderLine2 = callonce uuid74
    * def iLine12 = callonce uuid75
    * def iLine13 = callonce uuid76
    * def iLine14 = callonce uuid77
    * def iLine15 = callonce uuid78
    * def iLine16 = callonce uuid79

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
      | serials    | 'Serials'    |
      | gifts      | 'Gifts'      |
      | monographs | 'Monographs' |

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
      | fundId       | ledgerId         | fundCode     | fundTypeId | status     |
      | hist         | rolloverLedger   | 'HIST'       | null       | 'Active'   |
      | latin        | rolloverLedger   | 'LATIN'      | books      | 'Active'   |
      | law          | rolloverLedger   | 'LAW'        | books      | 'Active'   |
      | science      | rolloverLedger   | 'SCIENCE'    | serials    | 'Active'   |
      | giftsFund    | rolloverLedger   | 'GIFT'       | gifts      | 'Active'   |
      | africanHist  | rolloverLedger   | 'AFRICAHIST' | monographs | 'Active'   |
      | rollHist     | rolloverLedger   | 'ROLLHIST'   | books      | 'Active'   |
      | euroHist     | noRolloverLedger | 'EUROHIST'   | null       | 'Active'   |
      | inactiveFund | rolloverLedger   | 'INACTIVE'   | null       | 'Inactive' |
      | libFund1     | rolloverLedger   | 'LIBFUND1'   | books      | 'Active'   |
      | libFund2     | rolloverLedger   | 'LIBFUND2'   | books      | 'Active'   |
      | libFund3     | rolloverLedger   | 'LIBFUND3'   | books      | 'Active'   |

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
      | hist2020         | hist         | fromFiscalYearId | 160       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              |
      | latin2020        | latin        | fromFiscalYearId | 70        | 100                  | 100                  | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] | ['#(groupId2)']              |
      | law2020          | law          | fromFiscalYearId | 80        | 170                  | 160                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)', #(groupId2)] |
      | science2020      | science      | fromFiscalYearId | 110       | 80                   | 90                   | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              |
      | gift2020         | giftsFund    | fromFiscalYearId | 140       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |
      | africanHist2020  | africanHist  | fromFiscalYearId | 50        | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              |
      | africanHist2021  | africanHist  | toFiscalYearId   | 20        | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |
      | rollHist2020     | rollHist     | fromFiscalYearId | 180       | null                 | null                 | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              |
      | euroHist2020     | euroHist     | fromFiscalYearId | 280       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |
      | inactiveFund2020 | inactiveFund | fromFiscalYearId | 500       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              |
      | libBud1          | libFund1     | fromFiscalYearId | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |
      | libBud2          | libFund2     | fromFiscalYearId | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |
      | libBud3          | libFund3     | fromFiscalYearId | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              |

  Scenario: Create transfer to SCIENCE2020 budget
    Given path 'finance/transfers'
    And request
    """
      {
        "amount": 50,
        "currency": "USD",
        "description": "Rollover test transfer",
        "fiscalYearId": "#(fromFiscalYearId)",
        "source": "User",
        "fromFundId": "#(latin)",
        "toFundId": "#(science)",
        "transactionType": "Transfer"
      }
    """
    When method POST
    Then status 201

  Scenario Outline: Create open orders with 1 fund distribution
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2021-12-03T00:00:00.000+00:00"} : null

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
            "exchangeRate": "0.82858",
            "currency": "EUR"
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
      | encumberRemaining | encumberRemainingLine | law          | 'One-Time' | false        | true       | 10     |
      | noBudgetOrder     | noBudgetLine          | inactiveFund | 'One-Time' | false        | true       | 300    |
      | expendedLower     | expendedLowerLine     | law          | 'Ongoing'  | true         | true       | 30     |
      | noReEncumber      | noReEncumberLine      | giftsFund    | 'Ongoing'  | true         | false      | 20     |


  Scenario Outline: Create open orders with 2 fund distributions
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fund1Id = <fund1Id>
    * def fund2Id = <fund2Id>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2021-12-03T00:00:00.000+00:00"} : null
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
            "exchangeRate": "0.82858",
            "currency": "EUR"
          },
          "fundDistribution": [
            {
              "fundId": "#(fund1Id)",
              "distributionType": "percentage",
              "value": 50
            },
            {
              "fundId": "#(fund2Id)",
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
      | orderId        | poLineId           | fund1Id  | fund2Id  | orderType | subscription | reEncumber | amount |
      | expendedHigher | expendedHigherLine | law      | hist     | 'Ongoing' | false        | true       | 20     |
      | crossLedger    | crossLedgerLine    | rollHist | euroHist | 'Ongoing' | true         | true       | 40     |


  Scenario Outline: Create orders with different amount types
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2021-12-03T00:00:00.000+00:00"} : null
    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": '#(orderId)',
      "vendor": '#(globalVendorId)',
      "orderType": <orderType>,
      "reEncumber": <reEncumber>,
      "ongoing": #(ongoing),
    }
    """
    When method POST
    Then status 201

    Examples:
      | orderId  | orderType  | subscription | reEncumber |
      | libOrder | 'One-Time' | false        | true       |

  Scenario Outline: Create open orders with 2 fund distribution and different amount type
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fund = <fund>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2021-12-03T00:00:00.000+00:00"} : null
    * def rq =
    """
    {
      "id": "#(poLineId)",
      "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
      "cost": {
        "listUnitPrice": "<amount>",
        "quantityPhysical": 1,
        "exchangeRate": "0.82858",
        "currency": "EUR"
      },
      "fundDistribution": [],
      "orderFormat": "Physical Resource",
      "physical": {
        "createInventory": "None"
      },
      "purchaseOrderId": "#(orderId)",
      "source": "User",
      "titleOrPackage": "#(poLineId)"
    }
    """
    * set rq.fundDistribution = karate.map(fund, function(fund){return {fundId: fund.id, distributionType: fund.type, value: fund.value}})

    Given path 'orders/order-lines'
    And request rq
    When method POST
    Then status 201

    Examples:
      | orderId  | poLineId      | fund                                                                                                                                                           | orderType  | subscription | amount |
#      | libOrder | libOrderLine  | [{"id":"#(libFund1)", "value":18.41, type:"amount"},{"id": "#(libFund2)", "value":41, type:"percentage"},{"id":"#(libFund3)", "value":41, type:"percentage"}]  | 'One-Time' | false        | 102.26 |
      | libOrder | libOrderLine  | [{"id":"#(libFund1)", "value":51, type:"percentage"},{"id": "#(libFund2)", "value":21, type:"percentage"},{"id":"#(libFund3)", "value":28, type:"percentage"}] | 'One-Time' | false        | 101    |
      | libOrder | libOrderLine2 | [{"id":"#(libFund1)", "value":18, type:"percentage"},{"id": "#(libFund2)", "value":41, type:"percentage"},{"id":"#(libFund3)", "value":41, type:"percentage"}] | 'One-Time' | false        | 102.26 |

  Scenario Outline: Open order
    * configure headers = headersAdmin

    * def orderId = <orderId>
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = response
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

    Examples:
      | orderId  |
      | libOrder |


  Scenario: Create open orders with 3 fund distributions

    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": '#(multiFundOrder)',
      "vendor": '#(globalVendorId)',
      "workflowStatus": "Open",
      "orderType": "Ongoing",
      "reEncumber": true,
      "ongoing" : {
        "interval" : 182,
        "isSubscription" : true,
        "renewalDate" : "2021-12-03T00:00:00.000+00:00"
      },
      "compositePoLines": [
        {
          "id": "#(multiFundLine)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "10",
            "quantityPhysical": 1,
            "exchangeRate": "0.82858",
            "currency": "EUR"
          },
          "fundDistribution": [
            {
              "fundId": "#(rollHist)",
              "distributionType": "percentage",
              "value": 20
            },
            {
              "fundId": "#(giftsFund)",
              "distributionType": "percentage",
              "value": 30
            },
            {
              "fundId": "#(science)",
              "distributionType": "percentage",
              "value": 50
            }
          ],
          "orderFormat": "Physical Resource",
          "physical": {
            "createInventory": "None"
          },
          "purchaseOrderId": "#(multiFundOrder)",
          "source": "User",
          "titleOrPackage": "Multi line"
        }
      ]

    }
    """
    When method POST
    Then status 201

  Scenario: Create closed order and encumbrance with orderStatus closed
    * configure headers = headersAdmin
    Given path 'finance-storage/order-transaction-summaries'
    And request
    """
    {
      "id": "#(orderClosed)",
      "numTransactions": 1
    }
    """
    When method POST
    Then status 201

    Given path 'finance-storage/transactions'
    And request
    """
      {
        "amount": 40,
        "currency": "USD",
        "description": "Rollover test",
        "fiscalYearId": "#(fromFiscalYearId)",
        "source": "PoLine",
        "fromFundId": "#(giftsFund)",
        "transactionType": "Encumbrance",
        "encumbrance" :
          {
          "initialAmountEncumbered": 40,
          "status": "Unreleased",
          "orderStatus": 'Closed',
          "orderType": 'Ongoing',
          "subscription": true,
          "reEncumber": true,
          "sourcePurchaseOrderId": '#(orderClosed)',
          "sourcePoLineId": '#(orderClosedLine)'
          }
      }
    """
    When method POST
    Then status 201
    * def encumbranceId = response.id

    Given path 'orders/composite-orders'
    And request
    """
    {
      "id": '#(orderClosed)',
      "vendor": '#(globalVendorId)',
      "workflowStatus": "Closed",
      "orderType": 'Ongoing',
      "reEncumber": true,
      "ongoing" : {
        "interval" : 182,
        "isSubscription" : true,
        "renewalDate" : "2021-12-03T00:00:00.000+00:00"
      },
      "compositePoLines": [
        {
          "id": "#(orderClosedLine)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "40",
            "quantityPhysical": 1,
            "exchangeRate": "0.82858",
            "currency": "EUR"
          },
          "fundDistribution": [
            {
              "fundId": "#(giftsFund)",
              "encumbrance": "#(encumbranceId)",
              "distributionType": "percentage",
              "value": 100
            }
          ],
          "orderFormat": "Physical Resource",
          "physical": {
            "createInventory": "None"
          },
          "purchaseOrderId": "#(orderClosed)",
          "source": "User",
          "titleOrPackage": "#(orderClosedLine)"
        }
      ]

    }
    """
    When method POST
    Then status 201


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
      | encumbranceInvoiceId   | 11             |
      | noEncumbranceInvoiceId | 5              |


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
      | fromFundId | poLineId              | amount | release | invoiceId              | invoiceLineId |
      | law        | encumberRemainingLine | 6      | false   | encumbranceInvoiceId   | iLine1        |
      | law        | expendedHigherLine    | 11     | false   | encumbranceInvoiceId   | iLine2        |
      | hist       | expendedHigherLine    | 11     | false   | encumbranceInvoiceId   | iLine3        |
      | law        | expendedLowerLine     | 25     | false   | encumbranceInvoiceId   | iLine4        |
      | giftsFund  | orderClosedLine       | 40     | true    | encumbranceInvoiceId   | iLine5        |
      | giftsFund  | noReEncumberLine      | 20     | false   | encumbranceInvoiceId   | iLine6        |
      | hist       | null                  | 49     | false   | noEncumbranceInvoiceId | iLine7        |
      | latin      | null                  | 10     | false   | noEncumbranceInvoiceId | iLine8        |
      | law        | null                  | 29     | false   | noEncumbranceInvoiceId | iLine9        |
      | science    | null                  | 120    | false   | noEncumbranceInvoiceId | iLine10       |
      | giftsFund  | null                  | 60     | false   | noEncumbranceInvoiceId | iLine11       |
      | libFund1   | libOrderLine          | 0.2    | false   | encumbranceInvoiceId   | iLine12       |
      | libFund2   | libOrderLine          | 0.2    | false   | encumbranceInvoiceId   | iLine13       |
      | libFund1   | libOrderLine2         | 0.13   | false   | encumbranceInvoiceId   | iLine14       |
      | libFund2   | libOrderLine2         | 1      | false   | encumbranceInvoiceId   | iLine15       |
      | science    | multiFundLine         | 5      | true    | encumbranceInvoiceId   | iLine16       |

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
      | fromFundId | poLineId              | amount | invoiceId              | invoiceLineId |
      | law        | encumberRemainingLine | 6      | encumbranceInvoiceId   | iLine1        |
      | law        | expendedHigherLine    | 11     | encumbranceInvoiceId   | iLine2        |
      | hist       | expendedHigherLine    | 11     | encumbranceInvoiceId   | iLine3        |
      | law        | expendedLowerLine     | 25     | encumbranceInvoiceId   | iLine4        |
      | giftsFund  | orderClosedLine       | 40     | encumbranceInvoiceId   | iLine5        |
      | giftsFund  | noReEncumberLine      | 20     | encumbranceInvoiceId   | iLine6        |
      | hist       | null                  | 49     | noEncumbranceInvoiceId | iLine7        |
      | latin      | null                  | 10     | noEncumbranceInvoiceId | iLine8        |
      | law        | null                  | 29     | noEncumbranceInvoiceId | iLine9        |
      | science    | null                  | 120    | noEncumbranceInvoiceId | iLine10       |
      | giftsFund  | null                  | 60     | noEncumbranceInvoiceId | iLine11       |
      | libFund1   | libOrderLine          | 0.2    | encumbranceInvoiceId   | iLine12       |
      | libFund2   | libOrderLine          | 0.2    | encumbranceInvoiceId   | iLine13       |
      | libFund1   | libOrderLine2         | 0.13   | encumbranceInvoiceId   | iLine14       |
      | libFund2   | libOrderLine2         | 1      | encumbranceInvoiceId   | iLine15       |
      | science    | multiFundLine         | 5      | encumbranceInvoiceId   | iLine16       |

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
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverAvailable": false,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": true,
            "adjustAllocation": 10,
            "rolloverAvailable": false,
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverAvailable": true,
            "addAvailableTo": "Available",
            "setAllowances": false,
            "allowableEncumbrance": 110 ,
            "allowableExpenditure": 100
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "Ongoing",
            "basedOn": "Expended",
            "increaseBy": 0
          },
          {
            "orderType": "Ongoing-Subscription",
            "basedOn": "Expended",
            "increaseBy": 10
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

  Scenario Outline: Check that budget <id> status is <status> after rollover
    * configure headers = headersAdmin

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id               | status   |
      | hist2020         | 'Closed' |
      | latin2020        | 'Closed' |
      | law2020          | 'Closed' |
      | science2020      | 'Closed' |
      | gift2020         | 'Closed' |
      | africanHist2020  | 'Closed' |
      | rollHist2020     | 'Closed' |
      | euroHist2020     | 'Active' |
      | inactiveFund2020 | 'Closed' |
      | libBud1          | 'Closed' |
      | libBud2          | 'Closed' |
      | libBud3          | 'Closed' |


  Scenario Outline: Check new budgets after rollover
    * def fundId = <fundId>

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId
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
      | hist        | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |
      | latin       | 77        | 77        | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] |
      | law         | 88        | 58.21     | 29.79       | 0            | 29.79      | 160.0                | 170.0                | [#(globalElecExpenseClassId)]                             |
      | science     | 110       | 142.25    | 2.75        | 35           | 2.75       | 110.0                | 120.0                | [#(globalElecExpenseClassId)]                             |
      | giftsFund   | 157.51    | 155.86    | 1.65        | 0            | 1.65       | null                 | null                 | [#(globalElecExpenseClassId)]                             |
      | africanHist | 77.5      | 127.5     | 0           | 50           | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |
      | rollHist    | 198       | 196.9     | 1.1         | 0            | 1.1        | null                 | null                 | [#(globalElecExpenseClassId)]                             |

  Scenario Outline: Verify new budget groups after rollover
    * configure headers = headersAdmin

    * def groups = <groups>
    * def fundId = <fundId>
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId
    When method GET
    Then status 200

    Given path 'finance-storage/group-fund-fiscal-years'
    When param query = 'budgetId==' + response.budgets[0].id
    And method GET
    Then status 200
    And match $.totalRecords == groups.length
    And match $.groupFundFiscalYears[*].groupId contains any groups

    Examples:
      | fundId      | groups                       |
      | hist        | ['#(groupId1)']              |
      | latin       | ['#(groupId2)']              |
      | law         | ['#(groupId1)', #(groupId2)] |
      | science     | ['#(groupId1)']              |
      | giftsFund   | ['#(groupId2)']              |
      | africanHist | ['#(groupId2)']              |
      | rollHist    | ['#(groupId1)']              |


  Scenario: Check expected number of allocations for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions == '#[10]'

  Scenario Outline: Check allocations after rollover
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId    | amount |
      | latin     | 77     |
      | law       | 88     |
      | science   | 110    |
      | giftsFund | 157.51 |
      | rollHist  | 198    |

  Scenario: Check expected number of rollover transfers for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND transactionType==Rollover transfer'
    When method GET
    Then status 200
    And match response.transactions == '#[2]'

  Scenario Outline: Check rollover transfers after rollover
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND transactionType==Rollover transfer'
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId      | amount |
      | science     | 35     |
      | africanHist | 50     |

  Scenario: Check expected number of encumbrances for new fiscal year
    * configure headers = headersAdmin
    Given path 'finance-storage/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND transactionType==Encumbrance'
    When method GET
    Then status 200
    And match response.transactions == '#[10]'

  Scenario Outline: Check encumbrances after rollover
    * configure headers = headersAdmin
    * def fundId = <fundId>
    * def orderId = <orderId>

    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId    | orderId           | amount |
      | law       | expendedLower     | 27.5   |
      | law       | encumberRemaining | 2.29   |
      | science   | multiFundOrder    | 2.75   |
      | giftsFund | multiFundOrder    | 1.65   |
      | rollHist  | multiFundOrder    | 1.1    |

  Scenario: Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Error'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Error'


  Scenario Outline: Check rollover errors
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId + ' AND details.purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverErrors[0].details.amount == <amount>
    And match response.ledgerFiscalYearRolloverErrors[0].details.poLineId == poLineId
    And match response.ledgerFiscalYearRolloverErrors[0].details.fundId == fundId
    And match response.ledgerFiscalYearRolloverErrors[0].errorMessage == <errorMessage>

    Examples:
      | orderId        | poLineId           | fundId       | amount | errorMessage                                                                   |
      | crossLedger    | crossLedgerLine    | rollHist     | 0      | 'Part of the encumbrances belong to the ledger, which has not been rollovered' |
      | expendedHigher | expendedHigherLine | hist         | 11.01  | 'Insufficient funds'                                                           |
      | noBudgetOrder  | noBudgetLine       | inactiveFund | 248.57 | 'Budget not found'

  Scenario Outline: Check order line after rollover
    * configure headers = headersAdmin
    * def poLineId = <poLineId>

    Given path 'finance-storage/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePoLineId==' + poLineId
    When method GET
    Then status 200
    * def encumbranceIds = $.transactions[*].id
    * def total = $.transactions..amount
    * def sum = function(item) {var BigDecimal = Java.type('java.math.BigDecimal'); var sum=new BigDecimal("0"); for(var i=0; i<item.length; i++) {sum = sum.add(new BigDecimal(item[i]));} return sum.setScale(2, java.math.RoundingMode.HALF_UP).doubleValue();}
    * match sum(total) == <transactionAmount>

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.cost.fyroAdjustmentAmount == <fyroAdjustment>
    * match response.fundDistribution[*].encumbrance contains any encumbranceIds
    * match response.fundDistribution[*].value contains only <fundAmount>

    Examples:
      | poLineId              | fyroAdjustment | fundAmount   | transactionAmount |
      | expendedLowerLine     | -7.21          | [100]        | 27.5              |
      | encumberRemainingLine | -8.1           | [100]        | 2.29              |
      | libOrderLine          | -31.99         | [51, 21 ,28] | 83.29             |
      | libOrderLine2         | -32.99         | [18, 41, 41] | 83.6              |


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
