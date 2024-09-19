# For MODORDERS-1162
Feature: Rollover with no settings

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * call loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain' }

    * configure headers = headersUser

    * callonce variables

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def validateOrderLineEncumbranceLinks = read('classpath:thunderjet/mod-orders/reusable/validate-order-line-encumbrance-links.feature')

  @Positive
  Scenario: Rollover with no settings
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fiscalYearId1 = call uuid
    * def fiscalYearId2 = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid

    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def orderId3 = call uuid
    * def orderId4 = call uuid

    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid

    * def ongoingObj = { "interval": 123, "isSubscription": true, "renewalDate": "2022-05-08T00:00:00.000+00:00" }

    * def rolloverId = call uuid

    * table orders
      | id       | orderId  | orderType  | reEncumber | ongoing    |
      | orderId1 | orderId1 | 'One-Time' | true       | null       |
      | orderId2 | orderId2 | 'One-Time' | false      | null       |
      | orderId3 | orderId3 | 'Ongoing'  | true       | ongoingObj |
      | orderId4 | orderId4 | 'Ongoing'  | false      | ongoingObj |

    * table orderLines
      | id        | orderId  | listUnitPrice |
      | poLineId1 | orderId1 | 10.0          |
      | poLineId2 | orderId2 | 10.0          |
      | poLineId3 | orderId3 | 10.0          |
      | poLineId4 | orderId4 | 10.0          |

    ### 1. Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fiscalYearId1)', code: 'TESTFYA0012', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: 'TESTFYA' }

    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fiscalYearId2)', code: 'TESTFYA0013', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: 'TESTFYA' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId1)' }

    ### 2. Create fund and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId2)', allocated: 1000, status: 'Active' }

    ### 3. Create order and order line
    * def v = call createOrder orders
    * def v = call createOrderLine orderLines

    ### 4. Open orders
    * def v = call openOrder orders

    ### 5. Check encumbrance transactions in the previous year before rollover
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fiscalYearId1
    When method GET
    Then status 200
    * def encumbrances = $.transactions
    And match $.totalRecords == orders.length
    And match each $.transactions[*].amount == 10.0
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == 10.0

    ### 6. Check encumbrance links before rollover (POLs point to the old encumbrances)
    * def v = call validateOrderLineEncumbranceLinks orderLines

    ### 7. Start rollover with no settings
    Given path 'finance/ledger-rollovers'
    And request
      """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fiscalYearId1)",
        "toFiscalYearId": "#(fiscalYearId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [{
          "rolloverAllocation": false,
          "adjustAllocation": 0,
          "rolloverBudgetValue": "None",
          "setAllowances": false,
          "allowableEncumbrance": 100,
          "allowableExpenditure": 100
        }],
        "encumbrancesRollover": []
      }
      """
    When method POST
    Then status 201
    * call pause 1500

    ### 8. Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match each response.ledgerFiscalYearRolloverProgresses[*].budgetsClosingRolloverStatus == 'Success'
    And match each response.ledgerFiscalYearRolloverProgresses[*].ordersRolloverStatus == 'Success'
    And match each response.ledgerFiscalYearRolloverProgresses[*].financialRolloverStatus == 'Success'
    And match each response.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == 'Success'

    ### 9. Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    ### 10. Check encumbrance transactions in the new year
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fiscalYearId2
    When method GET
    Then status 200
    * def encumbrances = $.transactions
    And match $.totalRecords == orders.length
    And match each $.transactions[*].amount == 0.0
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Released'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == 0.0

    ### 11. Check encumbrance links after rollover (POLs point to the new encumbrances)
    * def v = call validateOrderLineEncumbranceLinks orderLines