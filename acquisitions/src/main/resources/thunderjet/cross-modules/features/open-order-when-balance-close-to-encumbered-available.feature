# For MODFISTO-472, FAT-12169, https://foliotest.testrail.io/index.php?/cases/view/449361
Feature: Order can be opened when balance is close to the encumbered available balance

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 5000 }

    * callonce variables

    # Create finance data unique to each test (ledger with restricted encumbrance, fund A, budget A
    # with $100 allocated, +$10 net transfer, allowable encumbrance/expenditure 110%)
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def budgetAId = call uuid
    * def v = call createLedger { id: '#(ledgerId)', restrictEncumbrance: true, restrictExpenditures: false }
    * def v = call createFund { id: '#(fundAId)', name: 'Fund A', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetAId)', fundId: '#(fundAId)', allocated: 100, netTransfers: 10, allowableEncumbrance: 110.0, allowableExpenditure: 110.0 }

  @C449361
  @Positive
  Scenario: Order can be opened when balance is close to the encumbered available balance
    * def order1Id = call uuid
    * def poLine1Id = call uuid
    * def order2Id = call uuid
    * def poLine2Id = call uuid
    * def invoice1Id = call uuid
    * def invoiceLine1Id = call uuid
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid

    # 1. Create Order #1 ($10) and open it -> encumbered $10 on Fund A
    * def v = call createOrder { id: '#(order1Id)', orderType: 'One-Time' }
    * table polineRows1
      | id          | orderId    | fundId    | listUnitPrice | titleOrPackage |
      | poLine1Id   | order1Id   | fundAId   | 10.0          | 'Order 1 line' |
    * call createOrderLine polineRows1
    * def v = call openOrder { orderId: '#(order1Id)' }

    # 2. Create Invoice #1 (NOT from Order #1) and approve it for $15 -> awaitingPayment $15
    * def v = call createInvoice { id: '#(invoice1Id)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine1Id)', invoiceId: '#(invoice1Id)', fundId: '#(fundAId)', total: 15.0, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: '#(invoice1Id)' }

    # 3. Create Invoice #2 (NOT from Order #1) and pay it for $20 -> expended $20
    * def v = call createInvoice { id: '#(invoice2Id)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLine2Id)', invoiceId: '#(invoice2Id)', fundId: '#(fundAId)', total: 20.0, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: '#(invoice2Id)' }
    * def v = call payInvoice { invoiceId: '#(invoice2Id)' }

    # 4. Verify budget reflects encumbered=$10, awaitingPayment=$15, expenditures=$20
    * def validateBudgetBeforeOpen =
    """
    function(response) {
      return response.allocated == 100.00 &&
             response.netTransfers == 10.00 &&
             response.encumbered == 10.00 &&
             response.awaitingPayment == 15.00 &&
             response.expenditures == 20.00;
    }
    """
    Given path 'finance/budgets', budgetAId
    And retry until validateBudgetBeforeOpen(response)
    When method GET
    Then status 200

    # 5. Create Order #2 in Pending status with one PO line of $75 on Fund A
    * def v = call createOrder { id: '#(order2Id)', orderType: 'One-Time' }
    * table polineRows2
      | id          | orderId    | fundId    | listUnitPrice | titleOrPackage |
      | poLine2Id   | order2Id   | fundAId   | 75.0          | 'Order 2 line' |
    * call createOrderLine polineRows2

    # 6. Open Order #2 - remaining allowed encumbrance = (100+10)*1.1 - (10+15+20) = 76, so $75 fits
    * def v = call openOrder { orderId: '#(order2Id)' }

    # 7. Verify Order #2 is Open and PO line current encumbrance = $75
    Given path 'orders/composite-orders', order2Id
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 75.00 && response.totalEncumbered == 75.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 8. Verify Encumbrance details for Order #2 PO line
    * def validateOrder2Encumbrance =
    """
    function(response) {
      if (!response.transactions || response.transactions.length == 0) return false;
      var transaction = response.transactions.find(function(t) { return t.encumbrance && t.encumbrance.sourcePoLineId == poLine2Id; });
      if (!transaction) return false;
      return transaction.transactionType == 'Encumbrance' &&
             transaction.amount == 75.00 &&
             transaction.fromFundId == fundAId &&
             transaction.encumbrance.sourcePurchaseOrderId == order2Id &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 75.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + order2Id
    And retry until validateOrder2Encumbrance(response)
    When method GET
    Then status 200

    # 9. Verify final Fund A budget state after opening Order #2
    * def validateBudgetAfterOpen =
    """
    function(response) {
      return response.allocated == 100.00 &&
             response.netTransfers == 10.00 &&
             response.encumbered == 85.00 &&
             response.awaitingPayment == 15.00 &&
             response.expenditures == 20.00;
    }
    """
    Given path 'finance/budgets', budgetAId
    And retry until validateBudgetAfterOpen(response)
    When method GET
    Then status 200
