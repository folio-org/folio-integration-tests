# For MODINVOICE-618, https://foliotest.testrail.io/index.php?/cases/view/919907
Feature: Subscription Info, Tags, And Comments Can Be Edited In An Approved Invoice When The Fund's Budget Is Set To Inactive

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 15000 }

    * callonce variables

  @C919907
  @Positive
  Scenario: Subscription Info, Tags, And Comments Can Be Edited In An Approved Invoice When The Fund's Budget Is Set To Inactive
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Active Fund With Budget In Current Fiscal Year With $1000 Allocation
    * print '1. Create Active Fund With Budget In Current Fiscal Year With $1000 Allocation'
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(globalLedgerId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Order In Open Status With One PO Line Using Fund A With $100 Distribution
    * print '2. Create Order In Open Status With One PO Line Using Fund A With $100 Distribution'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 100.00 }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 3. Create Invoice In Open Status Based On The Order
    * print '3. Create Invoice In Open Status Based On The Order'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }

    # 4. Create Invoice Line With Tags Linked To PO Line
    * print '4. Create Invoice Line With Tags Linked To PO Line'
    * def invoiceLineTags = { tagList: ['TestTag919907'] }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundId)", total: 100.00, releaseEncumbrance: false, tags: "#(invoiceLineTags)" }

    # 5. Approve The Invoice
    * print '5. Approve The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    # 6. Set Fund Budget To Inactive
    * print '6. Set Fund Budget To Inactive'
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = response
    * set budget.budgetStatus = 'Inactive'
    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Invoice Status Is Approved
    * print '7. Verify Invoice Status Is Approved'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.status == 'Approved'

    # 8. Verify Invoice Line Status Is Approved And Has Tag
    * print '8. Verify Invoice Line Status Is Approved And Has Tag'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.invoiceLineStatus == 'Approved'
    And match response.tags.tagList contains 'TestTag919907'

    # 9. Edit Subscription Info, Subscription Dates, And Comment In Approved Invoice Line With Inactive Budget
    * print '9. Edit Subscription Info, Subscription Dates, And Comment In Approved Invoice Line With Inactive Budget'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response
    * set invoiceLine.subscriptionInfo = 'Updated Subscription Info'
    * set invoiceLine.subscriptionStart = '2025-01-01'
    * set invoiceLine.subscriptionEnd = '2025-12-31'
    * set invoiceLine.comment = 'Updated comment for C919907'
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # 10. Verify Subscription Info, Subscription Dates, And Comment Were Updated Successfully
    * print '10. Verify Subscription Info, Subscription Dates, And Comment Were Updated Successfully'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.subscriptionInfo == 'Updated Subscription Info'
    And match response.subscriptionStart == '2025-01-01T00:00:00.000+00:00'
    And match response.subscriptionEnd == '2025-12-31T00:00:00.000+00:00'
    And match response.comment == 'Updated comment for C919907'
    And match response.invoiceLineStatus == 'Approved'

    # 11. Add Additional Tags To Invoice Line
    * print '11. Add Additional Tags To Invoice Line'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response
    * set invoiceLine.tags.tagList = ['TestTag919907', 'SecondTag919907']
    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204

    # 12. Verify Additional Tags Were Added Successfully
    * print '12. Verify Additional Tags Were Added Successfully'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.tags.tagList contains 'TestTag919907'
    And match response.tags.tagList contains 'SecondTag919907'
    And match response.tags.tagList == '#[2]'
    And match response.invoiceLineStatus == 'Approved'

