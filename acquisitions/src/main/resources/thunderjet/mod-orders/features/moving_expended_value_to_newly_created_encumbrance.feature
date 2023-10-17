@parallel=false
# for https://issues.folio.org/browse/MODORDERS-834
Feature: Moving expended amount when editing fund distribution for POL

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

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def budgetId1 = callonce uuid3
    * def budgetId2 = callonce uuid4
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId = callonce uuid8
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = callonce uuid9
    * def fyId2 = callonce uuid10
    * def ledgerId = callonce uuid11
    * def rolloverId = callonce uuid12
    * def previewExpendedRolloverId = callonce uuid13
    * def previewRemainingRolloverId = callonce uuid14
    * def previewInitialAmountEncumberedRolloverId = callonce uuid15


  Scenario: Create fiscal years and associated ledger
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId1), code: 'TESTFY0001', periodStart: #(periodStart1), periodEnd: #(periodEnd1), series: 'TESTFY' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(fyId2), code: 'TESTFY0002', periodStart: #(periodStart2), periodEnd: #(periodEnd2), series: 'TESTFY' }
    * call createLedger { 'id': '#(ledgerId)', fiscalYearId: '#(fyId1)'}


  Scenario Outline: Prepare finances
    * def fundId = <fundId>
    * def fundCode = <fundCode>
    * def budgetId = <budgetId>
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', code: '#(fundCode)', ledgerId: '#(ledgerId)' }
    * call createBudget { id: '#(budgetId)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 1000 }

    Examples:
      | fundId  | fundCode    | budgetId  |
      | fundId1 | 'fundCode1' | budgetId1 |
      | fundId2 | 'fundCode2' | budgetId2 |


  Scenario: Create an order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      reEncumber: 'True'
    }
    """
    When method POST
    Then status 201

  Scenario: Create a po line
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId1
    * set poLine.fundDistribution[0].code = fundId1
    * set poLine.paymentStatus = 'Awaiting Payment'
    * set poLine.receiptStatus = 'Partially Received'

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

  Scenario: Open the order
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
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

  Scenario: Create a invoice line
    * print "Get the encumbrance id"
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance

    * print "Add an invoice line linked to the po line"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.poLineId = poLineId
    * set invoiceLine.fundDistributions[0].fundId = fundId1
    * set invoiceLine.fundDistributions[0].encumbrance = encumbranceId
    * set invoiceLine.total = 1
    * set invoiceLine.subTotal = 1
    * set invoiceLine.releaseEncumbrance = false
    * remove invoiceLine.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

  Scenario: Approve the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Check the budget after invoice approve
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 1
    And match $.available == 999
    And match $.awaitingPayment == 1
    And match $.expenditures == 0
    And match $.cashBalance == 1000
    And match $.encumbered == 0

  Scenario: Pay the invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Paid'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Check the budget after invoice paid
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 1
    And match $.available == 999
    And match $.awaitingPayment == 0
    And match $.expenditures == 1
    And match $.cashBalance == 999
    And match $.encumbered == 0

  Scenario: Update fundId in poLine
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * def oldEncumbranceId = $.fundDistribution[0].encumbrance
    * set poLine.fundDistribution[0].fundId = fundId2
    * set poLine.fundDistribution[0].code = fundId2
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    Given path 'finance/transactions', oldEncumbranceId
    When method GET
    Then status 404

  Scenario: Check the newly created encumbrance
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def newEncumbranceId = $.fundDistribution[0].encumbrance

    Given path 'finance/transactions', newEncumbranceId
    When method GET
    Then status 200
    And match $.amount == 0
    And match $.encumbrance.status == 'Unreleased'
    And match $.encumbrance.amountExpended == 1
    And match $.encumbrance.amountAwaitingPayment == 0


  Scenario: Check the previous budget
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 1
    And match $.available == 999
    And match $.awaitingPayment == 0
    And match $.expenditures == 1
    And match $.encumbered == 0

  Scenario: Check the current budget
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 0
    And match $.available == 1000
    And match $.awaitingPayment == 0
    And match $.expenditures == 0
    And match $.encumbered == 0

  Scenario: Start preview rollover with based on Expended
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewExpendedRolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "rolloverType": "Preview",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
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
    And param query = 'ledgerRolloverId==' + previewExpendedRolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


  Scenario Outline: Check new budgets after preview rollover based on Expended
    * def fundId = <fundId>

    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND ledgerRolloverId==' + previewExpendedRolloverId
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.ledgerFiscalYearRolloverBudgets[0].id

    Given path 'finance/ledger-rollovers-budgets', budget_id
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.unavailable == <unavailable>
    And match response.awaitingPayment == <awaitingPayment>
    And match response.expenditures == <expenditures>
    And match response.encumbered == <encumbered>
    And match response.netTransfers == <netTransfers>

    # For fund2 encumbered should be 1, because we copy initialEncumbranceAmount and Expended from old encumbrance to new one
    # when editing order's fund distribution for paid or cancelled invoices and now we making rollover based on Expended
    Examples:
      | fundId   | allocated | available | unavailable | awaitingPayment | expenditures | encumbered | netTransfers |
      | fundId1  | 1000      | 1999      | 0           | 0               | 0            | 0          | 999          |
      | fundId2  | 1000      | 1999      | 1           | 0               | 0            | 1          | 1000         |


  Scenario: Start preview rollover with based on Remaining
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewRemainingRolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "rolloverType": "Preview",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
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


  Scenario Outline: Check new budgets after preview rollover based on Remaining
    * def fundId = <fundId>

    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND ledgerRolloverId==' + previewRemainingRolloverId
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.ledgerFiscalYearRolloverBudgets[0].id

    Given path 'finance/ledger-rollovers-budgets', budget_id
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.unavailable == <unavailable>
    And match response.awaitingPayment == <awaitingPayment>
    And match response.expenditures == <expenditures>
    And match response.encumbered == <encumbered>
    And match response.netTransfers == <netTransfers>

    # For fund2 encumbered should be 0, because after editing order's fund distribution for paid or cancelled invoices
    # encumbrance amount is 0 and we making rollover based on this remaining amount
    Examples:
      | fundId   | allocated | available | unavailable | awaitingPayment | expenditures | encumbered | netTransfers |
      | fundId1  | 1000      | 1999      | 0           | 0               | 0            | 0          | 999          |
      | fundId2  | 1000      | 2000      | 0           | 0               | 0            | 0          | 1000         |


  Scenario: Start preview rollover with based on Initial Amount Encumbered
    Given path 'finance/ledger-rollovers'
    And request
    """
      {
        "id": "#(previewInitialAmountEncumberedRolloverId)",
        "ledgerId": "#(ledgerId)",
        "fromFiscalYearId": "#(fyId1)",
        "toFiscalYearId": "#(fyId2)",
        "rolloverType": "Preview",
        "restrictEncumbrance": true,
        "restrictExpenditures": true,
        "needCloseBudgets": true,
        "budgetsRollover": [
          {
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
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


  Scenario Outline: Check new budgets after preview rollover based on Initial Amount Encumbered
    * def fundId = <fundId>

    Given path 'finance/ledger-rollovers-budgets'
    And param query = 'fundId==' + fundId + ' AND ledgerRolloverId==' + previewInitialAmountEncumberedRolloverId
    And retry until response.totalRecords > 0
    When method GET
    Then status 200
    * def budget_id = $.ledgerFiscalYearRolloverBudgets[0].id

    Given path 'finance/ledger-rollovers-budgets', budget_id
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.unavailable == <unavailable>
    And match response.awaitingPayment == <awaitingPayment>
    And match response.expenditures == <expenditures>
    And match response.encumbered == <encumbered>
    And match response.netTransfers == <netTransfers>

    # For fund2 encumbered should be 1, because we copy initialEncumbranceAmount and Expended from old encumbrance to new one
    # when editing order's fund distribution for paid or cancelled invoices and now we making rollover based on Initial Encumbrance
    Examples:
      | fundId   | allocated | available | unavailable | awaitingPayment | expenditures | encumbered | netTransfers |
      | fundId1  | 1000      | 1999      | 0           | 0               | 0            | 0          | 999          |
      | fundId2  | 1000      | 1999      | 1           | 0               | 0            | 1          | 1000         |


  Scenario: Start rollover
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
            "rolloverAllocation": true,
            "adjustAllocation": 0,
            "rolloverBudgetValue": "Available",
            "setAllowances": false,
            "allowableEncumbrance": 100,
            "allowableExpenditure": 100
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
    * call pause 1000


  Scenario: Wait for rollover to end
    * configure retry = { count: 10, interval: 500 }
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus != 'In Progress'
    When method GET
    Then status 200


  Scenario: Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].budgetsClosingRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].ordersRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].financialRolloverStatus == 'Success'
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'


  Scenario: Check rollover errors
    Given path 'finance/ledger-rollovers-errors'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  Scenario Outline: Check the new budgets after common rollover
    * def fundId = <fundId>
    Given path 'finance/budgets'
    And param query = 'fiscalYearId==' + fyId2 + ' AND fundId==' + fundId
    When method GET
    Then status 200
    * def budget_id = $.budgets[0].id

    Given path 'finance/budgets', budget_id
    When method GET
    Then status 200

    And match response.allocated == <allocated>
    And match response.available == <available>
    And match response.unavailable == <unavailable>
    And match response.awaitingPayment == <awaitingPayment>
    And match response.expenditures == <expenditures>
    And match response.encumbered == <encumbered>
    And match response.netTransfers == <netTransfers>

    Examples:
      | fundId   | allocated | available | unavailable | awaitingPayment | expenditures | encumbered | netTransfers |
      | fundId1  | 1000      | 1999      | 0           | 0               | 0            | 0          | 999          |
      | fundId2  | 1000      | 1999      | 1           | 0               | 0            | 1          | 1000         |


  # Old encumbrance has been deleted, so in new FY we also expect only one encumbrance from the second fund
  # Transaction Amount and Encumbrance Initial Amount Encumbered is equals to 1, because rollover type was based on Expended
  # And we had 1$ expended in transaction from previous FY
  Scenario: Check encumbrances
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance AND fiscalYearId==' + fyId2
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.transactions[0].fromFundId == fundId2
    And match $.transactions[0].amount == 1
    And match $.transactions[0].encumbrance.sourcePurchaseOrderId == orderId
    And match $.transactions[0].encumbrance.sourcePoLineId == poLineId
    And match $.transactions[0].encumbrance.initialAmountEncumbered == 1
    And match $.transactions[0].encumbrance.amountAwaitingPayment == 0
    And match $.transactions[0].encumbrance.amountExpended == 0
    And match $.transactions[0].encumbrance.status == 'Unreleased'