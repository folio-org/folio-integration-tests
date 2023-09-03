# For https://issues.folio.org/browse/MODORDERS-712
@parallel=false
Feature: Rollover with closed order

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain' }
    * configure headers = headersUser

    * callonce variables
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = callonce uuid1
    * def fyId2 = callonce uuid2
    * def ledgerId = callonce uuid3
    * def fundId = callonce uuid4
    * def budgetId1 = callonce uuid5
    * def budgetId2 = callonce uuid6
    * def orderId = callonce uuid7
    * def poLineId = callonce uuid8
    * def rolloverId = callonce uuid9
    * def emptyEncumbrancePoLineId = callonce uuid10

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def closeOrder = read('classpath:thunderjet/mod-orders/reusable/close-order.feature')


  Scenario: Rollover with closed order
  ## Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: 'TESTFY0011', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: 'TESTFY' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: 'TESTFY0012', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: 'TESTFY' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fyId1) }


  ## Create fund and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId), code: #(fundId), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }


  ## Create the order and line
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }
    * def v = call createOrderLine { id: #(emptyEncumbrancePoLineId), orderId: #(orderId), fundId: #(fundId) }


  # Open and close the order
    * def v = call openOrder { orderId: #(orderId) }
    * def v = call closeOrder { orderId: #(orderId) }

  ## https://issues.folio.org/browse/MODORDERS-904
  ## Remove encumbrance from specific po line
  ## call endpoints other than mod-orders with admin token
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    * configure headers = headersAdmin
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    * def emptyEncumbrancePoLine = response

  ## remove encumbrance from fundDistribution and save
    * remove emptyEncumbrancePoLine.fundDistribution[0].encumbrance
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    * configure headers = headersAdmin
    And request emptyEncumbrancePoLine
    When method PUT
    Then status 204
  ## get updated po line with empty encumbrance
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    * configure headers = headersAdmin
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    * def emptyEncumbrancePoLineUpdated = response

  ## Start rollover
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": false,
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
            "basedOn": "Remaining",
            "increaseBy": 0
          }
        ]
      }
    """
    When method POST
    Then status 201
    * call pause 1500


  ## Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


  ## Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  ## Check encumbrance transactions
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2
    When method GET
    Then status 200
    And match $.totalRecords == 0


  ## Check encumbrance link
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.fundDistribution[0].encumbrance == '#notpresent'

  ## Check po line with empty encumbrance hasn't been modified after rollover
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    * configure headers = headersAdmin
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.metadata.updatedDate == emptyEncumbrancePoLineUpdated.metadata.updatedDate
