@parallel=false
# for https://folio-org.atlassian.net/browse/MODORDERS-956
Feature: Verify that order with broken encumbrance will be rolled over successfully

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createLedger = read('classpath:thunderjet/mod-finance/reusable/createLedger.feature')
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def getOrderLine = read('classpath:thunderjet/mod-orders/reusable/get-order-line.feature')

    * def fromFiscalYearId = callonce uuid1
    * def toFiscalYearId = callonce uuid2
    * def ledgerId = callonce uuid3
    * def rolloverId = callonce uuid4
    * def fundId = callonce uuid5
    * def budgetId = callonce uuid6

    * def brokenOrderId = callonce uuid7
    * def regularOrderId = callonce uuid8
    * def brokenPoLineId = callonce uuid9
    * def regularPoLineId = callonce uuid10

    * def nonExistingEncumbranceId = callonce uuid11

    * def codePrefix = callonce random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

    * configure retry = { count: 10, interval: 5000 }

  Scenario Outline: Prepare fiscal year with <fiscalYearId> for rollover
    * configure headers = headersAdmin
    * def fiscalYearId = <fiscalYearId>
    * def code = <code>
    * def periodStart = code + '-01-01T00:00:00Z'
    * def periodEnd = code + '-12-30T23:59:59Z'

    * def v = call createFiscalYear { id: #(fiscalYearId), code: #(codePrefix + code), periodStart: #(periodStart), periodEnd: #(periodEnd) }

    Examples:
      | fiscalYearId     | code     |
      | fromFiscalYearId | fromYear |
      | toFiscalYearId   | toYear   |


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fromFiscalYearId) }
    * def v = call createFund { id: #(fundId),  ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), fiscalYearId: #(fromFiscalYearId), allocated: 100 }


  Scenario Outline: Create orders and open them
    * configure headers = headersAdmin

    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def listUnitPrice = <listUnitPrice>

    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), listUnitPrice: #(listUnitPrice) }
    * def v = call openOrder { orderId: "#(orderId)" }

    Examples:
      | orderId          | poLineId          | listUnitPrice |
      | brokenOrderId    | brokenPoLineId    | 20            |
      | regularOrderId   | regularPoLineId   | 30            |


  Scenario: Replace encumbrance from fund distribution with non existing id
    * configure headers = headersAdmin
    * def orderLineResponse = call getOrderLine { poLineId: #(brokenPoLineId) }
    * def orderLine = orderLineResponse.response
    * set orderLine.fundDistribution[0].encumbrance = nonExistingEncumbranceId
    Given path 'orders/order-lines', brokenPoLineId
    And request orderLine
    When method PUT
    Then status 204


  Scenario: Start rollover <rolloverId> for ledger <ledgerId>
    * configure headers = headersUser

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
        "needCloseBudgets": true,
        "rolloverType": "Commit",
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "adjustAllocation": 0.0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "addAvailableTo" : "Available"
          }
        ],
        "encumbrancesRollover": [
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


  Scenario: Wait for rollover to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


  Scenario: Check rollover logs for rolloverId=<rolloverId>
    Given path 'finance/ledger-rollovers-logs', rolloverId
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Commit'


  Scenario: Check rollover statuses rolloverId=<rolloverId>
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


  Scenario: Check new budget after rollover
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def newBudgetId = $.budgets[0].id

    Given path 'finance/budgets', newBudgetId
    When method GET
    Then status 200
    And match response.allocated == 100
    And match response.available == 50
    And match response.unavailable == 50
    And match response.netTransfers == 0
    And match response.encumbered == 50


  Scenario Outline: Check encumbrances and order lines after rollover
    * def orderId = <orderId>
    * def poLineId = <poLineId>
    * def amount = <amount>
    * def initialAmountEncumbered = <initialAmountEncumbered>

    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = response.transactions[0]
    * def encumbranceId = transaction.id
    And match transaction.amount == amount
    And match transaction.encumbrance.status == 'Unreleased'
    And match transaction.encumbrance.amountExpended == 0
    And match transaction.encumbrance.initialAmountEncumbered == initialAmountEncumbered

    * configure headers = headersAdmin
    * def orderLineResponse = call getOrderLine { poLineId: #(poLineId) }
    * def response = orderLineResponse.response
    And match response.fundDistribution[0].encumbrance == encumbranceId

    Examples:
      | orderId          | poLineId         | amount   | initialAmountEncumbered |
      | brokenOrderId    | brokenPoLineId   | 20       | 20                      |
      | regularOrderId   | regularPoLineId  | 30       | 30                      |