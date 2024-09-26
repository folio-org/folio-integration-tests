# For MODINVOICE-555
Feature: Rollover and pay invoice using past fiscal year

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

  @Positive
  Scenario: Rollover and pay invoice using past fiscal year
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
    * def orderId5 = call uuid
    * def orderId6 = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid
    * def poLineId5 = call uuid
    * def poLineId6 = call uuid

    * def rolloverId = call uuid

    * def invoiceId1 = call uuid
    * def invoiceId2 = call uuid
    * def invoiceId3 = call uuid
    * def invoiceId4 = call uuid
    * def invoiceId5 = call uuid
    * def invoiceId6 = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def invoiceLineId3 = call uuid
    * def invoiceLineId4 = call uuid
    * def invoiceLineId5 = call uuid
    * def invoiceLineId6 = call uuid

    ### 1. Create fiscal years and associated ledgers
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fiscalYearId1)', code: 'TESTFYB0012', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: 'TESTFYB' }

    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fiscalYearId2)', code: 'TESTFYB0013', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: 'TESTFYB' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId1)' }

    ### 2. Create fund and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * table budgets
      | id        | fundId | fiscalYearId  | allocated | status   |
      | budgetId1 | fundId | fiscalYearId1 | 1000      | 'Active' |
      | budgetId2 | fundId | fiscalYearId2 | 1000      | 'Active' |
    * def v = call createBudget budgets
    * configure headers = headersUser

    ### 3. Create orders and order lines
    * def emptyOngoingObj = { }
    * def ongoingObj = { "interval": 123, "isSubscription": true, "renewalDate": "2022-05-08T00:00:00.000+00:00" }
    * table orders
      | id       | orderId  | orderType  | reEncumber | ongoing         |
      | orderId1 | orderId1 | 'One-Time' | true       | null            |
      | orderId2 | orderId2 | 'One-Time' | false      | null            |
      | orderId3 | orderId3 | 'Ongoing'  | true       | emptyOngoingObj |
      | orderId4 | orderId4 | 'Ongoing'  | false      | emptyOngoingObj |
      | orderId5 | orderId5 | 'Ongoing'  | true       | ongoingObj      |
      | orderId6 | orderId6 | 'Ongoing'  | false      | ongoingObj      |
    * def v = call createOrder orders

    * table orderLines
      | id        | orderId  | orderType  | listUnitPrice |
      | poLineId1 | orderId1 | 'One-Time' | 50.0          |
      | poLineId2 | orderId2 | 'One-Time' | 50.0          |
      | poLineId3 | orderId3 | 'Ongoing'  | 50.0          |
      | poLineId4 | orderId4 | 'Ongoing'  | 50.0          |
      | poLineId5 | orderId5 | 'Ongoing'  | 50.0          |
      | poLineId6 | orderId6 | 'Ongoing'  | 50.0          |
    * def v = call createOrderLine orderLines

    ### 4. Open orders
    * def v = call openOrder orders

    ### 5. Check encumbrance transactions in the previous year before rollover
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance And fiscalYearId==' + fiscalYearId1
    When method GET
    Then status 200
    And match $.totalRecords == orders.length
    And match each $.transactions[*].amount == 50.0
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == 'Unreleased'
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == 50.0

    ### 6. Start rollover with settings
    # Rollover with 3 order types: One-Time, Ongoing and Ongoing with subscription
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
        "needCloseBudgets": false,
        "budgetsRollover": [{
          "addAvailableTo": "Allocation",
          "rolloverBudgetValue": "None",
          "rolloverAllocation": true
        }],
        "encumbrancesRollover": [
          { "orderType": "Ongoing", "basedOn": "InitialAmount" },
          { "orderType": "Ongoing-Subscription", "basedOn": "InitialAmount" },
          { "orderType": "One-time", "basedOn": "InitialAmount" }
        ]
      }
      """
    When method POST
    Then status 201
    * call pause 1500

    ### 7. Check rollover statuses
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match each $.ledgerFiscalYearRolloverProgresses[*].budgetsClosingRolloverStatus == 'Success'
    And match each $.ledgerFiscalYearRolloverProgresses[*].ordersRolloverStatus == 'Success'
    And match each $.ledgerFiscalYearRolloverProgresses[*].financialRolloverStatus == 'Success'
    And match each $.ledgerFiscalYearRolloverProgresses[*].overallRolloverStatus == 'Success'

    ### 8. Check encumbrance transactions in new year
    * table newYearEncumbrances
      | fiscalYearId  | reEncumber | amount | status       | totalRecords |
      | fiscalYearId2 | true       | 50.0   | 'Unreleased' | 3            |
      | fiscalYearId2 | false      | 0.0    | 'Released'   | 3            |
    * def v = call read('@CheckEncumbranceTransactionsInNewYear') newYearEncumbrances

    ### 9. Create invoices
    * table invoices
      | id         | invoiceId  | fiscalYearId  |
      | invoiceId1 | invoiceId1 | fiscalYearId1 |
      | invoiceId2 | invoiceId2 | fiscalYearId1 |
      | invoiceId3 | invoiceId3 | fiscalYearId1 |
      | invoiceId4 | invoiceId4 | fiscalYearId1 |
      | invoiceId5 | invoiceId5 | fiscalYearId1 |
      | invoiceId6 | invoiceId6 | fiscalYearId1 |
    * def v = call createInvoice invoices

    ### 10. Add invoice lines
    * table invoiceLines
      | invoiceLineId  | invoiceId  | poLineId  | total | fundId | fiscalYearId  |
      | invoiceLineId1 | invoiceId1 | poLineId1 | 50.0  | fundId | fiscalYearId1 |
      | invoiceLineId2 | invoiceId2 | poLineId2 | 50.0  | fundId | fiscalYearId1 |
      | invoiceLineId3 | invoiceId3 | poLineId3 | 50.0  | fundId | fiscalYearId1 |
      | invoiceLineId4 | invoiceId4 | poLineId4 | 50.0  | fundId | fiscalYearId1 |
      | invoiceLineId5 | invoiceId5 | poLineId5 | 50.0  | fundId | fiscalYearId1 |
      | invoiceLineId6 | invoiceId6 | poLineId6 | 50.0  | fundId | fiscalYearId1 |
    * def v = call createInvoiceLine invoiceLines

    ### 11. Approve the invoices
    * def v = call approveInvoice invoices

    ### 12. Check pending payments were created in past fiscal year
    * def v = call read('@CheckPendingPaymentsWereCreatedInPastFiscalYear') invoiceLines

    ### 13. Pay the invoices
    * def v = call payInvoice invoices

    ### 14. Check order line statuses
    * def v = call read('@CheckOrderLineStatuses') orderLines

    ### 15. Check the past budget
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    And match $.unavailable == 300
    And match $.available == 700
    And match $.cashBalance == 700
    And match $.overExpended == 0
    And match $.encumbered == 0

    ### 16. Check the current budget
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 150
    And match $.available == 1850
    And match $.cashBalance == 2000
    And match $.overExpended == 0
    And match $.encumbered == 150

  ### Local reusable functions, @ignore indicator excludes these scenarios from test reports

  @ignore @CheckEncumbranceTransactionsInNewYear
  Scenario: Check encumbrance transactions in new year
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance And fiscalYearId==' + fiscalYearId + ' And encumbrance.reEncumber==' + reEncumber
    When method GET
    Then status 200
    And match $.totalRecords == totalRecords
    And match each $.transactions[*].amount == amount
    And match each $.transactions[*].currency == 'USD'
    And match each $.transactions[*].encumbrance.orderStatus == 'Open'
    And match each $.transactions[*].encumbrance.status == status
    And match each $.transactions[*].encumbrance.initialAmountEncumbered == amount

  @ignore @CheckPendingPaymentsWereCreatedInPastFiscalYear
  Scenario: Check pending payments were created in past fiscal year
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' And transactionType==Pending payment'
    When method GET
    Then status 200
    And match each $.transactions[*].fiscalYearId == fiscalYearId

  @ignore @CheckOrderLineStatuses
  Scenario: Check order line statuses
    Given path 'orders/order-lines', id
    When method GET
    Then status 200
    * def paymentStatus = orderType == 'One-Time' ? 'Fully Paid' : 'Ongoing'
    * def receiptStatus = orderType == 'One-Time' ? 'Awaiting Receipt' : 'Ongoing'
    And match $.paymentStatus == paymentStatus
    And match $.receiptStatus == receiptStatus