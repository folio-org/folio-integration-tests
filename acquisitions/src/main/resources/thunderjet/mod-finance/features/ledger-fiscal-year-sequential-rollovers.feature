Feature: Ledger fiscal year sequential rollovers

  # 1) rollover preview fiscalYearId1 -> fiscalYearId2
  # 2) rollover fiscalYearId1 -> fiscalYearId2
  # 3) rollover preview fiscalYearId2 -> fiscalYearId3
  # 4) rollover fiscalYearId2 -> fiscalYearId3

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
    * def rolloverLedger2 = callonce uuid5

    * def books = callonce uuid6
    * def serials = callonce uuid7
    * def gifts = callonce uuid8
    * def monographs = callonce uuid9

    * def hist = callonce uuid10
    * def latin = callonce uuid11
    * def law = callonce uuid12
    * def science = callonce uuid13
    * def giftsFund = callonce uuid14
    * def africanHist = callonce uuid15
    * def rollHist = callonce uuid16
    * def euroHist = callonce uuid17

    * def hist2020 = callonce uuid18
    * def latin2020 = callonce uuid19
    * def law2020 = callonce uuid20
    * def science2020 = callonce uuid21
    * def gift2020 = callonce uuid22
    * def africanHist2020 = callonce uuid23
    * def africanHist2022 = callonce uuid24
    * def rollHist2020 = callonce uuid25
    * def euroHist2020 = callonce uuid26

    * def encumberRemaining = callonce uuid27
    * def expendedHigher = callonce uuid28
    * def expendedLower = callonce uuid29
    * def orderClosed = callonce uuid30
    * def noReEncumber = callonce uuid31
    * def crossLedger = callonce uuid32

    * def encumberRemainingLine = callonce uuid33
    * def expendedHigherLine = callonce uuid34
    * def expendedLowerLine = callonce uuid35
    * def orderClosedLine = callonce uuid36
    * def noReEncumberLine = callonce uuid37
    * def crossLedgerLine = callonce uuid38

    * def encumbranceInvoiceId = callonce uuid39
    * def noEncumbranceInvoiceId = callonce uuid40

    * def iLine1 = callonce uuid41
    * def iLine2 = callonce uuid42
    * def iLine3 = callonce uuid43
    * def iLine4 = callonce uuid44
    * def iLine5 = callonce uuid45
    * def iLine6 = callonce uuid46
    * def iLine7 = callonce uuid47
    * def iLine8 = callonce uuid48
    * def iLine9 = callonce uuid49
    * def iLine10 = callonce uuid50
    * def iLine11 = callonce uuid51
    * def iLine12 = callonce uuid52
    * def iLine12 = callonce uuid53
    * def iLine13 = callonce uuid54
    * def iLine14 = callonce uuid55
    * def iLine15 = callonce uuid56
    * def iLine16 = callonce uuid57

    * def rolloverId1 = callonce uuid58
    * def rolloverId2 = callonce uuid59
    * def rolloverId3 = callonce uuid60
    * def rolloverId4 = callonce uuid61

    * def previewRolloverId1 = callonce uuid62
    * def previewRolloverId2 = callonce uuid63
    * def previewRolloverId3 = callonce uuid64
    * def previewRolloverId4 = callonce uuid65

    * def groupId1 = callonce uuid66
    * def groupId2 = callonce uuid67

    * def inactiveFund = callonce uuid68
    * def inactiveFund2020 = callonce uuid69
    * def noBudgetOrder = callonce uuid70
    * def noBudgetLine = callonce uuid71

    * def multiFundOrder = callonce uuid72
    * def multiFundLine = callonce uuid73

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def toYear2 = parseInt(toYear) + 1

    * def libFund1 = callonce uuid74
    * def libFund2 = callonce uuid75
    * def libFund3 = callonce uuid76

    * def libBud1 = callonce uuid77
    * def libBud2 = callonce uuid78
    * def libBud3 = callonce uuid79

    * def libOrder = callonce uuid80
    * def libOrderLine = callonce uuid81
    * def libOrderLine2 = callonce uuid82

    * def classicalFund1 = callonce uuid83
    * def classicalFund2 = callonce uuid84

    * def classicalBud1 = callonce uuid85
    * def classicalBud2 = callonce uuid86

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
      | rolloverLedger2 |

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
      | fundId         | ledgerId        | fundCode     | fundTypeId | status     |
      | hist           | rolloverLedger1 | 'HIST'       | null       | 'Active'   |
      | latin          | rolloverLedger1 | 'LATIN'      | books      | 'Active'   |
      | law            | rolloverLedger1 | 'LAW'        | books      | 'Active'   |
      | science        | rolloverLedger1 | 'SCIENCE'    | serials    | 'Active'   |
      | giftsFund      | rolloverLedger1 | 'GIFT'       | gifts      | 'Active'   |
      | africanHist    | rolloverLedger1 | 'AFRICAHIST' | monographs | 'Active'   |
      | rollHist       | rolloverLedger1 | 'ROLLHIST'   | books      | 'Active'   |
      | euroHist       | rolloverLedger2 | 'EUROHIST'   | null       | 'Active'   |
      | inactiveFund   | rolloverLedger1 | 'INACTIVE'   | null       | 'Inactive' |
      | libFund1       | rolloverLedger1 | 'LIBFUND1'   | books      | 'Active'   |
      | libFund2       | rolloverLedger1 | 'LIBFUND2'   | books      | 'Active'   |
      | libFund3       | rolloverLedger1 | 'LIBFUND3'   | books      | 'Active'   |
      | classicalFund1 | rolloverLedger1 | 'CLASSIC1'   | books      | 'Active'   |
      | classicalFund2 | rolloverLedger2 | 'CLASSIC2'   | books      | 'Active'   |

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
      | id               | fundId         | fiscalYearId  | allocated | allowableExpenditure | allowableEncumbrance | expenseClasses                                            | groups                       | budgetStatus |
      | hist2020         | hist           | fiscalYearId1 | 60        | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Active'     |
      | latin2020        | latin          | fiscalYearId1 | 70        | 100                  | 100                  | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] | ['#(groupId2)']              | 'Active'     |
      | law2020          | law            | fiscalYearId1 | 80        | 170                  | 160                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)', #(groupId2)] | 'Active'     |
      | science2020      | science        | fiscalYearId1 | 110       | 80                   | 90                   | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Active'     |
      | gift2020         | giftsFund      | fiscalYearId1 | 140       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Active'     |
      | africanHist2020  | africanHist    | fiscalYearId1 | 50        | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Active'     |
      | africanHist2022  | africanHist    | fiscalYearId2 | 20        | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Active'     |
      | rollHist2020     | rollHist       | fiscalYearId1 | 180       | null                 | null                 | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Active'     |
      | euroHist2020     | euroHist       | fiscalYearId1 | 280       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Active'     |
      | inactiveFund2020 | inactiveFund   | fiscalYearId1 | 500       | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId1)']              | 'Active'     |
      | libBud1          | libFund1       | fiscalYearId1 | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Active'     |
      | libBud2          | libFund2       | fiscalYearId1 | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Active'     |
      | libBud3          | libFund3       | fiscalYearId1 | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Active'     |
      | classicalBud1    | classicalFund1 | fiscalYearId2 | 2550      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Planned'    |
      | classicalBud2    | classicalFund2 | fiscalYearId2 | 1000      | 100                  | 100                  | [#(globalElecExpenseClassId)]                             | ['#(groupId2)']              | 'Planned'    |

  Scenario: Create transfer to SCIENCE2020 budget
    Given path 'finance/transfers'
    And request
    """
      {
        "amount": 50,
        "currency": "USD",
        "description": "Rollover test transfer",
        "fiscalYearId": "#(fiscalYearId1)",
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
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2022-12-03T00:00:00.000+00:00"} : null
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
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>, "interval": 182, "renewalDate": "2022-12-03T00:00:00.000+00:00"} : null
    * def rq =
    """
    {
      "id": "#(poLineId)",
      "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
      "cost": {
        "listUnitPrice": "<amount>",
        "quantityPhysical": 1,
        "currency": "USD"
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
        "renewalDate" : "2022-12-03T00:00:00.000+00:00"
      },
      "compositePoLines": [
        {
          "id": "#(multiFundLine)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "10",
            "quantityPhysical": 1,
            "currency": "USD"
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
        "fiscalYearId": "#(fiscalYearId1)",
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
        "renewalDate" : "2022-12-03T00:00:00.000+00:00"
      },
      "compositePoLines": [
        {
          "id": "#(orderClosedLine)",
          "acquisitionMethod": "#(globalPurchaseAcqMethodId)",
          "cost": {
            "listUnitPrice": "40",
            "quantityPhysical": 1,
            "currency": "USD"
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
        "fiscalYearId": "#(fiscalYearId1)",
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
        "fiscalYearId": "#(fiscalYearId1)",
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

  Scenario: Start first rollover preview for ledger 1
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewRolloverId1)",
        "ledgerId": "#(rolloverLedger1)",
        "fromFiscalYearId": "#(fiscalYearId1)",
        "toFiscalYearId": "#(fiscalYearId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "rolloverType": "Preview",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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

  Scenario: Wait for rollover preview for ledger 1 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + previewRolloverId1
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

  Scenario: Start first rollover preview for ledger 2
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewRolloverId2)",
        "ledgerId": "#(rolloverLedger2)",
        "fromFiscalYearId": "#(fiscalYearId1)",
        "toFiscalYearId": "#(fiscalYearId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "rolloverType": "Preview",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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

  Scenario: Wait for rollover preview for ledger 2 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + previewRolloverId2
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

  Scenario Outline: Check that budget <id> status is <status> after rollover, budget status should not be changed
    * configure headers = headersAdmin

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id               | status    |
      | hist2020         | 'Active'  |
      | latin2020        | 'Active'  |
      | law2020          | 'Active'  |
      | science2020      | 'Active'  |
      | gift2020         | 'Active'  |
      | africanHist2020  | 'Active'  |
      | rollHist2020     | 'Active'  |
      | euroHist2020     | 'Active'  |
      | inactiveFund2020 | 'Active'  |
      | libBud1          | 'Active'  |
      | libBud2          | 'Active'  |
      | libBud3          | 'Active'  |
      | classicalBud1    | 'Planned' |
      | classicalBud2    | 'Planned' |

  Scenario Outline: Check new budgets after rollover preview
    * def fundId = <fundId>

    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId2
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

    Examples:
      | fundId      | allocated | available | unavailable | netTransfers | encumbered | allowableEncumbrance | allowableExpenditure |
      | hist        | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                |
      | latin       | 77        | 77        | 0           | 0            | 0          | 100.0                | 100.0                |
      | law         | 88        | 56.5      | 31.5        | 0            | 31.5       | 160.0                | 170.0                |
      | science     | 110       | 142.25    | 2.75        | 35           | 2.75       | 110.0                | 120.0                |
      | giftsFund   | 157       | 155.35    | 1.65        | 0            | 1.65       | null                 | null                 |
      | africanHist | 77.5      | 127.5     | 0           | 50           | 0          | 100.0                | 100.0                |
      | rollHist    | 198       | 196.9     | 1.1         | 0            | 1.1        | null                 | null                 |
      | euroHist    | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                |

  Scenario Outline: Check rollover preview id=<previewRolloverId> logs
    * def previewRolloverId = <previewRolloverId>
    Given path 'finance/ledger-rollovers-logs', previewRolloverId1
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Error'
    And match response.ledgerRolloverType == 'Preview'

    Examples:
      | previewRolloverId  |
      | previewRolloverId1 |
      | previewRolloverId2 |

  Scenario Outline: Check rollover preview id=<previewRolloverId> statuses
    * def previewRolloverId = <previewRolloverId>
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + previewRolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Error'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Error'

    Examples:
      | previewRolloverId  |
      | previewRolloverId1 |
      | previewRolloverId2 |


  Scenario Outline: Check rollover preview  id=<previewRolloverId> errors
    * configure headers = headersAdmin

    * def previewRolloverId = <previewRolloverId>
    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + previewRolloverId + ' AND details.purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverErrors[0].details.amount == <amount>
    And match response.ledgerFiscalYearRolloverErrors[0].details.poLineId == poLineId
    And match response.ledgerFiscalYearRolloverErrors[0].details.fundId == fundId
    And match response.ledgerFiscalYearRolloverErrors[0].errorMessage == <errorMessage>

    Examples:
      | previewRolloverId  | orderId        | poLineId           | fundId       | amount | errorMessage                                                                                                                                                             |
      | previewRolloverId1 | crossLedger    | crossLedgerLine    | rollHist     | 0      | '#("[WARNING] Part of the encumbrances belong to the ledger, which has not been rollovered. Ledgers to rollover: " + rolloverLedger2 + " (id=" + rolloverLedger2 + ")")' |
      | previewRolloverId1 | expendedHigher | expendedHigherLine | hist         | 11     | 'Insufficient funds'                                                                                                                                                     |
      | previewRolloverId1 | noBudgetOrder  | noBudgetLine       | inactiveFund | 300    | 'Budget not found'                                                                                                                                                       |
      | previewRolloverId2 | crossLedger    | crossLedgerLine    | euroHist     | 0      | '#("[WARNING] Part of the encumbrances belong to the ledger, which has not been rollovered. Ledgers to rollover: " + rolloverLedger1 + " (id=" + rolloverLedger1 + ")")' |


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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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
      | hist2020         | 'Closed'  |
      | latin2020        | 'Closed'  |
      | law2020          | 'Closed'  |
      | science2020      | 'Closed'  |
      | gift2020         | 'Closed'  |
      | africanHist2020  | 'Closed'  |
      | rollHist2020     | 'Closed'  |
      | euroHist2020     | 'Active'  |
      | inactiveFund2020 | 'Closed'  |
      | libBud1          | 'Closed'  |
      | libBud2          | 'Closed'  |
      | libBud3          | 'Closed'  |
      | classicalBud1    | 'Active'  |
      | classicalBud2    | 'Planned' |


  Scenario: Start first rollover for ledger 2
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId2)",
        "ledgerId": "#(rolloverLedger2)",
        "fromFiscalYearId": "#(fiscalYearId1)",
        "toFiscalYearId": "#(fiscalYearId2)",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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


  Scenario: Wait for first rollover for ledger 2 to end
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
      | hist2020         | 'Closed'  |
      | latin2020        | 'Closed'  |
      | law2020          | 'Closed'  |
      | science2020      | 'Closed'  |
      | gift2020         | 'Closed'  |
      | africanHist2020  | 'Closed'  |
      | rollHist2020     | 'Closed'  |
      | euroHist2020     | 'Closed'  |
      | inactiveFund2020 | 'Closed'  |
      | libBud1          | 'Closed'  |
      | libBud2          | 'Closed'  |
      | libBud3          | 'Closed'  |
      | classicalBud1    | 'Active'  |
      | classicalBud2    | 'Active' |




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
      | hist        | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |
      | latin       | 77        | 77        | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] |
      | law         | 88        | 56.5      | 31.5        | 0            | 31.5       | 160.0                | 170.0                | [#(globalElecExpenseClassId)]                             |
      | science     | 110       | 142.25    | 2.75        | 35           | 2.75       | 110.0                | 120.0                | [#(globalElecExpenseClassId)]                             |
      | giftsFund   | 157       | 155.35    | 1.65        | 0            | 1.65       | null                 | null                 | [#(globalElecExpenseClassId)]                             |
      | africanHist | 77.5      | 127.5     | 0           | 50           | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |
      | rollHist    | 198       | 196.9     | 1.1         | 0            | 1.1        | null                 | null                 | [#(globalElecExpenseClassId)]                             |
      | euroHist    | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |

  Scenario Outline: Verify new budget groups after rollover
    * configure headers = headersAdmin

    * def groups = <groups>
    * def fundId = <fundId>
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId2
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
      | euroHist    | ['#(groupId2)']              |


  Scenario: Check expected number of allocations for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions == '#[10]'

  Scenario Outline: Check allocations after rollover
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId2 + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId    | amount |
      | latin     | 77     |
      | law       | 88     |
      | science   | 110    |
      | giftsFund | 157    |
      | rollHist  | 198    |

  Scenario: Check expected number of rollover transfers for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND transactionType==Rollover transfer'
    When method GET
    Then status 200
    And match response.transactions == '#[2]'

  Scenario Outline: Check rollover transfers after rollover
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId2 + ' AND transactionType==Rollover transfer'
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
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' AND transactionType==Encumbrance'
    When method GET
    Then status 200
    And match response.transactions == '#[10]'

  Scenario Outline: Check encumbrances after rollover
    * configure headers = headersAdmin
    * def fundId = <fundId>
    * def orderId = <orderId>

    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId2 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId    | orderId           | amount |
      | law       | expendedLower     | 27.5   |
      | law       | encumberRemaining | 4      |
      | science   | multiFundOrder    | 2.75   |
      | giftsFund | multiFundOrder    | 1.65   |
      | rollHist  | multiFundOrder    | 1.1    |

  Scenario: Check rollover 1 logs
    Given path 'finance/ledger-rollovers-logs', rolloverId1
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Error'
    And match response.ledgerRolloverType == 'Commit'

  Scenario: Check rollover 1 statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Error'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Error'


  Scenario Outline: Check rollover 1 errors
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId1 + ' AND details.purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverErrors[0].details.amount == <amount>
    And match response.ledgerFiscalYearRolloverErrors[0].details.poLineId == poLineId
    And match response.ledgerFiscalYearRolloverErrors[0].details.fundId == fundId
    And match response.ledgerFiscalYearRolloverErrors[0].errorMessage == <errorMessage>

    Examples:
      | orderId        | poLineId           | fundId       | amount | errorMessage                                                                                                                                                               |
      | crossLedger    | crossLedgerLine    | rollHist     | 0      | '#("[WARNING] Part of the encumbrances belong to the ledger, which has not been rollovered. Ledgers to rollover: " + rolloverLedger2 + " (id=" + rolloverLedger2 + ")")' |
      | expendedHigher | expendedHigherLine | hist         | 11     | 'Insufficient funds'                                                                                                                                                       |
      | noBudgetOrder  | noBudgetLine       | inactiveFund | 300    | 'Budget not found'                                                                                                                                                         |

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

  Scenario: Start second rollover preview for ledger 1
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewRolloverId3)",
        "ledgerId": "#(rolloverLedger1)",
        "fromFiscalYearId": "#(fiscalYearId2)",
        "toFiscalYearId": "#(fiscalYearId3)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "rolloverType": "Preview",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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

  Scenario: Wait for second rollover preview for ledger 1 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + previewRolloverId3
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

  Scenario: Start second rollover preview for ledger 2
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewRolloverId4)",
        "ledgerId": "#(rolloverLedger2)",
        "fromFiscalYearId": "#(fiscalYearId2)",
        "toFiscalYearId": "#(fiscalYearId3)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "rolloverType": "Preview",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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

  Scenario: Wait for second rollover preview for ledger 2 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + previewRolloverId4
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

  Scenario Outline: Check that budget <id> status is <status> after rollover, budget status should not be changed
    * configure headers = headersAdmin

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id               | status    |
      | hist2020         | 'Closed'  |
      | latin2020        | 'Closed'  |
      | law2020          | 'Closed'  |
      | science2020      | 'Closed'  |
      | gift2020         | 'Closed'  |
      | africanHist2020  | 'Closed'  |
      | rollHist2020     | 'Closed'  |
      | euroHist2020     | 'Closed'  |
      | inactiveFund2020 | 'Closed'  |
      | libBud1          | 'Closed'  |
      | libBud2          | 'Closed'  |
      | libBud3          | 'Closed'  |
      | classicalBud1    | 'Active'  |
      | classicalBud2    | 'Active'  |

  Scenario Outline: Check new budgets after rollover preview
    * def fundId = <fundId>

    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId3
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

    Examples:
      | fundId      | allocated | available | unavailable | netTransfers | encumbered | allowableEncumbrance | allowableExpenditure |
      | hist        | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                |
      | latin       | 84.7      | 84.7      | 0           | 0            | 0          | 100.0                | 100.0                |
      | law         | 96.8      | 92.8      | 4           | 0            | 4          | 160.0                | 170.0                |
      | science     | 110       | 252.25    | 0.0         | 142.25       | 0          | 110.0                | 120.0                |
      | giftsFund   | 312.35    | 312.35    | 0.0         | 0            | 0.0        | null                 | null                 |
      | africanHist | 89.125    | 216.625   | 0           | 127.5        | 0          | 100.0                | 100.0                |
      | rollHist    | 217.8     | 217.8     | 0.0         | 0            | 0.0        | null                 | null                 |
      | euroHist    | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                |

  Scenario Outline: Check rollover preview id=<previewRolloverId> logs
    * def previewRolloverId = <previewRolloverId>
    Given path 'finance/ledger-rollovers-logs', previewRolloverId1
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Error'
    And match response.ledgerRolloverType == 'Preview'

    Examples:
      | previewRolloverId  |
      | previewRolloverId1 |
      | previewRolloverId2 |

  Scenario Outline: Check rollover preview id=<previewRolloverId> statuses
    * def previewRolloverId = <previewRolloverId>
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + previewRolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Error'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Error'

    Examples:
      | previewRolloverId  |
      | previewRolloverId3 |
      | previewRolloverId4 |


  Scenario Outline: Check rollover preview  id=<previewRolloverId> errors
    * configure headers = headersAdmin

    * def previewRolloverId = <previewRolloverId>
    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + previewRolloverId + ' AND details.purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverErrors[0].details.amount == <amount>
    And match response.ledgerFiscalYearRolloverErrors[0].details.poLineId == poLineId
    And match response.ledgerFiscalYearRolloverErrors[0].details.fundId == fundId
    And match response.ledgerFiscalYearRolloverErrors[0].errorMessage == <errorMessage>

    Examples:
      | previewRolloverId  | orderId        | poLineId           | fundId       | amount | errorMessage                                                                                                                                                             |
      | previewRolloverId3 | crossLedger    | crossLedgerLine    | rollHist     | 0      | '#("[WARNING] Part of the encumbrances belong to the ledger, which has not been rollovered. Ledgers to rollover: " + rolloverLedger2 + " (id=" + rolloverLedger2 + ")")' |
      | previewRolloverId4 | crossLedger    | crossLedgerLine    | euroHist     | 0      | '#("[WARNING] Part of the encumbrances belong to the ledger, which has not been rollovered. Ledgers to rollover: " + rolloverLedger1 + " (id=" + rolloverLedger1 + ")")' |

  Scenario: Start second rollover for ledger 1
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId3)",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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

  Scenario: Wait for second rollover for ledger 1 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId3
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
      | hist2020         | 'Closed'  |
      | latin2020        | 'Closed'  |
      | law2020          | 'Closed'  |
      | science2020      | 'Closed'  |
      | gift2020         | 'Closed'  |
      | africanHist2020  | 'Closed'  |
      | rollHist2020     | 'Closed'  |
      | euroHist2020     | 'Closed'  |
      | inactiveFund2020 | 'Closed'  |
      | libBud1          | 'Closed'  |
      | libBud2          | 'Closed'  |
      | libBud3          | 'Closed'  |
      | classicalBud1    | 'Closed'  |
      | classicalBud2    | 'Active' |

  Scenario: Check rollover 3 logs
    Given path 'finance/ledger-rollovers-logs', rolloverId3
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Error'
    And match response.ledgerRolloverType == 'Commit'

  Scenario: Check rollover 3 statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId3
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Error'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Error'


  Scenario Outline: Check rollover 3 errors
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>

    Given path 'finance-storage/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId3 + ' AND details.purchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverErrors[0].details.amount == <amount>
    And match response.ledgerFiscalYearRolloverErrors[0].details.poLineId == poLineId
    And match response.ledgerFiscalYearRolloverErrors[0].details.fundId == fundId
    And match response.ledgerFiscalYearRolloverErrors[0].errorMessage == <errorMessage>

    Examples:
      | orderId        | poLineId           | fundId       | amount | errorMessage                                                                                                                                                               |
      | crossLedger    | crossLedgerLine    | rollHist     | 0      | '#("[WARNING] Part of the encumbrances belong to the ledger, which has not been rollovered. Ledgers to rollover: " + rolloverLedger2 + " (id=" + rolloverLedger2 + ")")' |

  Scenario: Start second rollover for ledger 2
    * configure headers = headersUser
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId4)",
        "ledgerId": "#(rolloverLedger2)",
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
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Available",
            "setAllowances": true,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": true
          },
          {
            "fundTypeId": "#(rollHist)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "addAvailableTo": "Allocation",
            "setAllowances": false,
            "allowableEncumbrance": 110,
            "allowableExpenditure": 120
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverBudgetValue": "Available",
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

  Scenario: Wait for second rollover for ledger 2 to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId4
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
      | hist2020         | 'Closed'  |
      | latin2020        | 'Closed'  |
      | law2020          | 'Closed'  |
      | science2020      | 'Closed'  |
      | gift2020         | 'Closed'  |
      | africanHist2020  | 'Closed'  |
      | rollHist2020     | 'Closed'  |
      | euroHist2020     | 'Closed'  |
      | inactiveFund2020 | 'Closed'  |
      | libBud1          | 'Closed'  |
      | libBud2          | 'Closed'  |
      | libBud3          | 'Closed'  |
      | classicalBud1    | 'Closed'  |
      | classicalBud2    | 'Closed' |

  Scenario: Check rollover 4 logs
    Given path 'finance/ledger-rollovers-logs', rolloverId4
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Commit'

  Scenario: Check rollover 4 statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId4
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
      | hist        | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |
      | latin       | 84.7      | 84.7      | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId), #(globalPrnExpenseClassId)] |
      | law         | 96.8      | 92.8      | 4           | 0            | 4          | 160.0                | 170.0                | [#(globalElecExpenseClassId)]                             |
      | science     | 110       | 252.25    | 0.0         | 142.25       | 0          | 110.0                | 120.0                | [#(globalElecExpenseClassId)]                             |
      | giftsFund   | 312.35    | 312.35    | 0.0         | 0            | 0.0        | null                 | null                 | [#(globalElecExpenseClassId)]                             |
      | africanHist | 89.125    | 216.625   | 0           | 127.5        | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |
      | rollHist    | 217.8     | 217.8     | 0.0         | 0            | 0.0        | null                 | null                 | [#(globalElecExpenseClassId)]                             |
      | euroHist    | 0         | 0         | 0           | 0            | 0          | 100.0                | 100.0                | [#(globalElecExpenseClassId)]                             |

  Scenario Outline: Verify new budget groups after rollover
    * configure headers = headersAdmin

    * def groups = <groups>
    * def fundId = <fundId>
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId3
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
      | euroHist    | ['#(groupId2)']              |


  Scenario: Check expected number of allocations for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId3 + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions == '#[10]'

  Scenario Outline: Check allocations after rollover
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId3 + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId    | amount |
      | latin     | 84.7   |
      | law       | 96.8   |
      | science   | 110    |
      | giftsFund | 312.35 |
      | rollHist  | 217.8  |

  Scenario: Check expected number of rollover transfers for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId3 + ' AND transactionType==Rollover transfer'
    When method GET
    Then status 200
    And match response.transactions == '#[2]'

  Scenario Outline: Check rollover transfers after rollover
    * def fundId = <fundId>

    Given path 'finance/transactions'
    And param query = 'toFundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId3 + ' AND transactionType==Rollover transfer'
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId      | amount |
      | science     | 142.25 |
      | africanHist | 127.5  |

  Scenario: Check expected number of encumbrances for new fiscal year
    * configure headers = headersAdmin
    Given path 'finance-storage/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId3 + ' AND transactionType==Encumbrance'
    When method GET
    Then status 200
    And match response.transactions == '#[10]'

  Scenario Outline: Check encumbrances after rollover
    * configure headers = headersAdmin
    * def fundId = <fundId>
    * def orderId = <orderId>

    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + fiscalYearId3 + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId    | orderId           | amount |
      | law       | expendedLower     | 0.0    |
      | law       | encumberRemaining | 4      |
      | science   | multiFundOrder    | 0.0    |
      | giftsFund | multiFundOrder    | 0.0    |
      | rollHist  | multiFundOrder    | 0.0    |
