# For MODFISTO-371
@parallel=false
Feature: Test ledger fiscal year rollover based on cash balance value

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def invoiceId = callonce uuid6
    * def invoiceLineId = callonce uuid7
    * def invoiceLineId2 = callonce uuid16
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = callonce uuid8
    * def fyId2 = callonce uuid9
    * def ledgerId = callonce uuid10
    * def previewFirstFlowId = callonce uuid11
    * def previewSecondFlowId = callonce uuid12
    * def previewThirdFlowId = callonce uuid13
    * def previewFourthFlowId = callonce uuid14
    * def commonRolloverId = callonce uuid15


  Scenario: Create fiscal years and associated ledger
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: 'TESTFY0003', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: 'TESTFY' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: 'TESTFY0004', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: 'TESTFY' }
    * def v = call createLedger { 'id': '#(ledgerId)', fiscalYearId: '#(fyId1)'}


  Scenario: Prepare finances
    * def fundCode = fundId
    * def v = call createFund { id: '#(fundId)', code: '#(fundCode)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 100 }


  Scenario: Create an order
    * def v = call createOrder { id: '#(orderId)' }

  Scenario Outline: Create a po line with unit price <unitPrice>
    * def unitPrice = <unitPrice>
    * def poLineId = <poLineId>
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: '#(unitPrice)', paymentStatus: 'Awaiting Payment', receiptStatus: 'Partially Received' }

    Examples:
      | unitPrice   | poLineId    |
      | 40.0        | poLineId1   |
      | 10.0        | poLineId2   |

  Scenario: Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

  Scenario: Create an invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

  Scenario: Create an invoice line from the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId1)', fundId: '#(fundId)', total: 50 }

  Scenario: Create a credit invoice line from the po line
    * def v = call createInvoiceLineFromPoLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', poLineId: '#(poLineId1)', fundId: '#(fundId)', total: -10 }

  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

  Scenario: Check the budget before preview rollover
    * configure headers = headersAdmin
    Given path 'finance-storage/budgets', budgetId
    When method GET
    Then status 200

    And match $.available == 50
    And match $.encumbered == 10
    And match $.allocated == 100
    And match $.cashBalance == 60
    And match $.netTransfers == 0
    And match $.allocationTo == 0
    And match $.expenditures == 50
    And match $.credits == 10
    And match $.totalFunding == 100
    And match $.allocationFrom == 0
    And match $.awaitingPayment == 0
    And match $.initialAllocation == 100

    * def budgetResponse = response

    # Updating budget with wrong data, these should be fixed by rollover scripts
    * set budgetResponse.cashBalance = 40
    * set budgetResponse.unavailable = 40

    Given path 'finance-storage/budgets', budgetId
    And request budgetResponse
    When method PUT
    Then status 204

  Scenario Outline: Start preview rollover based on CashBalance

    * def rolloverId = <id>
    * def addAvailableTo = <addAvailableTo>
    * def rolloverAllocation = <rolloverAllocation>

    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(rolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "rolloverType": "Preview",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": #(rolloverAllocation),
            "addAvailableTo": "#(addAvailableTo)",
            "rolloverBudgetValue": "CashBalance"
          }
        ],
        "encumbrancesRollover": []
      }
    """
    When method POST
    Then status 201

    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200

    Examples:
      | id                   | addAvailableTo | rolloverAllocation |
      | previewFirstFlowId   | 'Allocation'   | true               |
      | previewSecondFlowId  | 'Available'    | true               |
      | previewThirdFlowId   | 'Allocation'   | false              |
      | previewFourthFlowId  | 'Available'    | false              |


  Scenario Outline: Check new budgets after preview rollover based on CashBalance
    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND ledgerRolloverId==' + <id>
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.ledgerFiscalYearRolloverBudgets[0].id

    Given path 'finance/ledger-rollovers-budgets', budget_id
    When method GET
    Then status 200

    And match response.available == <available>
    And match response.allocated == <allocated>
    And match response.cashBalance == <cashBalance>
    And match response.netTransfers == <netTransfers>
    And match response.totalFunding == <totalFunding>
    And match response.allocationTo == <allocationTo>
    And match response.allocationFrom == <allocationFrom>
    And match response.initialAllocation == <initialAllocation>

    Examples:
      | id                   | initialAllocation | allocationTo | allocationFrom | allocated | netTransfers | totalFunding | cashBalance | available |
      | previewFirstFlowId   | 160               | 0            | 0              | 160       | 0            | 160          | 160         | 160       |
      | previewSecondFlowId  | 100               | 0            | 0              | 100       | 60           | 160          | 160         | 160       |
      | previewThirdFlowId   | 60                | 0            | 0              | 60        | 0            | 60           | 60          | 60        |
      | previewFourthFlowId  | 0                 | 0            | 0              | 0         | 60           | 60           | 60          | 60        |


  Scenario: Start rollover
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(commonRolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "addAvailableTo": "Allocation",
            "rolloverBudgetValue": "CashBalance"
          }
        ],
        "encumbrancesRollover": [
          {
            "orderType": "One-time",
            "basedOn": "Expended",
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
    And param query = 'ledgerRolloverId==' + commonRolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


  Scenario: Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + commonRolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


  Scenario: Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + commonRolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  Scenario: Check the new budgets after common rollover
    Given path 'finance/budgets'
    And param query = 'fiscalYearId==' + fyId2 + ' AND fundId==' + fundId
    When method GET
    Then status 200
    * def budget_id = $.budgets[0].id

    Given path 'finance/budgets', budget_id
    When method GET
    Then status 200

    And match response.available == 160
    And match response.allocated == 160
    And match response.cashBalance == 160
    And match response.netTransfers == 0
    And match response.totalFunding == 160
    And match response.allocationTo == 0
    And match response.allocationFrom == 0
    And match response.initialAllocation == 160
