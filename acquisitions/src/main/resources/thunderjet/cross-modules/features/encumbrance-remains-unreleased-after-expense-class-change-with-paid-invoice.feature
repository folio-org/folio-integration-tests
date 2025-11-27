# For MODINVOICE-583, UIOR-1406, https://foliotest.testrail.io/index.php?/cases/view/700837, https://foliotest.testrail.io/index.php?/cases/view/710243
@parallel=false
Feature: Encumbrance Remains Unreleased After Changing Expense Class In PO Line With Paid Invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 5, interval: 5000 }
    * configure readTimeout = 120000
    * configure connectTimeout = 120000

    * callonce variables

  @Positive
  Scenario: Encumbrance Remains Unreleased After Changing Expense Class In PO Line With Paid Invoice Release True
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def expenseClassElectronicId = call uuid
    * def expenseClassPrintId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund A With $100 Allocation
    * print '1. Create Fund A With $100 Allocation'
    * def v = call createFund { id: "#(fundId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }

    # 2. Create Two Expense Classes (Electronic And Print)
    * print '2. Create Two Expense Classes (Electronic And Print)'
    * def v = call createExpenseClass { id: "#(expenseClassElectronicId)", code: "e1", name: "Electronic1" }
    * def v = call createExpenseClass { id: "#(expenseClassPrintId)", code: "p1", name: "Print1" }

    # 3. Assign Both Expense Classes To Budget
    * print '3. Assign Both Expense Classes To Budget'
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = response
    * set budget.statusExpenseClasses = [{ 'expenseClassId': '#(expenseClassElectronicId)', 'status': 'Active' }, { 'expenseClassId': '#(expenseClassPrintId)', 'status': 'Active' }]
    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    # 4. Create Ongoing Order With Re-Encumber Option Enabled
    * print '4. Create Ongoing Order With Re-Encumber Option Enabled'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)", reEncumber: true }

    # 5. Create Order Line With Fund A, Electronic Expense Class, And $5 Total Cost
    * print '5. Create Order Line With Fund A, Electronic Expense Class, And $5 Total Cost'
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", expenseClassId: "#(expenseClassElectronicId)", listUnitPrice: 5.00, titleOrPackage: "Test Ongoing Order" }

    # 6. Open The Order
    * print '6. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 7. Create Invoice With $5 Amount And Release Encumbrance True
    * print '7. Create Invoice With $5 Amount And Release Encumbrance True'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", expenseClassId: "#(expenseClassElectronicId)", total: 5.00, releaseEncumbrance: true }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Verify PO Line Fund Distribution Has Electronic Expense Class And Capture Encumbrance ID
    * print '8. Verify PO Line Fund Distribution Has Electronic Expense Class And Capture Encumbrance ID'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundId
    And match response.fundDistribution[0].expenseClassId == expenseClassElectronicId
    And match response.cost.listUnitPrice == 5.00

    # 9. Change Expense Class From Electronic To Print In PO Line
    * print '9. Change Expense Class From Electronic To Print In PO Line'
    * def poLine = response
    * set poLine.fundDistribution[0].expenseClassId = expenseClassPrintId
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 10. Verify PO Line Fund Distribution Updated With Print Expense Class
    * print '10. Verify PO Line Fund Distribution Updated With Print Expense Class'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].expenseClassId == expenseClassPrintId
    * def originalEncumbranceId = response.fundDistribution[0].encumbrance

    # 11. Approve And Pay The Invoice
    * print '11. Approve And Pay The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 12. Verify Invoice Line Has Electronic Expense Class (Original) And Encumbrance ID Remains Unchanged
    * print '12. Verify Invoice Line Has Electronic Expense Class (Original) And Encumbrance ID Remains Unchanged'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.status == 'Paid'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.fundDistributions[0].expenseClassId == expenseClassElectronicId
    And match response.fundDistributions[0].fundId == fundId
    And match response.fundDistributions[0].encumbrance == originalEncumbranceId

    # 13. Verify Encumbrance Transaction Has Print Expense Class And Unreleased Status
    * print '13. Verify Encumbrance Transaction Has Print Expense Class And Unreleased Status'
    * def validateEncumbrance =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.encumbrance.sourcePurchaseOrderId == orderId);
      if (!encumbrance) return false;
      return encumbrance.amount == 0.00 &&
             encumbrance.fromFundId == fundId &&
             encumbrance.expenseClassId == expenseClassPrintId &&
             encumbrance.encumbrance.status == 'Released' &&
             encumbrance.encumbrance.initialAmountEncumbered == 5.00 &&
             encumbrance.encumbrance.amountAwaitingPayment == 0.00 &&
             encumbrance.encumbrance.amountExpended == 5.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundId
    And retry until validateEncumbrance(response)
    When method GET
    Then status 200

  @Positive
  Scenario: Encumbrance Remains Unreleased After Changing Expense Class In PO Line With Paid Invoice Release False
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def expenseClassElectronicId = call uuid
    * def expenseClassPrintId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund A With $100 Allocation
    * print '1. Create Fund A With $100 Allocation'
    * def v = call createFund { id: "#(fundId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }

    # 2. Create Two Expense Classes (Electronic And Print)
    * print '2. Create Two Expense Classes (Electronic And Print)'
    * def v = call createExpenseClass { id: "#(expenseClassElectronicId)", code: "e2", name: "Electronic2" }
    * def v = call createExpenseClass { id: "#(expenseClassPrintId)", code: "p2", name: "Print2" }

    # 3. Assign Both Expense Classes To Budget
    * print '3. Assign Both Expense Classes To Budget'
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = response
    * set budget.statusExpenseClasses = [{ 'expenseClassId': '#(expenseClassElectronicId)', 'status': 'Active' }, { 'expenseClassId': '#(expenseClassPrintId)', 'status': 'Active' }]
    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    # 4. Create Ongoing Order With Re-Encumber Option Enabled
    * print '4. Create Ongoing Order With Re-Encumber Option Enabled'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)", reEncumber: true }

    # 5. Create Order Line With Fund A, Electronic Expense Class, And $5 Total Cost
    * print '5. Create Order Line With Fund A, Electronic Expense Class, And $5 Total Cost'
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", expenseClassId: "#(expenseClassElectronicId)", listUnitPrice: 5.00, titleOrPackage: "Test Ongoing Order" }

    # 6. Open The Order
    * print '6. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 7. Create Invoice With $5 Amount And Release Encumbrance False
    * print '7. Create Invoice With $5 Amount And Release Encumbrance False'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", expenseClassId: "#(expenseClassElectronicId)", total: 5.00, releaseEncumbrance: false }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Verify PO Line Fund Distribution Has Electronic Expense Class And Capture Encumbrance ID
    * print '8. Verify PO Line Fund Distribution Has Electronic Expense Class And Capture Encumbrance ID'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundId
    And match response.fundDistribution[0].expenseClassId == expenseClassElectronicId
    And match response.cost.listUnitPrice == 5.00

    # 9. Change Expense Class From Electronic To Print In PO Line
    * print '9. Change Expense Class From Electronic To Print In PO Line'
    * def poLine = response
    * set poLine.fundDistribution[0].expenseClassId = expenseClassPrintId
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 10. Verify PO Line Fund Distribution Updated With Print Expense Class
    * print '10. Verify PO Line Fund Distribution Updated With Print Expense Class'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].expenseClassId == expenseClassPrintId
    * def originalEncumbranceId = response.fundDistribution[0].encumbrance

    # 11. Approve And Pay The Invoice
    * print '11. Approve And Pay The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 12. Verify Invoice Line Has Electronic Expense Class (Original) And Encumbrance ID Remains Unchanged
    * print '12. Verify Invoice Line Has Electronic Expense Class (Original) And Encumbrance ID Remains Unchanged'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.status == 'Paid'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.fundDistributions[0].expenseClassId == expenseClassElectronicId
    And match response.fundDistributions[0].fundId == fundId
    And match response.fundDistributions[0].encumbrance == originalEncumbranceId

    # 13. Verify Encumbrance Transaction Has Print Expense Class And Unreleased Status
    * print '13. Verify Encumbrance Transaction Has Print Expense Class And Unreleased Status'
    * def validateEncumbrance =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.encumbrance.sourcePurchaseOrderId == orderId);
      if (!encumbrance) return false;
      return encumbrance.amount == 0.00 &&
             encumbrance.fromFundId == fundId &&
             encumbrance.expenseClassId == expenseClassPrintId &&
             encumbrance.encumbrance.status == 'Unreleased' &&
             encumbrance.encumbrance.initialAmountEncumbered == 5.00 &&
             encumbrance.encumbrance.amountAwaitingPayment == 0.00 &&
             encumbrance.encumbrance.amountExpended == 5.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundId
    And retry until validateEncumbrance(response)
    When method GET
    Then status 200
