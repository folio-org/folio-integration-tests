@parallel=false
# for https://issues.folio.org/browse/MODORDERS-834
Feature: Test ledger fiscal year rollover based on cash balance value

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

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def invoiceId = callonce uuid6
    * def invoiceLineId = callonce uuid7
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
    * def v = call createFiscalYear { id: #(fyId1), code: 'TESTFY0001', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: 'TESTFY' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: 'TESTFY0002', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: 'TESTFY' }
    * call createLedger { 'id': '#(ledgerId)', fiscalYearId: '#(fyId1)'}


  Scenario: Prepare finances
    * def fundCode = fundId
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)', ledgerId: '#(ledgerId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 100 }


  Scenario: Create an order
    * configure headers = headersAdmin
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      reEncumber: 'False'
    }
    """
    When method POST
    Then status 201

  Scenario Outline: Create a po lines
    * configure headers = headersAdmin
    * copy poLine = orderLineTemplate
    * set poLine.id = <poLineId>
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = 'Awaiting Payment'
    * set poLine.receiptStatus = 'Partially Received'
    * set poLine.cost.listUnitPrice = <unitPrice>
    * set poLine.cost.poLineEstimatedPrice = <unitPrice>

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    Examples:
      | unitPrice   | poLineId    |
      | 40.0        | poLineId1   |
      | 10.0        | poLineId2   |

  Scenario: Open the order
    * configure headers = headersAdmin
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

  Scenario: Create an invoice
    * configure headers = headersAdmin
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

  Scenario: Create a invoice line
    * configure headers = headersAdmin
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId1
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.total = 40
    * set invoiceLine.subTotal = 40
    * remove invoiceLine.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

  Scenario: Approve the invoice
    * configure headers = headersAdmin
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Pay the invoice
    * configure headers = headersAdmin
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Check the budget before preview rollover
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200

    And match $.available == 50
    And match $.encumbered == 10
    And match $.allocated == 100
    And match $.cashBalance == 60
    And match $.netTransfers == 0
    And match $.allocationTo == 0
    And match $.expenditures == 40
    And match $.totalFunding == 100
    And match $.allocationFrom == 0
    And match $.awaitingPayment == 0
    And match $.initialAllocation == 100

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
