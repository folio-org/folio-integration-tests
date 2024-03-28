@parallel=false
# for https://issues.folio.org/browse/MODFISTO-477
Feature: Remove fund distribution after rollover from open order with re-encumber flag is false

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
    * def orderId = callonce uuid7
    * def poLineId = callonce uuid8

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


  Scenario: Create an order
    * def v = callonce createOrder { id: #(orderId), orderType: 'One-Time', reEncumber: false }


  Scenario: Create an order line
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }


  Scenario: Open the order
    * def v = callonce openOrder { orderId: "#(orderId)" }


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
            "adjustAllocation": 0,
            "rolloverBudgetValue": "None",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
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
    And match response.available == 100
    And match response.unavailable == 0
    And match response.netTransfers == 0
    And match response.encumbered == 0


  Scenario: Check encumbrance after rollover
    * configure headers = headersAdmin

    Given path 'finance-storage/transactions'
    And param query = 'fromFundId==' + fundId + ' AND fiscalYearId==' + toFiscalYearId + ' AND encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = response.transactions[0]
    And match transaction.amount == 0
    And match transaction.encumbrance.status == 'Released'
    And match transaction.encumbrance.amountExpended == 0
    And match transaction.encumbrance.initialAmountEncumbered == 0
    And match transaction.encumbrance.reEncumber == false


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


  Scenario: Remove fund distribution from POL
    * configure headers = headersUser
    * def orderLineResponse = call getOrderLine { poLineId: #(poLineId) }
    * def orderLine = orderLineResponse.response
    * remove orderLine.fundDistributions[0]
    Given path 'orders/order-lines', poLineId
    And request orderLine
    When method PUT
    Then status 204