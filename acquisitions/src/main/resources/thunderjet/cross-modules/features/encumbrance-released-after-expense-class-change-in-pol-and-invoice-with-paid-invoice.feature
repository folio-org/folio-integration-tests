# For MODINVOICE-583, UIOR-1406, https://foliotest.testrail.io/index.php?/cases/view/722381
Feature: Release encumbrance when changing expense class both in PO line and invoice line (releaseEncumbrance=true)

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

  @C722381
  @Positive
  Scenario: Release encumbrance when changing expense class both in PO line and invoice line with releaseEncumbrance=true
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
    * def v = call createExpenseClass { id: "#(expenseClassElectronicId)", code: "e3", name: "Electronic3" }
    * def v = call createExpenseClass { id: "#(expenseClassPrintId)", code: "p3", name: "Print3" }

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

    # 1. Verify PO Line Fund Distribution Has Electronic Expense Class
    * print '1. Verify PO Line Fund Distribution Has Electronic Expense Class'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundId
    And match response.fundDistribution[0].expenseClassId == expenseClassElectronicId

    # 2-4. Change Expense Class In PO Line From Electronic To Print
    * print '2-4. Change Expense Class In PO Line From Electronic To Print'
    * def poLineUpdate = response
    * set poLineUpdate.fundDistribution[0].expenseClassId = expenseClassPrintId
    * remove poLineUpdate.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', orderLineId
    And request poLineUpdate
    When method PUT
    Then status 204

    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].expenseClassId == expenseClassPrintId

    # 5. Verify Invoice Line Has Electronic Expense Class And Current Encumbrance
    * print '5. Verify Invoice Line Has Electronic Expense Class And Current Encumbrance'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.fundDistributions[0].expenseClassId == expenseClassElectronicId

    * def validateEncumbranceElectronic =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.encumbrance && t.encumbrance.sourcePoLineId == orderLineId);
      if (!encumbrance) return false;
      return encumbrance.amount == 5.00 &&
             encumbrance.fromFundId == fundId &&
             encumbrance.expenseClassId == expenseClassPrintId &&
             encumbrance.encumbrance.status == 'Unreleased';
    }
    """

    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundId
    And retry until validateEncumbranceElectronic(response)
    When method GET
    Then status 200

    # 6. Change Expense Class In Invoice Line To Print
    * print '6. Change Expense Class In Invoice Line To Print'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLineUpdate = response
    * set invoiceLineUpdate.fundDistributions[0].expenseClassId = expenseClassPrintId

    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLineUpdate
    When method PUT
    Then status 204

    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.fundDistributions[0].expenseClassId == expenseClassPrintId

    # 7. Approve And Pay Invoice
    * print '7. Approve And Pay Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.status == 'Paid'

    # 8. Verify Invoice Line Status Is Paid With Print Expense Class
    * print '8. Verify Invoice Line Status Is Paid With Print Expense Class'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.invoiceLineStatus == 'Paid'
    And match response.fundDistributions[0].expenseClassId == expenseClassPrintId

    # 9. Verify Encumbrance Is Released With Print Expense Class
    * print '9. Verify Encumbrance Is Released With Print Expense Class'
    * def validateEncumbrancePrint =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.encumbrance && t.encumbrance.sourcePoLineId == orderLineId);
      if (!encumbrance) return false;
      return encumbrance.amount == 0 &&
             encumbrance.fromFundId == fundId &&
             encumbrance.expenseClassId == expenseClassPrintId &&
             encumbrance.encumbrance.status == 'Released' &&
             encumbrance.encumbrance.initialAmountEncumbered == 5 &&
             encumbrance.encumbrance.amountAwaitingPayment == 0 &&
             encumbrance.encumbrance.amountExpended == 5;
    }
    """

    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundId
    And retry until validateEncumbrancePrint(response)
    When method GET
    Then status 200

    * def validateBudget =
    """
    function(response) {
      return response.encumbered == 0 &&
             response.awaitingPayment == 0 &&
             response.expenditures == 5 &&
             response.available == 95;
    }
    """

    Given path 'finance/budgets', budgetId
    And retry until validateBudget(response)
    When method GET
    Then status 200

    * def validatePayment =
    """
    function(response) {
      var payment = response.transactions.find(t => t.transactionType == 'Payment' && t.sourceInvoiceId == invoiceId && t.fromFundId == fundId);
      if (!payment) return false;
      return payment.amount == 5 &&
             payment.expenseClassId == expenseClassPrintId;
    }
    """

    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundId
    And retry until validatePayment(response)
    When method GET
    Then status 200

