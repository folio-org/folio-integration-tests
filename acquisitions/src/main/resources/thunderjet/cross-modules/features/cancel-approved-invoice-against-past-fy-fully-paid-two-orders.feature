# For MODINVOICE-573, UINV-577, MODINVOICE-585, https://foliotest.testrail.io/index.php?/cases/view/700861
Feature: POL Payment Status Updated To Fully Paid For Two Orders When Cancelling Invoice Against Previous Fiscal Year

  Background:
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 500 }

    * callonce variables

  @C700861
  @Positive
  Scenario: POL Payment Status Updated To Fully Paid For Two Orders When Cancelling Invoice Against Previous Fiscal Year
    # 1. Generate Unique Identifiers For This Test Scenario
    * def series = call random_string
    * def fromYear = call getCurrentYear
    * def toYear = parseInt(fromYear) + 1
    * def fyId1 = call uuid
    * def fyId2 = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId1 = call uuid
    * def orderId2 = call uuid
    * def orderLineId1 = call uuid
    * def orderLineId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid
    * def rolloverId = call uuid

    # 2. Create Fiscal Year #1 (Current Year) And Fiscal Year #2 (Next Year) With Same Series
    * def periodStart1 = fromYear + '-01-01T00:00:00Z'
    * def periodEnd1 = fromYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId1)', code: '#(series + "0001")', periodStart: '#(periodStart1)', periodEnd: '#(periodEnd1)', series: '#(series)' }
    * def periodStart2 = toYear + '-01-01T00:00:00Z'
    * def periodEnd2 = toYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fyId2)', code: '#(series + "0002")', periodStart: '#(periodStart2)', periodEnd: '#(periodEnd2)', series: '#(series)' }

    # 3. Create Active Ledger, Fund, And Budgets For Both Fiscal Years
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fyId1)' }
    * def v = call createFund { id: '#(fundId)', code: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId)', fiscalYearId: '#(fyId1)', allocated: 1000, status: 'Active' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId)', fiscalYearId: '#(fyId2)', allocated: 1000, status: 'Active' }

    # 4. Create Two One-Time Orders With Re-Encumber Active, Each With One PO Line
    * def v = call createOrder { id: '#(orderId1)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(orderLineId1)', orderId: '#(orderId1)', fundId: '#(fundId)', listUnitPrice: 25.00 }
    * def v = call createOrder { id: '#(orderId2)', orderType: 'One-Time', reEncumber: true }
    * def v = call createOrderLine { id: '#(orderLineId2)', orderId: '#(orderId2)', fundId: '#(fundId)', listUnitPrice: 50.00 }

    # 5. Open Both Orders To Create Encumbrances In Fiscal Year #1
    * def v = call openOrder { orderId: '#(orderId1)' }
    * def v = call openOrder { orderId: '#(orderId2)' }

    # 6. Get Encumbrance IDs From Both PO Lines Before Rollover
    Given path 'orders/order-lines', orderLineId1
    When method GET
    Then status 200
    * def encumbranceId1 = $.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', orderLineId2
    When method GET
    Then status 200
    * def encumbranceId2 = $.fundDistribution[0].encumbrance

    # 7. Create Invoice For Fiscal Year #1 With Two Invoice Lines And Release Encumbrance Active, Then Approve
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(fyId1)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId1)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId1)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId1)', total: 25.00, releaseEncumbrance: true }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId2)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId2)', fundId: '#(fundId)', encumbranceId: '#(encumbranceId2)', total: 50.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Verify Both PO Lines Have "Awaiting Payment" Status After Invoice Approval (Steps 1-2)
    Given path 'orders/order-lines', orderLineId1
    When method GET
    Then status 200
    And match $.paymentStatus == 'Awaiting Payment'

    Given path 'orders/order-lines', orderLineId2
    When method GET
    Then status 200
    And match $.paymentStatus == 'Awaiting Payment'

    # 9. Verify Invoice Status Is "Approved" And Fiscal Year Is Fiscal Year #1 (Step 3)
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.status == 'Approved'
    And match $.fiscalYearId == fyId1

    # 10. Perform Rollover From FY#1 To FY#2 With One-Time Encumbrances Based On Initial Amount
    * def budgetsRollover = [ { rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', addAvailableTo: 'Allocation', setAllowances: false } ]
    * def encumbrancesRollover = [ { orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 } ]
    * def v = call rollover { id: '#(rolloverId)', ledgerId: '#(ledgerId)', fromFiscalYearId: '#(fyId1)', toFiscalYearId: '#(fyId2)', restrictEncumbrance: true, restrictExpenditures: true, needCloseBudgets: false, budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 11. Verify Rollover Completed Successfully
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    When method GET
    Then status 200
    And match response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success'

    # 12. Shift Fiscal Year Periods So FY#1 Becomes Past And FY#2 Includes Current Date
    * def v = call backdateFY { id: '#(fyId1)' }
    * def v = call backdateFY { id: '#(fyId2)' }

    # 13. Cancel Invoice Against Previous Fiscal Year With "Fully Paid" POL Payment Status (Steps 4-6)
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)', poLinePaymentStatus: 'Fully Paid' }

    # 14. Verify Invoice Status Is "Cancelled" After Cancellation (Step 6)
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 15. Verify Invoice Line #1 Status Is "Cancelled" (Step 7)
    Given path 'invoice/invoice-lines', invoiceLineId1
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    # 16. Verify Past FY Encumbrance #1 Is "Unreleased" With Correct Amounts (Step 8)
    * def isEncumbranceCorrect =
    """
    function(response, amount) {
      if (!response.transactions || response.transactions.length == 0) return false;
      var t = response.transactions[0];
      return t.encumbrance.status == 'Unreleased' &&
      t.amount == amount &&
      t.fiscalYearId == fyId1 &&
      t.encumbrance.initialAmountEncumbered == amount &&
      t.encumbrance.amountAwaitingPayment == 0.00 &&
      t.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId1
    And retry until isEncumbranceCorrect(response, 25.00)
    When method GET
    Then status 200

    # 17. Verify POL #1 Payment Status Is "Fully Paid" (Step 9)
    Given path 'orders/order-lines', orderLineId1
    When method GET
    Then status 200
    And match $.paymentStatus == 'Fully Paid'

    # 18. Verify Invoice Line #2 Status Is "Cancelled" (Step 10)
    Given path 'invoice/invoice-lines', invoiceLineId2
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Cancelled'

    # 19. Verify Past FY Encumbrance #2 Is "Unreleased" With Correct Amounts (Step 11)
    Given path 'finance/transactions'
    And param query = 'id==' + encumbranceId2
    And retry until isEncumbranceCorrect(response, 50.00)
    When method GET
    Then status 200

    # 20. Verify POL #2 Payment Status Is "Fully Paid" (Step 12)
    Given path 'orders/order-lines', orderLineId2
    When method GET
    Then status 200
    And match $.paymentStatus == 'Fully Paid'

