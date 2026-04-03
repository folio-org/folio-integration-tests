# For MODFISTO-484, https://foliotest.testrail.io/index.php?/cases/view/496153
Feature: Budget Summary When Decrease Allocation Exceeds Available Amount

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @C496153
  @Positive
  Scenario: Budget Summary When Decrease Allocation Exceeds Available Amount
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId = call uuid
    * def budgetBId = call uuid
    * def transferId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Ledger With Restrictions Disabled, Fund A And Fund B Each Allocated At $500
    * print '1. Create Ledger With Restrictions Disabled, Fund A And Fund B Each Allocated At $500'
    * def v = call createLedger { id: "#(ledgerId)", restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: "#(fundAId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", allocated: 500 }
    * def v = call createFund { id: "#(fundBId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", allocated: 500, allowableEncumbrance: 200.0, allowableExpenditure: 200.0 }

    # 2. Transfer $1000 From Fund B To Fund A
    * print '2. Transfer $1000 From Fund B To Fund A'
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "transactionsToCreate": [{
        "id": "#(transferId)",
        "amount": 1000,
        "currency": "USD",
        "fromFundId": "#(fundBId)",
        "toFundId": "#(fundAId)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "transactionType": "Transfer",
        "source": "User"
      }]
    }
    """
    When method POST
    Then status 204

    # 3. Create, Approve And Pay Invoice For Fund B For $100 (Not Based On Order)
    * print '3. Create, Approve And Pay Invoice For Fund B For $100 (Not Based On Order)'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", fundId: "#(fundBId)", total: 100.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 4. Create And Open Order With PO Line For $500 Against Fund B
    * print '4. Create And Open Order With PO Line For $500 Against Fund B'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundBId)", listUnitPrice: 500.00, titleOrPackage: "Budget Transfer Test" }
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Verify Fund B Budget Row - Allocated, Net Transfers, Unavailable, Available
    * print '5. Verify Fund B Budget Row - Allocated, Net Transfers, Unavailable, Available'
    * def validateFundBBudgetRow =
    """
    function(response) {
      return response.allocated == 500.00 &&
             response.netTransfers == -1000.00 &&
             response.unavailable == 600.00 &&
             response.available == -1100.00;
    }
    """
    Given path 'finance/budgets', budgetBId
    And retry until validateFundBBudgetRow(response)
    When method GET
    Then status 200

    # 6. Verify Fund B Budget Summary - Funding Information And Financial Activity
    * print '6. Verify Fund B Budget Summary - Funding Information And Financial Activity'
    * def validateBudgetBSummary =
    """
    function(response) {
      return response.initialAllocation == 500.00 &&
             response.allocationTo == 0.00 &&
             response.allocationFrom == 0.00 &&
             response.allocated == 500.00 &&
             response.netTransfers == -1000.00 &&
             response.totalFunding == -500.00 &&
             response.cashBalance == -600.00 &&
             response.encumbered == 500.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 100.00 &&
             response.credits == 0.00 &&
             response.unavailable == 600.00 &&
             response.overEncumbrance == 500.00 &&
             response.overExpended == 100.00 &&
             response.available == -1100.00;
    }
    """
    Given path 'finance/budgets', budgetBId
    And retry until validateBudgetBSummary(response)
    When method GET
    Then status 200
