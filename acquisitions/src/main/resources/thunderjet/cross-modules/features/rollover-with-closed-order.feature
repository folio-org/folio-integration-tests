# For https://issues.folio.org/browse/MODORDERS-712
Feature: Rollover with closed order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def closeOrderRemoveLines = read('classpath:thunderjet/mod-orders/reusable/close-order-remove-lines.feature')


  Scenario: Rollover with closed order
    * def series = call random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def rolloverId = call uuid
    * def emptyEncumbrancePoLineId = call uuid

  ## Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: '#(series + "0001")', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: '#(series + "0002")', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: '#(series)' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fyId1) }


  ## Create fund and budgets
    * def v = call createFund { id: #(fundId), code: #(fundId), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId), fiscalYearId: #(fyId1), allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId), fiscalYearId: #(fyId2), allocated: 1000, status: 'Active' }


  ## Create the order and line
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }
    * def v = call createOrderLine { id: #(emptyEncumbrancePoLineId), orderId: #(orderId), fundId: #(fundId) }


  # Open and close the order
    * def v = call openOrder { orderId: #(orderId) }
    * def v = call closeOrderRemoveLines { orderId: #(orderId) }

  ## https://issues.folio.org/browse/MODORDERS-904
  ## Remove encumbrance from specific po line
  ## call endpoints other than mod-orders with admin token
    * configure headers = headersAdmin
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    * def emptyEncumbrancePoLine = response

  ## remove encumbrance from fundDistribution and save
    * remove emptyEncumbrancePoLine.fundDistribution[0].encumbrance
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    And request emptyEncumbrancePoLine
    When method PUT
    Then status 204
  ## get updated po line with empty encumbrance
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    * def emptyEncumbrancePoLineUpdated = response

  ## Start rollover
    * configure headers = headersUser
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
    * configure headers = headersAdmin
    Given path '/orders-storage/po-lines', emptyEncumbrancePoLineId
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.metadata.updatedDate == emptyEncumbrancePoLineUpdated.metadata.updatedDate
