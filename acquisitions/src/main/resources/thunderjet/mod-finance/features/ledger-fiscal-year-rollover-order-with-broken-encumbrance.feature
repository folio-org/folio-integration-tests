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

  Scenario: Verify that order with broken encumbrance will be rolled over successfully
    * print "Prepare fiscal year with #(fromFiscalYearId) for rollover"
    * configure headers = headersAdmin
    * def code = fromYear
    * def periodStart = code + '-01-01T00:00:00Z'
    * def periodEnd = code + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fromFiscalYearId), code: #(codePrefix + code), periodStart: #(periodStart), periodEnd: #(periodEnd) }


    * print "Prepare fiscal year with #(toFiscalYearId) for rollover"
    * def code = toYear
    * def periodStart = code + '-01-01T00:00:00Z'
    * def periodEnd = code + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(toFiscalYearId), code: #(codePrefix + code), periodStart: #(periodStart), periodEnd: #(periodEnd) }


    * print "Prepare finances"
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fromFiscalYearId) }
    * def v = call createFund { id: #(fundId),  code: #(fundId), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), fiscalYearId: #(fromFiscalYearId), allocated: 100 }


    * print "Create order 1 and open them"
    * def v = call createOrder { id: #(brokenOrderId), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(brokenPoLineId), orderId: #(brokenOrderId), fundId: #(fundId), listUnitPrice: 20 }
    * def v = call openOrder { orderId: "#(brokenOrderId)" }


    * print "Create order 2 and open them"
    * def v = call createOrder { id: #(regularOrderId), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(regularPoLineId), orderId: #(regularOrderId), fundId: #(fundId), listUnitPrice: 30 }
    * def v = call openOrder { orderId: "#(regularOrderId)" }


    * print "Replace encumbrance from fund distribution with non existing id"
    * def orderLineResponse = call getOrderLine { poLineId: #(brokenPoLineId) }
    * def orderLine = orderLineResponse.response
    * set orderLine.fundDistribution[0].encumbrance = nonExistingEncumbranceId
    Given path 'orders/order-lines', brokenPoLineId
    And request orderLine
    When method PUT
    Then status 204


    * print "Start rollover #(rolloverId) for ledger #(ledgerId)"
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


    * print "Wait for rollover to end"
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


    * print "Check rollover logs for rolloverId=#(rolloverId)"
    Given path 'finance/ledger-rollovers-logs', rolloverId
    When method GET
    Then status 200
    And match response.rolloverStatus == 'Success'
    And match response.ledgerRolloverType == 'Commit'


    * print "Check rollover statuses rolloverId=#(rolloverId)"
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


    * print "Check new budget after rollover"
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


    * print "Check that new encumbrance was created for order with broken encumbrance after rollover"
    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + brokenOrderId
    When method GET
    Then status 200
    * def transaction = response.transactions[0]
    * def encumbranceId = transaction.id
    And match transaction.amount == 20
    And match transaction.encumbrance.status == 'Unreleased'
    And match transaction.encumbrance.amountExpended == 0
    And match transaction.encumbrance.initialAmountEncumbered == 20


    * print "Ensure that link within the order with broken encumbrance referencing encumbrance have been updated to reflect encumbrance created in the new fiscal year"
    * configure headers = headersAdmin
    * def orderLineResponse = call getOrderLine { poLineId: #(brokenPoLineId) }
    * def response = orderLineResponse.response
    And match response.fundDistribution[*].encumbrance contains encumbranceId