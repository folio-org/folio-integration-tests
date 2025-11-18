# For MODFISTO-325, MODORDERS-712, MODFISTO-337, MODORDERS-870, MODFISTO-331, MODORDERS-755, MODFISTO-326, MODFISTO-333, https://foliotest.testrail.io/index.php?/cases/view/357580
Feature: Budget Summary And Encumbrances Updated Correctly When Editing POL With Related Invoice After Rollover Of Fiscal Year

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 15000 }
    * configure readTimeout = 120000
    * configure connectTimeout = 120000

    * callonce variables

  @Positive
  Scenario: Budget Summary And Encumbrances Updated Correctly When Editing POL With Related Invoice After Rollover Of Fiscal Year
    # Generate unique identifiers for this test scenario
    * def fromFiscalYearId = call uuid
    * def toFiscalYearId = call uuid
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAFY1Id = call uuid
    * def budgetBFY1Id = call uuid
    * def budgetAFY2Id = call uuid
    * def budgetBFY2Id = call uuid
    * def order1Id = call uuid
    * def order1LineId = call uuid
    * def order2Id = call uuid
    * def order2LineId = call uuid
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

    # 3. Create Ledger Related To Fiscal Year #1
    * print '3. Create Ledger Related To Fiscal Year #1'
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(fromFiscalYearId)" }

    # 4. Create Fund A With Budget In FY1 With $1000 Allocation
    * print '4. Create Fund A With Budget In FY1 With $1000 Allocation'
    * def v = call createFund { id: "#(fundAId)", ledgerId: "#(ledgerId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAFY1Id)", fundId: "#(fundAId)", fiscalYearId: "#(fromFiscalYearId)", allocated: 1000, status: "Active" }

    # 5. Create Fund B With Budget In FY1 With $1000 Allocation
    * print '5. Create Fund B With Budget In FY1 With $1000 Allocation'
    * def v = call createFund { id: "#(fundBId)", ledgerId: "#(ledgerId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBFY1Id)", fundId: "#(fundBId)", fiscalYearId: "#(fromFiscalYearId)", allocated: 1000, status: "Active" }

    # 6. Create Ongoing Order #1 With One POL Using Fund A With $100 Distribution And Re-Encumber Enabled
    * print '6. Create Ongoing Order #1 With One POL Using Fund A With $100 Distribution And Re-Encumber Enabled'
    * def ongoingConfig = { "interval": 123, "isSubscription": false, "manualRenewal": false }
    * def v = call createOrder { id: "#(order1Id)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)", reEncumber: true }
    * def v = call createOrderLine { id: "#(order1LineId)", orderId: "#(order1Id)", fundId: "#(fundAId)", listUnitPrice: 100.00, titleOrPackage: "Ongoing Order Line 1" }

    # 7. Open Order #1
    * print '7. Open Order #1'
    * def v = call openOrder { orderId: "#(order1Id)" }

    # 8. Create Paid Invoice Related To Order #1 POL And FY #1 With $100 Amount
    * print '8. Create Paid Invoice Related To Order #1 POL And FY #1 With $100 Amount'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(fromFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(order1LineId)", fundId: "#(fundAId)", total: 100.00 }
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 9. Create One-Time Order #2 With One POL Using Fund A With $10 Distribution And Re-Encumber Enabled
    * print '9. Create One-Time Order #2 With One POL Using Fund A With $10 Distribution And Re-Encumber Enabled'
    * def v = call createOrder { id: "#(order2Id)", vendor: "#(globalVendorId)", orderType: "One-Time", reEncumber: true }
    * def v = call createOrderLine { id: "#(order2LineId)", orderId: "#(order2Id)", fundId: "#(fundAId)", listUnitPrice: 10.00, titleOrPackage: "One-Time Order Line 2" }

    # 10. Open Order #2
    * print '10. Open Order #2'
    * def v = call openOrder { orderId: "#(order2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 11. Close Order #2 With Reason Cancelled
    * print '11. Close Order #2 With Reason Cancelled'
    Given path 'orders/composite-orders', order2Id
    When method GET
    Then status 200
    * def order2 = response
    * set order2.workflowStatus = 'Closed'
    * set order2.closeReason = { reason: 'Cancelled' }
    Given path 'orders/composite-orders', order2Id
    And request order2
    When method PUT
    Then status 204

    # 12. Verify Order #2 POL Receipt Status Is Cancelled And Payment Status Is Cancelled
    * print '12. Verify Order #2 POL Receipt Status Is Cancelled And Payment Status Is Cancelled'
    Given path 'orders/order-lines', order2LineId
    And retry until response.receiptStatus == 'Cancelled' && response.paymentStatus == 'Cancelled'
    When method GET
    Then status 200

    # 13. Verify Order #2 Encumbrance Is Released With $10 Initial Amount From Fund A
    * print '13. Verify Order #2 Encumbrance Is Released With $10 Initial Amount From Fund A'
    * def validateOrder2EncumbranceReleased =
    """
    function(response) {
      if (!response.transactions || response.transactions.length == 0) return false;
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.fromFundId == fundAId &&
             transaction.encumbrance &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.sourcePurchaseOrderId == order2Id;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + order2Id
    And retry until validateOrder2EncumbranceReleased(response)
    When method GET
    Then status 200

    # 14. Perform Ledger Rollover To FY #2 With Rollover Allocation Active, Rollover Budget Value None, And All Encumbrance Options Based On Expended
    * print '14. Perform Ledger Rollover To FY #2 With Rollover Allocation Active, Rollover Budget Value None, And All Encumbrance Options Based On Expended'
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
          "orderType": "Ongoing",
          "basedOn": "Expended",
          "increaseBy": 0
        },
        {
          "orderType": "Ongoing-Subscription",
          "basedOn": "Expended",
          "increaseBy": 0
        },
        {
          "orderType": "One-time",
          "basedOn": "Expended",
          "increaseBy": 0
        }
      ]
    }
    """
    Given path 'finance/ledger-rollovers'
    And request rolloverRequest
    When method POST
    Then status 201

    # 15. Wait For Rollover To Complete Successfully
    * print '15. Wait For Rollover To Complete Successfully'
    * def rolloverResponse = response
    * def rolloverJobId = rolloverResponse.id
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

    # 16. Update FY1 Period End To Yesterday And FY2 Period Begin To Today To Make FY2 Current
    * print '16. Update FY1 Period End To Yesterday And FY2 Period Begin To Today To Make FY2 Current'
    * def v = call shiftFiscalYearPeriods { fromFiscalYearId: "#(fromFiscalYearId)", toFiscalYearId: "#(toFiscalYearId)" }

    # 17. Verify Order #1 Encumbrance In FY2 Is Unreleased With $100 Initial Amount From Fund A
    * print '17. Verify Order #1 Encumbrance In FY2 Is Unreleased With $100 Initial Amount From Fund A'
    * def validateOrder1EncumbranceFY2 =
    """
    function(response) {
      if (!response.transactions || response.transactions.length == 0) return false;
      var transaction = response.transactions[0];
      return transaction.amount == 100.00 &&
             transaction.fromFundId == fundAId &&
             transaction.encumbrance &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 100.00 &&
             transaction.encumbrance.sourcePurchaseOrderId == order1Id;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + order1Id + ' and fiscalYearId==' + toFiscalYearId
    And retry until validateOrder1EncumbranceFY2(response)
    When method GET
    Then status 200

    # 17a. Verify Fund A Current Budget In FY2 Shows $100 Encumbered
    * print '17a. Verify Fund A Current Budget In FY2 Shows $100 Encumbered'
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundAId + ' and fiscalYearId==' + toFiscalYearId
    And retry until response.budgets != null && response.budgets.length > 0
    When method GET
    Then status 200
    * def budgetAFY2Id = response.budgets[0].id
    * def validateFundABudgetFY2 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 100.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00;
    }
    """
    Given path 'finance/budgets', budgetAFY2Id
    And retry until validateFundABudgetFY2(response)
    When method GET
    Then status 200

    # 18. Edit Order #1 POL - Change Unit Price To $70 And Change Fund From Fund A To Fund B
    * print '18. Edit Order #1 POL - Change Unit Price To $70 And Change Fund From Fund A To Fund B'
    Given path 'orders/order-lines', order1LineId
    When method GET
    Then status 200
    * def order1Line = response
    * set order1Line.cost.listUnitPrice = 70.00
    * set order1Line.fundDistribution[0].fundId = fundBId
    * set order1Line.fundDistribution[0].code = fundBId
    * remove order1Line.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', order1LineId
    And request order1Line
    When method PUT
    Then status 204

    # 19. Verify New Encumbrance For Order #1 From Fund B With $70 Initial Amount And Unreleased Status
    * print '19. Verify New Encumbrance For Order #1 From Fund B With $70 Initial Amount And Unreleased Status'
    * def validateNewEncumbranceFromFundB =
    """
    function(response) {
      if (!response.transactions || response.transactions.length == 0) return false;
      var transaction = response.transactions[0];
      return transaction.amount == 70.00 &&
             transaction.fromFundId == fundBId &&
             transaction.encumbrance &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 70.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00 &&
             transaction.encumbrance.sourcePurchaseOrderId == order1Id;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + order1Id + ' and fiscalYearId==' + toFiscalYearId + ' and fromFundId==' + fundBId
    And retry until validateNewEncumbranceFromFundB(response)
    When method GET
    Then status 200
    * def newEncumbranceId = response.transactions[0].id

    # 19a. Verify New Encumbrance Transaction Details From Fund B
    * print '19a. Verify New Encumbrance Transaction Details From Fund B'
    Given path 'finance/transactions', newEncumbranceId
    When method GET
    Then status 200
    And match response.transactionType == 'Encumbrance'
    And match response.amount == 70.00
    And match response.fromFundId == fundBId
    And match response.fiscalYearId == toFiscalYearId
    And match response.source == 'PoLine'
    And match response.encumbrance.status == 'Unreleased'
    And match response.encumbrance.initialAmountEncumbered == 70.00
    And match response.encumbrance.sourcePoLineId == order1LineId
    And match response.encumbrance.sourcePurchaseOrderId == order1Id

    # 19b. Verify Fund B Current Budget In FY2 Shows $70 Encumbered
    * print '19b. Verify Fund B Current Budget In FY2 Shows $70 Encumbered'
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundBId + ' and fiscalYearId==' + toFiscalYearId
    And retry until response.budgets != null && response.budgets.length > 0
    When method GET
    Then status 200
    * def fundBBudgetId = response.budgets[0].id
    * def validateFundBBudgetFY2 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 70.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00;
    }
    """
    Given path 'finance/budgets', fundBBudgetId
    And retry until validateFundBBudgetFY2(response)
    When method GET
    Then status 200

    # 20. Verify Fund B Budget Does Not Contain Payment Transaction Related To Order #1
    * print '20. Verify Fund B Budget Does Not Contain Payment Transaction Related To Order #1'
    Given path 'finance/transactions'
    And param query = 'transactionType==Payment and toFundId==' + fundBId + ' and sourceInvoiceId==' + invoiceId
    When method GET
    Then status 200
    And match response.transactions == []

    # 21. Verify Fund A FY2 Budget Does Not Contain Encumbrances Or Payments Related To Order #1 And Order #2
    * print '21. Verify Fund A FY2 Budget Does Not Contain Encumbrances Or Payments Related To Order #1 And Order #2'
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + toFiscalYearId + ' and fromFundId==' + fundAId
    When method GET
    Then status 200
    And match response.transactions == []

    # 21a. Verify Fund A Current Budget In FY2 Shows $0 Encumbered
    * print '21a. Verify Fund A Current Budget In FY2 Shows $0 Encumbered'
    * def validateFundABudgetZeroEncumbered =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00;
    }
    """
    Given path 'finance/budgets', budgetAFY2Id
    And retry until validateFundABudgetZeroEncumbered(response)
    When method GET
    Then status 200

    # 22. Verify Fund A FY1 Budget Contains Released Encumbrances For Both Order #1 And Order #2 With Correct Initial Amounts
    * print '22. Verify Fund A FY1 Budget Contains Released Encumbrances For Both Order #1 And Order #2 With Correct Initial Amounts'
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and fiscalYearId==' + fromFiscalYearId + ' and fromFundId==' + fundAId
    When method GET
    Then status 200
    And match response.totalRecords == 2

    # 23. Verify Fund A FY1 Budget Contains Payment Related To Invoice With $100 Amount
    * print '23. Verify Fund A FY1 Budget Contains Payment Related To Invoice With $100 Amount'
    * def validatePaymentInFY1 =
    """
    function(response) {
      if (!response.transactions || response.transactions.length == 0) return false;
      return response.transactions.length >= 1 && response.transactions[0].amount == 100.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'transactionType==Payment and fromFundId==' + fundAId + ' and sourceInvoiceId==' + invoiceId
    And retry until validatePaymentInFY1(response)
    When method GET
    Then status 200

    # 24. Verify Order #1 Encumbrance In FY1 Is Released With $100 Initial Amount
    * print '24. Verify Order #1 Encumbrance In FY1 Is Released With $100 Initial Amount'
    * def validateOrder1EncumbranceFY1 =
    """
    function(response) {
      var transactions = response.transactions.filter(function(t) {
        return t.encumbrance && t.encumbrance.sourcePurchaseOrderId == order1Id;
      });
      return transactions.length > 0 &&
             transactions[0].encumbrance.status == 'Released' &&
             transactions[0].encumbrance.initialAmountEncumbered == 100.00 &&
             transactions[0].fromFundId == fundAId;
    }
    """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and fiscalYearId==' + fromFiscalYearId + ' and fromFundId==' + fundAId
    And retry until validateOrder1EncumbranceFY1(response)
    When method GET
    Then status 200
    * def order1EncumbranceFY1 = response.transactions.filter(function(t) { return t.encumbrance && t.encumbrance.sourcePurchaseOrderId == order1Id; })[0]

    # 27a. Verify Order #1 Encumbrance Transaction Details In FY1
    * print '27a. Verify Order #1 Encumbrance Transaction Details In FY1'
    Given path 'finance/transactions', order1EncumbranceFY1.id
    When method GET
    Then status 200
    And match response.transactionType == 'Encumbrance'
    And match response.fromFundId == fundAId
    And match response.fiscalYearId == fromFiscalYearId
    And match response.source == 'PoLine'
    And match response.encumbrance.status == 'Released'
    And match response.encumbrance.initialAmountEncumbered == 100.00
    And match response.encumbrance.sourcePoLineId == order1LineId
    And match response.encumbrance.sourcePurchaseOrderId == order1Id

    # 25. Verify Order #2 Encumbrance In FY1 Is Released With $10 Initial Amount
    * print '25. Verify Order #2 Encumbrance In FY1 Is Released With $10 Initial Amount'
    * def validateOrder2EncumbranceFY1 =
    """
    function(response) {
      var transactions = response.transactions.filter(function(t) {
        return t.encumbrance && t.encumbrance.sourcePurchaseOrderId == order2Id;
      });
      return transactions.length > 0 &&
             transactions[0].encumbrance.status == 'Released' &&
             transactions[0].encumbrance.initialAmountEncumbered == 10.00 &&
             transactions[0].fromFundId == fundAId;
    }
    """
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and fiscalYearId==' + fromFiscalYearId + ' and fromFundId==' + fundAId
    And retry until validateOrder2EncumbranceFY1(response)
    When method GET
    Then status 200
    * def order2EncumbranceFY1 = response.transactions.filter(function(t) { return t.encumbrance && t.encumbrance.sourcePurchaseOrderId == order2Id; })[0]

    # 25a. Verify Order #2 Encumbrance Transaction Details In FY1
    * print '25a. Verify Order #2 Encumbrance Transaction Details In FY1'
    Given path 'finance/transactions', order2EncumbranceFY1.id
    When method GET
    Then status 200
    And match response.transactionType == 'Encumbrance'
    And match response.fromFundId == fundAId
    And match response.fiscalYearId == fromFiscalYearId
    And match response.source == 'PoLine'
    And match response.encumbrance.status == 'Released'
    And match response.encumbrance.initialAmountEncumbered == 10.00
    And match response.encumbrance.sourcePoLineId == order2LineId
    And match response.encumbrance.sourcePurchaseOrderId == order2Id

    # 25b. Verify Fund A Previous Budget In FY1 Shows $0 Encumbered And $100 Expended
    * print '25b. Verify Fund A Previous Budget In FY1 Shows $0 Encumbered And $100 Expended'
    * def validateFundABudgetFY1 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 100.00 &&
             response.credits == 0.00;
    }
    """
    Given path 'finance/budgets', budgetAFY1Id
    And retry until validateFundABudgetFY1(response)
    When method GET
    Then status 200
