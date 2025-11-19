# For Scenario 5 - mod-orders becomes unavailable after removing Fund distribution from POL
Feature: Encumbrance After Removing Fund Distribution From POL

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
  Scenario: Encumbrance After Removing Fund Distribution From POL
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid
    * def invoice3Id = call uuid
    * def invoice3LineId = call uuid
    * def invoice4Id = call uuid
    * def invoice4LineId = call uuid
    * def invoice5Id = call uuid
    * def invoice5LineId = call uuid
    * def invoice6Id = call uuid
    * def invoice6LineId = call uuid

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * def v = call createFund { id: "#(fundId)", name: "Test Fund For POL Distribution" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Order With Order Line ($10 amount)
    * print '2. Create Order With Order Line ($10 amount)'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test Order For Fund Distribution Removal" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Create Invoice #1 With $5 Amount (release encumbrance = false) And Pay It
    * print '4. Create Invoice #1 With $5 Amount (release encumbrance = false) And Pay It'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 5. Create Invoice #2 With -$1 Amount (release encumbrance = false) And Pay It
    * print '5. Create Invoice #2 With -$1 Amount (release encumbrance = false) And Pay It'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -1.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 6. Create Invoice #3 With $3 Amount (release encumbrance = false) And Pay It
    * print '6. Create Invoice #3 With $3 Amount (release encumbrance = false) And Pay It'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 3.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice3Id)" }

    # 7. Verify Order State After Initial Invoices Are Paid
    * print '7. Verify Order State After Initial Invoices Are Paid'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 3.00 && response.totalExpended == 8.00 && response.totalCredited == 1.00
    When method GET
    Then status 200
    * print 'Order state after initial invoices:', response

    # 8. Cancel Invoice #1
    * print '8. Cancel Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(invoice1Id)" }

    # 9. Cancel The Order
    * print '9. Cancel The Order'
    * def v = call closeOrder { orderId: "#(orderId)" }

    # 10. Re-open The Order
    * print '10. Re-open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 11. Cancel Invoice #2
    * print '11. Cancel Invoice #2'
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    # 12. Cancel Invoice #3
    * print '12. Cancel Invoice #3'
    * def v = call cancelInvoice { invoiceId: "#(invoice3Id)" }

    # 13. Create Invoice #4 With $5 Amount (release encumbrance = false) And Pay It
    * print '13. Create Invoice #4 With $5 Amount (release encumbrance = false) And Pay It'
    * def v = call createInvoice { id: "#(invoice4Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice4LineId)", invoiceId: "#(invoice4Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice4Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice4Id)" }

    # 14. Create Invoice #5 With -$1 Amount (release encumbrance = false) And Pay It
    * print '14. Create Invoice #5 With -$1 Amount (release encumbrance = false) And Pay It'
    * def v = call createInvoice { id: "#(invoice5Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice5LineId)", invoiceId: "#(invoice5Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -1.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice5Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice5Id)" }

    # 15. Create Invoice #6 With $3 Amount (release encumbrance = false) And Pay It
    * print '15. Create Invoice #6 With $3 Amount (release encumbrance = false) And Pay It'
    * def v = call createInvoice { id: "#(invoice6Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice6LineId)", invoiceId: "#(invoice6Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 3.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice6Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice6Id)" }

    # 16. Verify Order State After Second Set Of Invoices Are Paid
    * print '16. Verify Order State After Second Set Of Invoices Are Paid'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 3.00 && response.totalExpended == 8.00 && response.totalCredited == 1.00
    When method GET
    Then status 200
    * print 'Order state after second set of invoices:', response

    # 17. Cancel Invoice #4
    * print '17. Cancel Invoice #4'
    * def v = call cancelInvoice { invoiceId: "#(invoice4Id)" }

    # 18. Cancel The Order
    * print '18. Cancel The Order'
    * def v = call closeOrder { orderId: "#(orderId)" }

    # 19. Re-open The Order
    * print '19. Re-open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 20. Cancel Invoice #5
    * print '20. Cancel Invoice #5'
    * def v = call cancelInvoice { invoiceId: "#(invoice5Id)" }

    # 21. Cancel Invoice #6
    * print '21. Cancel Invoice #6'
    * def v = call cancelInvoice { invoiceId: "#(invoice6Id)" }

    # 22. Verify Encumbrance State Before Removing Fund Distribution
    * print '22. Verify Encumbrance State Before Removing Fund Distribution'
    * def validateEncumbranceBeforeRemoval =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 10.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceBeforeRemoval(response)
    When method GET
    Then status 200
    * print 'Encumbrance state before fund distribution removal:', response

    # 23. Remove Fund Distribution From POL
    * print '23. Remove Fund Distribution From POL'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def orderLine = response
    * set orderLine.fundDistribution = []
    * print 'Removing fund distribution from POL:', orderLine
    Given path 'orders/order-lines', orderLineId
    And request orderLine
    When method PUT
    Then status 204

    # 24. Verify Order Line After Removing Fund Distribution
    * print '24. Verify Order Line After Removing Fund Distribution'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * match response.fundDistribution == []
    * print 'Order line after fund distribution removal:', response

    # 25. Verify Encumbrance State After Removing Fund Distribution
    * print '25. Verify Encumbrance State After Removing Fund Distribution'
    * def validateEncumbranceAfterRemoval =
    """
    function(response) {
      // After removing fund distribution, encumbrance should be released or removed
      return response.transactions.length == 0 ||
             (response.transactions[0].encumbrance && response.transactions[0].encumbrance.status == 'Released');
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterRemoval(response)
    When method GET
    Then status 200
    * print 'Encumbrance state after fund distribution removal:', response

    # 26. Verify Order State After Removing Fund Distribution
    * print '26. Verify Order State After Removing Fund Distribution'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * print 'Final order state after fund distribution removal:', response
    * match response.workflowStatus == 'Open'
    * match response.totalEstimatedPrice == 10.00
    * match response.totalEncumbered == 0.00

    # 27. Verify Budget State After Removing Fund Distribution
    * print '27. Verify Budget State After Removing Fund Distribution'
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * print 'Budget state after fund distribution removal:', response
    * match response.available == 1000.00
    * match response.allocated == 1000.00
    * match response.encumbered == 0.00

    # 28. Verify mod-orders Remains Available
    * print '28. Verify mod-orders Remains Available'
    Given path 'orders/composite-orders'
    And param query = 'id==' + orderId
    When method GET
    Then status 200
    * print 'mod-orders availability check passed'

