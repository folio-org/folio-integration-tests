# For MODORDERS-1191, https://foliotest.testrail.io/index.php?/cases/view/594372
Feature: Total Expended Amount Calculation With Paid Invoices From Different Fiscal Years

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

  @C594372
  @Positive
  Scenario: Total Expended Amount Calculation With Paid Invoices From Different Fiscal Years
    # Generate unique identifiers for this test scenario
    * def fiscalYear1Id = call uuid
    * def fiscalYear2Id = call uuid
    * def ledgerId = call uuid
    * def fundAId = call uuid
    * def budgetAId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice2Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2LineId = call uuid
    * def rolloverId = call uuid

    # 1. Create Two Consecutive Fiscal Years With Identical Unique Letter Part
    * def currentYear = new Date().getFullYear()
    * def nextYear = currentYear + 1
    * def fiscalYearCode1 = 'FYTB' + currentYear
    * def fiscalYearCode2 = 'FYTB' + nextYear

    # 1. Create First Fiscal Year With Period Including Today
    * print '1. Create First Fiscal Year With Period Including Today'
    * def fy1StartDate = currentYear + '-01-01T00:00:00.000Z'
    * def fy1EndDate = currentYear + '-12-31T23:59:59.999Z'
    * def fy2StartDate = nextYear + '-01-01T00:00:00.000Z'
    * def fy2EndDate = nextYear + '-12-31T23:59:59.999Z'
    * def v = call createFiscalYear { id: "#(fiscalYear1Id)", code: "#(fiscalYearCode1)", periodStart: "#(fy1StartDate)", periodEnd: "#(fy1EndDate)" }
    * def v = call createFiscalYear { id: "#(fiscalYear2Id)", code: "#(fiscalYearCode2)", periodStart: "#(fy2StartDate)", periodEnd: "#(fy2EndDate)" }

    # 2. Create Ledger Related To First Fiscal Year
    * print '2. Create Ledger Related To First Fiscal Year'
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(fiscalYear1Id)" }

    # 3. Create Fund A With Budget Having Money Allocation
    * print '3. Create Fund A With Budget Having Money Allocation'
    * def v = call createFund { id: "#(fundAId)", ledgerId: "#(ledgerId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(fiscalYear1Id)", allocated: 100, status: "Active" }

    # 4. Create Order In Open Status With One PO Line, Re-Encumber Active, Fund Distribution Specified
    * print '4. Create Order In Open Status With One PO Line, Re-Encumber Active, Fund Distribution Specified'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time", reEncumber: true }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundAId)", listUnitPrice: 5.00, titleOrPackage: "Test Order Line" }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Create Invoice 1 With Release Encumbrance Option Active
    * print '5. Create Invoice 1 With Release Encumbrance Option Active'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(fiscalYear1Id)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 5.00, releaseEncumbrance: true }

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

    # 8. Update FY1 Period End To Yesterday And FY2 Period Begin To Today To Make FY2 Current
    * print '8. Update FY1 Period End To Yesterday And FY2 Period Begin To Today To Make FY2 Current'
    * def v = call shiftFiscalYearPeriods { fromFiscalYearId: "#(fiscalYear1Id)", toFiscalYearId: "#(fiscalYear2Id)", series: "FYTB" }

    # 9. Create Invoice 2 With Release Encumbrance Option Active
    * print '9. Create Invoice 2 With Release Encumbrance Option Active'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(fiscalYear2Id)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 5.00, releaseEncumbrance: true }

    # 10. Approve And Pay Invoice 2 For Current / Second Fiscal Year
    * print '10. Approve And Pay Invoice 2 For Current / Second Fiscal Year'
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 11. Navigate To Order Details Pane And Verify Total Expended Contains Only Values Related To Current Fiscal Year
    * print '11. Navigate To Order Details Pane And Verify Total Expended Contains Only Values Related To Current Fiscal Year'
    * def validateOrderTotals =
    """
    function(response) {
      return response.totalEstimatedPrice == 5.00 &&
             response.totalEncumbered == 0.00 &&
             response.totalExpended == 5.00 &&
             response.totalCredited == 0.00;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderTotals(response)
    When method GET
    Then status 200
