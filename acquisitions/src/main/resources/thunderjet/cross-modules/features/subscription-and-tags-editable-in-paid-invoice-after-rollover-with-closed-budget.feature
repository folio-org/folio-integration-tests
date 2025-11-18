# For MODINVOICE-618, https://foliotest.testrail.io/index.php?/cases/view/919908
Feature: Subscription Info, Tags, And Comments Can Be Edited In A Paid Invoice When The Fund's Budget From Prior FY Is Closed

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 15000 }

    * callonce variables

  @Positive
  Scenario: Subscription Info, Tags, And Comments Can Be Edited In A Paid Invoice When The Fund's Budget From Prior FY Is Closed
    # Generate unique identifiers for this test scenario
    * def fromFiscalYearId = call uuid
    * def toFiscalYearId = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetFY1Id = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def rolloverId = call uuid

    * def series = call random_string
    * def fromYear = callonce getCurrentYear
    * def toYear = parseInt(fromYear) + 1

    # 1. Create Fiscal Year 1
    * print '1. Create Fiscal Year 1'
    * def periodStart1 = fromYear + "-01-01T00:00:00Z"
    * def periodEnd1 = fromYear + "-12-30T23:59:59Z"
    * def v = call createFiscalYear { id: "#(fromFiscalYearId)", code: "#(series + '0001')", periodStart: "#(periodStart1)", periodEnd: "#(periodEnd1)", series: "#(series)" }

    # 2. Create Fiscal Year 2
    * print '2. Create Fiscal Year 2'
    * def periodStart2 = toYear + "-01-01T00:00:00Z"
    * def periodEnd2 = toYear + "-12-30T23:59:59Z"
    * def v = call createFiscalYear { id: "#(toFiscalYearId)", code: "#(series + '0002')", periodStart: "#(periodStart2)", periodEnd: "#(periodEnd2)", series: "#(series)" }

    # 3. Create Ledger Related To First Fiscal Year
    * print '3. Create Ledger Related To First Fiscal Year'
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(fromFiscalYearId)" }

    # 4. Create Active Fund With Budget In FY1 With $1000 Allocation
    * print '4. Create Active Fund With Budget In FY1 With $1000 Allocation'
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetFY1Id)", fundId: "#(fundId)", fiscalYearId: "#(fromFiscalYearId)", allocated: 1000, status: "Active" }

    # 5. Create One-Time Order With Re-Encumber Enabled Using Fund With $100 Distribution
    * print '5. Create One-Time Order With Re-Encumber Enabled Using Fund With $100 Distribution'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time", reEncumber: true }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 100.00 }

    # 6. Open The Order
    * print '6. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 7. Create Invoice With Tag In Open Status Based On The Order In FY1
    * print '7. Create Invoice With Tag In Open Status Based On The Order In FY1'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(fromFiscalYearId)" }
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = response
    * set invoice.tags = { tagList: ['TestTag919908'] }
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    # 8. Create Invoice Line With Tag Linked To PO Line
    * print '8. Create Invoice Line With Tag Linked To PO Line'
    * def invoiceLineTags = { tagList: ['TestTag919908'] }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", total: 100.00, releaseEncumbrance: false, tags: "#(invoiceLineTags)" }

    # 9. Approve The Invoice
    * print '9. Approve The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    # 10. Pay The Invoice
    * print '10. Pay The Invoice'
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 11. Perform Ledger Rollover To FY2 With Close Budgets And One-Time Encumbrance Rollover Based On Initial Amount
    * print '11. Perform Ledger Rollover To FY2 With Close Budgets And One-Time Encumbrance Rollover Based On Initial Amount'
    * def rolloverRequest =
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
          "addAvailableTo": "Available"
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
    Given path 'finance/ledger-rollovers'
    And request rolloverRequest
    When method POST
    Then status 201

    # 12. Wait For Rollover To Complete Successfully
    * print '12. Wait For Rollover To Complete Successfully'
    * def rolloverJobId = response.id
    * def checkRolloverComplete =
    """
    function(response) {
      return response.ledgerFiscalYearRolloverProgresses != null &&
             response.ledgerFiscalYearRolloverProgresses.length > 0 &&
             response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success';
    }
    """
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverJobId
    And retry until checkRolloverComplete(response)
    When method GET
    Then status 200

    # 13. Verify Budget Created In FY2
    * print '13. Verify Budget Created In FY2'
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId + ' and fiscalYearId==' + toFiscalYearId
    And retry until response.budgets != null && response.budgets.length > 0
    When method GET
    Then status 200
    * def budgetFY2Id = response.budgets[0].id

    # 14. Verify FY1 Budget Is Closed
    * print '14. Verify FY1 Budget Is Closed'
    Given path 'finance/budgets', budgetFY1Id
    And retry until response.budgetStatus == 'Closed'
    When method GET
    Then status 200

    # 15. Update FY1 Period To Be In The Past And FY2 Period To Include Current Date
    * print '15. Update FY1 Period To Be In The Past And FY2 Period To Include Current Date'
    * def v = call shiftFiscalYearPeriods { fromFiscalYearId: "#(fromFiscalYearId)", toFiscalYearId: "#(toFiscalYearId)", series: "#(series)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 16. Verify Invoice Status Is Paid And Has Tag
    * print '16. Verify Invoice Status Is Paid And Has Tag'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.status == 'Paid'
    And match response.tags.tagList contains 'TestTag919908'

    # 17. Remove Tag From Invoice
    * print '17. Remove Tag From Invoice'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = response
    * set invoice.tags.tagList = []
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

    # 18. Verify Tag Removed From Invoice
    * print '18. Verify Tag Removed From Invoice'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.tags.tagList == []

    # 19. Verify Invoice Line Status Is Paid And Has Tag
    * print '19. Verify Invoice Line Status Is Paid And Has Tag'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.invoiceLineStatus == 'Paid'
    And match response.tags.tagList contains 'TestTag919908'

    # 20. Remove Tag From Invoice Line
    * print '20. Remove Tag From Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response
    * set invoiceLine.tags.tagList = []
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # 21. Verify Tag Removed From Invoice Line
    * print '21. Verify Tag Removed From Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.tags.tagList == []

    # 22. Add New Tag To Invoice Line
    * print '22. Add New Tag To Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response
    * set invoiceLine.tags.tagList = ['TestTag919908']
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # 23. Verify New Tag Added To Invoice Line
    * print '23. Verify New Tag Added To Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.tags.tagList contains 'TestTag919908'

    # 24. Edit Subscription Info, Subscription Dates, And Comment In Paid Invoice Line
    * print '24. Edit Subscription Info, Subscription Dates, And Comment In Paid Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response
    * set invoiceLine.subscriptionInfo = 'Updated Subscription Info'
    * set invoiceLine.subscriptionStart = '2025-01-01'
    * set invoiceLine.subscriptionEnd = '2025-12-31'
    * set invoiceLine.comment = 'Updated comment for C919908'
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # 25. Verify Subscription Info, Subscription Dates, And Comment Were Updated Successfully In Paid Invoice Line
    * print '25. Verify Subscription Info, Subscription Dates, And Comment Were Updated Successfully In Paid Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.subscriptionInfo == 'Updated Subscription Info'
    And match response.subscriptionStart == '2025-01-01'
    And match response.subscriptionEnd == '2025-12-31'
    And match response.comment == 'Updated comment for C919908'
    And match response.invoiceLineStatus == 'Paid'

