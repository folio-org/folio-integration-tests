# For MODFISTO-477, UIF-611, https://foliotest.testrail.io/index.php?/cases/view/451636
Feature: Fund Distribution Can Be Changed After Rollover When Re-Encumber Is Not Active

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
  Scenario: Fund Distribution Can Be Changed After Rollover When Re-Encumber Is Not Active
    # Generate unique identifiers for this test scenario
    * def ledgerId = call uuid
    * def fiscalYearId1 = call uuid
    * def fiscalYearId2 = call uuid
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId1 = call uuid
    * def budgetAId2 = call uuid
    * def budgetBId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def rolloverId = call uuid

    * def currentYear = new Date().getFullYear()
    * def nextYear = currentYear + 1
    * def fiscalYearCode1 = 'FYTA' + currentYear
    * def fiscalYearCode2 = 'FYTA' + nextYear

    # 1. Create First Fiscal Year With Period Including Today
    * print '1. Create First Fiscal Year With Period Including Today'
    * def fy1StartDate = currentYear + '-01-01T00:00:00.000Z'
    * def fy1EndDate = currentYear + '-12-31T23:59:59.999Z'
    * def v = call createFiscalYear { id: "#(fiscalYearId1)", code: "#(fiscalYearCode1)", periodStart: "#(fy1StartDate)", periodEnd: "#(fy1EndDate)" }

    # 2. Create Second Fiscal Year
    * print '2. Create Second Fiscal Year'
    * def fy2StartDate = nextYear + '-01-01T00:00:00.000Z'
    * def fy2EndDate = nextYear + '-12-31T23:59:59.999Z'
    * def v = call createFiscalYear { id: "#(fiscalYearId2)", code: "#(fiscalYearCode2)", periodStart: "#(fy2StartDate)", periodEnd: "#(fy2EndDate)" }

    # 3. Create Ledger Related To First Fiscal Year
    * print '3. Create Ledger Related To First Fiscal Year'
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(fiscalYearId1)" }

    # 4. Create Fund A With Budget In FY1
    * print '4. Create Fund A With Budget In FY1'
    * def v = call createFund { id: "#(fundAId)", name: "Fund A", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetAId1)", fundId: "#(fundAId)", fiscalYearId: "#(fiscalYearId1)", allocated: 1000, status: "Active" }

    # 5. Create Fund B With Budget In FY2 (Different Ledger)
    * print '5. Create Fund B With Budget In FY2 (Different Ledger)'
    * def v = call createFund { id: "#(fundBId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(fiscalYearId2)", allocated: 1000, status: "Active" }

    # 6. Create One-Time Order Without Re-Encumber Option
    * print '6. Create One-Time Order Without Re-Encumber Option'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time", reEncumber: false }

    # 7. Create Order Line With Fund A And $50 Total Cost
    * print '7. Create Order Line With Fund A And $50 Total Cost'
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundAId)", listUnitPrice: 50.00, titleOrPackage: "Test One-Time Order" }

    # 8. Open The Order
    * print '8. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 9. Perform Rollover From FY1 To FY2
    * print '9. Perform Rollover From FY1 To FY2'
    * def budgetsRollover = [{ rolloverAllocation: true, adjustAllocation: 0, rolloverBudgetValue: 'None', setAllowances: false }]
    * def encumbrancesRollover = [{ orderType: 'One-time', basedOn: 'InitialAmount', increaseBy: 0 }]
    * def v = call rollover { id: "#(rolloverId)", ledgerId: "#(ledgerId)", fromFiscalYearId: "#(fiscalYearId1)", toFiscalYearId: "#(fiscalYearId2)", budgetsRollover: '#(budgetsRollover)', encumbrancesRollover: '#(encumbrancesRollover)' }

    # 10. Wait For Rollover To Complete
    * print '10. Wait For Rollover To Complete'
    * def validateRolloverComplete =
    """
    function(response) {
      return response.ledgerFiscalYearRolloverProgresses &&
             response.ledgerFiscalYearRolloverProgresses.length > 0 &&
             response.ledgerFiscalYearRolloverProgresses[0].overallRolloverStatus == 'Success';
    }
    """
    Given path 'finance/ledger-rollovers-progress'
    And param query = 'ledgerRolloverId==' + rolloverId
    And retry until validateRolloverComplete(response)
    When method GET
    Then status 200

    # 11. Update FY1 Period End To Yesterday And FY2 Period Begin To Today To Make FY2 Current
    * print '11. Update FY1 Period End To Yesterday And FY2 Period Begin To Today To Make FY2 Current'
    * def currentDate = call getCurrentDate
    * def yesterday = call getYesterday
    Given path 'finance/fiscal-years', fiscalYearId1
    When method GET
    Then status 200
    * def fy1 = response
    * set fy1.periodEnd = yesterday + 'T23:59:59Z'
    Given path 'finance/fiscal-years', fiscalYearId1
    And request fy1
    When method PUT
    Then status 204

    Given path 'finance/fiscal-years', fiscalYearId2
    When method GET
    Then status 200
    * def fy2 = response
    * set fy2.periodStart = currentDate + 'T00:00:00Z'
    Given path 'finance/fiscal-years', fiscalYearId2
    And request fy2
    When method PUT
    Then status 204

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 12. Verify PO Line Has Fund A
    * print '12. Verify PO Line Has Fund A'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundAId

    # 13. Change Fund Distribution From Fund A To Fund B
    * print '13. Change Fund Distribution From Fund A To Fund B'
    * def poLine = response
    * set poLine.fundDistribution[0].fundId = fundBId
    * set poLine.fundDistribution[0].code = fundBId
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 14. Verify PO Line Updated Successfully With Fund B And Current Encumbrance Is $0
    * print '14. Verify PO Line Updated Successfully With Fund B And Current Encumbrance Is $0'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundBId

    # 15. Verify Rollover Adjustment Field Appears In Cost Details
    * print '15. Verify Rollover Adjustment Field Appears In Cost Details'
    And match response.cost.poLineEstimatedPrice == 0.00

    # 16. Verify Encumbrance Transaction For Fund A In Previous Budget With Unreleased Status
    * print '16. Verify Encumbrance Transaction For Fund A In Previous Budget With Unreleased Status'
    * def validateEncumbranceFY1 =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.fromFundId == fundAId && t.encumbrance.sourcePurchaseOrderId == orderId);
      if (!encumbrance) return false;
      return encumbrance.amount == 50.00 &&
             encumbrance.fiscalYearId == fiscalYearId1 &&
             encumbrance.encumbrance.status == 'Unreleased';
    }
    """
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId1 + ' and fromFundId==' + fundAId
    And retry until validateEncumbranceFY1(response)
    When method GET
    Then status 200

    # 17. Change PO Line Price To Different Value
    * print '17. Change PO Line Price To Different Value'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def poLine = response
    * set poLine.cost.listUnitPrice = 60.00
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 18. Verify PO Line Updated With New Price And Rollover Adjustment Removed
    * print '18. Verify PO Line Updated With New Price And Rollover Adjustment Removed'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.cost.listUnitPrice == 60.00
    And match response.fundDistribution[0].fundId == fundBId

    # 19. Verify New Encumbrance Transaction For Fund B (Since Trillium: Amount=$0, Status=Released)
    * print '19. Verify New Encumbrance Transaction For Fund B (Since Trillium: Amount=$0, Status=Released)'
    * def validateEncumbranceFundB =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.fromFundId == fundBId && t.encumbrance.sourcePurchaseOrderId == orderId);
      if (!encumbrance) return false;
      return encumbrance.amount == 0.00 &&
             encumbrance.fromFundId == fundBId &&
             encumbrance.encumbrance.status == 'Released' &&
             encumbrance.encumbrance.initialAmountEncumbered == 60.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + fiscalYearId2 + ' and fromFundId==' + fundBId
    And retry until validateEncumbranceFundB(response)
    When method GET
    Then status 200


