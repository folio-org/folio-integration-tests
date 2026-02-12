# For MODORDERS-1191, MODORDERS-1203, https://foliotest.testrail.io/index.php?/cases/view/594371
Feature: Total Expended Amount Calculation When Order Has No Encumbrances

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

  @C594371
  @Positive
  Scenario: Total Expended Amount Calculation When Order Has No Encumbrances
    # Generate unique identifiers for this test scenario
    * def fiscalYear1Id = call uuid
    * def fiscalYear2Id = call uuid
    * def fiscalYear3Id = call uuid
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def budgetAId = call uuid
    * def ledgerBId = call uuid
    * def fundBId = call uuid
    * def budgetBId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid
    * def invoice3Id = call uuid
    * def invoice3LineId = call uuid
    * def rolloverId = call uuid

    # 1. Create Two Consecutive Fiscal Years With Identical Unique Letter Part
    * def currentYear = new Date().getFullYear()
    * def prevYear = currentYear - 1
    * def yesterday = call getYesterday

    # 1. Create First Fiscal Year In Past Year
    * print '1. Create First Fiscal Year In Past Year'
    * def fiscalYearCode1 = 'ZA' + prevYear
    * def fy1StartDate = prevYear + '-01-01T00:00:00.000Z'
    * def fy1EndDate = prevYear + '-12-31T23:59:59.999Z'
    * def v = call createFiscalYear { id: "#(fiscalYear1Id)", code: "#(fiscalYearCode1)", periodStart: "#(fy1StartDate)", periodEnd: "#(fy1EndDate)", series: "ZA" }

    * def fiscalYearCode2 = 'ZA' + currentYear
    * def fy2StartDate = yesterday + 'T00:00:00.000Z'
    * def fy2EndDate = currentYear + '-12-31T23:59:59.999Z'
    * def v = call createFiscalYear { id: "#(fiscalYear2Id)", code: "#(fiscalYearCode2)", periodStart: "#(fy2StartDate)", periodEnd: "#(fy2EndDate)", series: "ZA" }

    # 2. Create Ledger A Related To First Fiscal Year
    * print '2. Create Ledger A Related To First Fiscal Year'
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(fiscalYear1Id)" }

    # 3. Create Fund A With Budget Having Money Allocation
    * print '3. Create Fund A With Budget Having Money Allocation'
    * def v = call createFund { id: "#(fundAId)", ledgerId: "#(ledgerId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(fiscalYear1Id)", allocated: 100, status: "Active" }

    # 4. Create Order In Open Status With One PO Line Without Fund Distribution
    * print '4. Create Order In Open Status With One PO Line Without Fund Distribution'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", listUnitPrice: 5.00, titleOrPackage: "Test Order Line", fundDistribution: [] }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Create Invoice 1, Specify Fund Distribution With Fund A
    * print '5. Create Invoice 1, Specify Fund Distribution With Fund A'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(fiscalYear1Id)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 1.00, releaseEncumbrance: false }

    # 6. Approve And Pay Invoice 1
    * print '6. Approve And Pay Invoice 1'
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Perform Rollover For Ledger
    * print '7. Perform Rollover For Ledger'
    * def budgetsRollover = [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false, addAvailableTo: 'Available' }]
    * def encumbrancesRollover = [{ orderType: 'Ongoing', basedOn: 'InitialAmount' }, { orderType: 'Ongoing-Subscription', basedOn: 'InitialAmount' }, { orderType: 'One-time', basedOn: 'InitialAmount' }]
    * def v = call rollover { id: "#(rolloverId)", ledgerId: "#(ledgerId)", fromFiscalYearId: "#(fiscalYear1Id)", toFiscalYearId: "#(fiscalYear2Id)", restrictEncumbrance: true, restrictExpenditures: true, needCloseBudgets: true, rolloverType: 'Commit', budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 8. Create Credit Invoice 2 For Order, Specify Fund Distribution With Fund A
    * print '8. Create Credit Invoice 2 For Order, Specify Fund Distribution With Fund A'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(fiscalYear2Id)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: -1.00, releaseEncumbrance: false }

    # 9. Approve And Pay Invoice 2 For Current / Second Fiscal Year
    * print '9. Approve And Pay Invoice 2 For Current / Second Fiscal Year'
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 10. Create Another Fiscal Year With Different Unique Letter Part
    * print '10. Create Another Fiscal Year With Different Unique Letter Part'
    * def fiscalYearCode3 = 'FYZ' + currentYear
    * def fy3StartDate = currentYear + '-01-01T00:00:00.000Z'
    * def fy3EndDate = currentYear + '-12-31T23:59:59.999Z'
    * def v = call createFiscalYear { id: "#(fiscalYear3Id)", code: "#(fiscalYearCode3)", periodStart: "#(fy3StartDate)", periodEnd: "#(fy3EndDate)", series: "FYZ" }

    # 11. Create Ledger B Related To Created Fiscal Year
    * print '11. Create Ledger B Related To Created Fiscal Year'
    * def v = call createLedger { id: "#(ledgerBId)", fiscalYearId: "#(fiscalYear3Id)" }

    # 12. Create Fund B With Budget Having Money Allocation
    * print '12. Create Fund B With Budget Having Money Allocation'
    * def v = call createFund { id: "#(fundBId)", ledgerId: "#(ledgerBId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(fiscalYear3Id)", allocated: 100, status: "Active" }

    # 13. Create Invoice 3 For Order, Specify Fund Distribution With Fund B
    * print '13. Create Invoice 3 For Order, Specify Fund Distribution With Fund B'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(fiscalYear3Id)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundBId)", total: 1.00, releaseEncumbrance: false }

    # 14. Approve And Pay Invoice 3
    * print '14. Approve And Pay Invoice 3'
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice3Id)" }

    # 15. Navigate To Order Details Pane And Verify Total Expended
    * print '15. Navigate To Order Details Pane And Verify Total Expended'
    * def validateOrderTotals =
    """
    function(response) {
      return response.totalEncumbered == 0.00 &&
             response.totalExpended == 1.00 &&
             response.totalCredited == 1.00 &&
             response.totalItems == 1;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderTotals(response)
    When method GET
    Then status 200
