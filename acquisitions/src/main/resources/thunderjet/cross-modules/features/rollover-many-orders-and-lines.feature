# For MODORDERS-1388
Feature: Rollover many orders and lines

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


  Scenario: Rollover many orders and lines using different ledgers
    * def series = call random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId1 = call uuid
    * def ledgerId2 = call uuid
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def budgetId3 = call uuid
    * def budgetId4 = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def rolloverId1 = call uuid
    * def rolloverId2 = call uuid

  ## Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: '#(series + "0001")', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: '#(series + "0002")', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: '#(series)' }
    * def v = call createLedger { id: #(ledgerId1), fiscalYearId: #(fyId1) }
    * def v = call createLedger { id: #(ledgerId2), fiscalYearId: #(fyId1) }

  ## Create funds and budgets
    * def v = call createFund { id: #(fundId1), code: #(fundId1), ledgerId: #(ledgerId1) }
    * def v = call createFund { id: #(fundId2), code: #(fundId2), ledgerId: #(ledgerId2) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId1), fiscalYearId: #(fyId1), allocated: 10000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId2), fiscalYearId: #(fyId1), allocated: 10000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId3), fundId: #(fundId1), fiscalYearId: #(fyId2), allocated: 10000, status: 'Active' }
    * def v = call createBudget { id: #(budgetId4), fundId: #(fundId2), fiscalYearId: #(fyId2), allocated: 10000, status: 'Active' }

  ## Create 450 orders
    * def orderParameters = []
    * def createOrderParameterArray =
    """
    function() {
      for (let i=0; i<450; i++) {
        orderParameters.push({ id: uuid(), orderType: 'One-Time', reEncumber: false });
      }
    }
    """
    * eval createOrderParameterArray()
    * def v = call createOrder orderParameters

  ## Create the order lines
    * def lineParameters = []
    * def createLineParameterArray =
    """
    function() {
      for (let i=0; i<450; i++) {
        for (let j=0; j<(i < 10 || i > 440 ? 210 : 1); j++) {
          lineParameters.push({ id: uuid(), orderId: orderParameters[i].id, fundId: i < 250 ? fundId1 : fundId2 });
        }
      }
    }
    """
    * eval createLineParameterArray()
    * def v = call createOrderLine lineParameters

  # Open all the orders
    * def openOrderParameters = []
    * def openOrderParameterArray =
    """
    function() {
      for (let i=0; i<450; i++) {
        openOrderParameters.push({ orderId: orderParameters[i].id });
      }
    }
    """
    * eval openOrderParameterArray()
    * def v = call openOrder openOrderParameters

  # Close some orders
    * def closeOrderParameters = []
    * def closeOrderParameterArray =
      """
    function() {
      for (let i=400; i<450; i++) {
        closeOrderParameters.push({ orderId: orderParameters[i].id });
      }
    }
    """
    * eval closeOrderParameterArray()
    * def v = call closeOrder closeOrderParameters

  ## Rollover the 2 ledgers
    * def budgetsRollover = [ { rolloverAllocation: false, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false } ]
    * def encumbrancesRollover = [ { orderType: 'One-time', basedOn: 'Remaining', increaseBy: 0 } ]
    * table rollovers
      | id          | ledgerId  | fromFiscalYearId | toFiscalYearId | budgetsRollover | encumbrancesRollover |
      | rolloverId1 | ledgerId1 | fyId1            | fyId2          | budgetsRollover | encumbrancesRollover |
      | rolloverId2 | ledgerId2 | fyId1            | fyId2          | budgetsRollover | encumbrancesRollover |
    * def v = call rollover rollovers

  ## Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']

    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == ['Success']

  ## Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId1
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

  ## Check encumbrance links and encumbrances
    Given path 'orders/order-lines', lineParameters[0].id
    When method GET
    Then status 200
    * def encumbrancesId = $.fundDistribution[0].encumbrance
    Given path 'finance/transactions', encumbrancesId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.fromFundId == fundId1
    And match $.fiscalYearId == fyId2

    Given path 'orders/order-lines', lineParameters[2390].id
    When method GET
    Then status 200
    * def encumbrancesId = $.fundDistribution[0].encumbrance
    Given path 'finance/transactions', encumbrancesId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.fromFundId == fundId2
    And match $.fiscalYearId == fyId2

    * def lastLineIndex = lineParameters.length - 1
    Given path 'orders/order-lines', lineParameters[lastLineIndex].id
    When method GET
    Then status 200
    And match $.fundDistribution[0].encumbrance == '#notpresent'
