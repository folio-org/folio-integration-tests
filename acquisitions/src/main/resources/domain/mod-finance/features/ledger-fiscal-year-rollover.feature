Feature: Ledger fiscal year rollover

  Background:
    * url baseUrl
    # uncomment below line for development
   # * callonce dev {tenant: 'test_finance133'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain'  }

    * configure headers = headersUser
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

    * def rolloverId = callonce uuid59

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1


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
      | fundTypeId  | name         |
      | books       | 'Books'      |
      | serials     | 'Serials'    |
      | gifts       | 'Gifts'      |
      | monographs  | 'Monographs' |

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
      "fundStatus": "Active",
      "ledgerId": "#(ledgerId)",
      "name": "Fund #(codePrefix + fundCode) for rollover API Tests",
      "fundTypeId": "#(fundTypeId)"
    }
    """
    When method POST
    Then status 201

    Examples:
      | fundId      | ledgerId         | fundCode     | fundTypeId |
      | hist        | rolloverLedger   | 'HIST'       | null       |
      | latin       | rolloverLedger   | 'LATIN'      | books      |
      | law         | rolloverLedger   | 'LAW'        | books      |
      | science     | rolloverLedger   | 'SCIENCE'    | serials    |
      | giftsFund   | rolloverLedger   | 'GIFT'       | gifts      |
      | africanHist | rolloverLedger   | 'AFRICAHIST' | monographs |
      | rollHist    | rolloverLedger   | 'ROLLHIST'   | books      |
      | euroHist    | noRolloverLedger | 'EUROHIST'   | null       |

  Scenario Outline: prepare budget with <fundId>, <fiscalYearId> for rollover
    * def id = <id>
    * def fundId = <fundId>
    * def fiscalYearId = <fiscalYearId>
    * def allocated = <allocated>

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": #(allocated),
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": 100.0
    }
    """
    When method POST
    Then status 201

    Examples:
      | id              | fundId      | fiscalYearId     | allocated |
      | hist2020        | hist        | fromFiscalYearId | 60        |
      | latin2020       | latin       | fromFiscalYearId | 70        |
      | law2020         | law         | fromFiscalYearId | 80        |
      | science2020     | science     | fromFiscalYearId | 110       |
      | gift2020        | giftsFund   | fromFiscalYearId | 140       |
      | africanHist2020 | africanHist | fromFiscalYearId | 50        |
      | africanHist2021 | africanHist | toFiscalYearId   | 20        |
      | rollHist2020    | rollHist    | fromFiscalYearId | 180       |
      | euroHist2020    | euroHist    | fromFiscalYearId | 280       |


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

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fundId = <fundId>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>} : null

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
          "acquisitionMethod": "Purchase",
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
      | orderId           |  poLineId             | fundId    | orderType  | subscription | reEncumber | amount |
      | encumberRemaining | encumberRemainingLine | law       | 'One-Time' | false        | true       | 10     |
      | expendedLower     | expendedLowerLine     | law       | 'Ongoing'  | true         | true       | 30     |
      | noReEncumber      | noReEncumberLine      | giftsFund | 'Ongoing'  | true         | false      | 20     |


  Scenario Outline: Create open orders with 2 fund distributions

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def fund1Id = <fund1Id>
    * def fund2Id = <fund2Id>
    * def ongoing = <orderType> == 'Ongoing' ? {"isSubscription": <subscription>} : null

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
          "acquisitionMethod": "Purchase",
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
      | orderId           |  poLineId             | fund1Id    | fund2Id  | orderType  | subscription | reEncumber | amount |
      | expendedHigher    | expendedHigherLine    | law        | hist     | 'Ongoing'  | false        | true       | 20     |
      | crossLedger       | crossLedgerLine       | rollHist   | euroHist | 'Ongoing'  | true         | true       | 40     |


  Scenario: Create closed order and encumbrance with orderStatus closed

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
      "ongoing": {
        "isSubscription": true
      },
      "compositePoLines": [
        {
          "id": "#(orderClosedLine)",
          "acquisitionMethod": "Purchase",
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
      | encumbranceInvoiceId   | 6              |
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
      | fromFundId  | poLineId              | amount | release | invoiceId              | invoiceLineId |
      | law         | encumberRemainingLine | 6      | false   | encumbranceInvoiceId   | iLine1        |
      | law         | expendedHigherLine    | 11     | false   | encumbranceInvoiceId   | iLine2        |
      | hist        | expendedHigherLine    | 11     | false   | encumbranceInvoiceId   | iLine3        |
      | law         | expendedLowerLine     | 25     | false   | encumbranceInvoiceId   | iLine4        |
      | giftsFund   | orderClosedLine       | 40     | true    | encumbranceInvoiceId   | iLine5        |
      | giftsFund   | noReEncumberLine      | 20     | false   | encumbranceInvoiceId   | iLine6        |
      | hist        | null                  | 49     | false   | noEncumbranceInvoiceId | iLine7        |
      | latin       | null                  | 10     | false   | noEncumbranceInvoiceId | iLine8        |
      | law         | null                  | 29     | false   | noEncumbranceInvoiceId | iLine9        |
      | science     | null                  | 120    | false   | noEncumbranceInvoiceId | iLine10       |
      | giftsFund   | null                  | 60     | false   | noEncumbranceInvoiceId | iLine11       |

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
      | fromFundId  | poLineId              | amount | invoiceId              | invoiceLineId |
      | law         | encumberRemainingLine | 6      | encumbranceInvoiceId   | iLine1        |
      | law         | expendedHigherLine    | 11     | encumbranceInvoiceId   | iLine2        |
      | hist        | expendedHigherLine    | 11     | encumbranceInvoiceId   | iLine3        |
      | law         | expendedLowerLine     | 25     | encumbranceInvoiceId   | iLine4        |
      | giftsFund   | orderClosedLine       | 40     | encumbranceInvoiceId   | iLine5        |
      | giftsFund   | noReEncumberLine      | 20     | encumbranceInvoiceId   | iLine6        |
      | hist        | null                  | 49     | noEncumbranceInvoiceId | iLine7        |
      | latin       | null                  | 10     | noEncumbranceInvoiceId | iLine8        |
      | law         | null                  | 29     | noEncumbranceInvoiceId | iLine9        |
      | science     | null                  | 120    | noEncumbranceInvoiceId | iLine10       |
      | giftsFund   | null                  | 60     | noEncumbranceInvoiceId | iLine11       |

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
            "rolloverAllocation": false,
            "adjustAllocation": 0,
            "rolloverAvailable": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(books)",
            "rolloverAllocation": true,
            "adjustAllocation": 10,
            "rolloverAvailable": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(serials)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "addAvailableTo": "Available",
            "allowableEncumbrance": 110,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(gifts)",
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverAvailable": true,
            "addAvailableTo": "Allocation",
            "allowableEncumbrance": 110,
            "allowableExpenditure": 100
          },
          {
            "fundTypeId": "#(monographs)",
            "rolloverAllocation": true,
            "adjustAllocation": 15,
            "rolloverAvailable": true,
            "addAvailableTo": "Available",
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

    Given path 'finance/budgets', <id>
    When method GET
    Then status 200
    And match response.budgetStatus == <status>

    Examples:
      | id              | status      |
      | hist2020        | 'Closed'    |
      | latin2020       | 'Closed'    |
      | law2020         | 'Closed'    |
      | science2020     | 'Closed'    |
      | gift2020        | 'Closed'    |
      | africanHist2020 | 'Closed'    |
      | rollHist2020    | 'Closed'    |
      | euroHist2020    | 'Active'    |


  Scenario Outline: Check new budgets after rollover
    * def fundId = <fundId>

    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId
    When method GET
    Then status 200
    And match response.budgets[0].allocated == <allocated>
    And match response.budgets[0].available == <available>
    And match response.budgets[0].unavailable == <unavailable>
    And match response.budgets[0].netTransfers == <netTransfers>
    And match response.budgets[0].encumbered == <encumbered>

    Examples:
      | fundId      | allocated | available | unavailable | netTransfers | encumbered |
      | hist        | 0         | 0         | 0           | 0            | 0          |
      | latin       | 77        | 77        | 0           | 0            | 0          |
      | law         | 88        | 56.5      | 31.5        | 0            | 31.5       |
      | science     | 110       | 150       | 0           | 40           | 0          |
      | giftsFund   | 160       | 160       | 0           | 0            | 0          |
      | africanHist | 77.5      | 127.5     | 0           | 50           | 0          |
      | rollHist    | 198       | 198       | 0           | 0            | 0          |


  Scenario: Check expected number of allocations for new fiscal year
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND transactionType==Allocation'
    When method GET
    Then status 200
    And match response.transactions == '#[7]'

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
      | giftsFund | 160    |
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
      | science     | 40     |
      | africanHist | 50     |

  Scenario: Check expected number of encumbrances for new fiscal year
    Given path 'finance-storage/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' AND transactionType==Encumbrance'
    When method GET
    Then status 200
    And match response.transactions == '#[2]'

  Scenario Outline: Check encumbrances after rollover
    * def fundId = <fundId>
    * def orderId = <orderId>

    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.transactions[0].amount == <amount>

    Examples:
      | fundId | orderId           |amount |
      | law    | expendedLower     | 27.5  |
      | law    | encumberRemaining | 4     |

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
      | orderId        | poLineId           | fundId   | amount | errorMessage                                                                   |
      | crossLedger    | crossLedgerLine    | rollHist | 0      | 'Part of the encumbrances belong to the ledger, which has not been rollovered' |
      | expendedHigher | expendedHigherLine | hist     | 12.1   | 'Insufficient funds'                                                           |

    Scenario Outline: Check order line after rollover
      * def poLineId = <poLineId>

      Given path 'finance-storage/transactions'
      And param query = 'fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePoLineId==' + poLineId
      When method GET
      Then status 200
      * def encumbranceId = response.transactions[0].id

      Given path 'orders/order-lines', poLineId
      When method GET
      Then status 200
      And match response.cost.fyroAdjustmentAmount == <fyroAdjustment>
      * match response.fundDistribution[0].encumbrance == encumbranceId

      Examples:
        | poLineId              | fyroAdjustment |
        | expendedLowerLine     | -2.5           |
        | encumberRemainingLine | -6             |


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
      Given path '/finance-storage/ledger-rollovers', rolloverId
      When method DELETE
      Then status 204
