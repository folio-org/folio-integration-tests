# For MODFIN-373, https://foliotest.testrail.io/index.php?/cases/view/496175
Feature: Over Encumbrance Is Calculated Correctly For Fiscal Year Ledger And Group

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 5, interval: 5000 }

    * callonce variables

  @C496175
  @Positive
  Scenario: Over Encumbrance Is Calculated Correctly For Fiscal Year Ledger And Group
    # 1. Generate Unique Identifiers For This Test Scenario
    * print '1. Generate Unique Identifiers For This Test Scenario'
    * def series = call random_string
    * def currentYear = call getCurrentYear
    * def fiscalYearId = call uuid
    * def ledgerAId = call uuid
    * def ledgerBId = call uuid
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId = call uuid
    * def budgetBId = call uuid
    * def groupId = call uuid
    * def order1Id = call uuid
    * def orderLine1Id = call uuid
    * def order2Id = call uuid
    * def orderLine2Id = call uuid
    * def invoice1Id = call uuid
    * def invoiceLine1Id = call uuid
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid

    # 2. Create Dedicated Fiscal Year For This Test
    * print '2. Create Dedicated Fiscal Year For This Test'
    * def periodStart = currentYear + '-01-01T00:00:00Z'
    * def periodEnd = currentYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: '#(series + currentYear)', periodStart: '#(periodStart)', periodEnd: '#(periodEnd)', series: '#(series)' }

    # 3. Create Ledger A With Encumbrance Enforcement Disabled
    * print '3. Create Ledger A With Encumbrance Enforcement Disabled'
    * def v = call createLedger { id: "#(ledgerAId)", fiscalYearId: "#(fiscalYearId)", restrictEncumbrance: false, restrictExpenditures: true }

    # 4. Create Ledger B With Encumbrance Enforcement Disabled
    * print '4. Create Ledger B With Encumbrance Enforcement Disabled'
    * def v = call createLedger { id: "#(ledgerBId)", fiscalYearId: "#(fiscalYearId)", restrictEncumbrance: false, restrictExpenditures: true }

    # 5. Create Fund A And Budget A Allocated At $100 In Ledger A
    * print '5. Create Fund A And Budget A Allocated At $100 In Ledger A'
    * def v = call createFund { id: "#(fundAId)", ledgerId: "#(ledgerAId)" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(fiscalYearId)", allocated: 100, allowableEncumbrance: 100.0, allowableExpenditure: 100.0 }

    # 6. Create Fund B And Budget B Allocated At $100 In Ledger B
    * print '6. Create Fund B And Budget B Allocated At $100 In Ledger B'
    * def v = call createFund { id: "#(fundBId)", ledgerId: "#(ledgerBId)" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(fiscalYearId)", allocated: 100, allowableEncumbrance: 100.0, allowableExpenditure: 100.0 }

    # 7. Create Group
    * print '7. Create Group'
    Given path 'finance/groups'
    And request { "id": "#(groupId)", "status": "Active", "name": "#(groupId)", "code": "#(groupId)" }
    When method POST
    Then status 201

    # 8. Assign Fund B To Group By Updating The Fund With groupIds
    * print '8. Assign Fund B To Group By Updating The Fund With groupIds'
    Given path 'finance/funds', fundBId
    When method GET
    Then status 200
    * def fundBComposite = response
    * def setGroupIds =
    """
    function() {
      fundBComposite.groupIds = [groupId];
    }
    """
    * eval setGroupIds()
    Given path 'finance/funds', fundBId
    And request fundBComposite
    When method PUT
    Then status 204

    # 9. Create And Open Order #1 For Fund A With $10
    * print '9. Create And Open Order #1 For Fund A With $10'
    * def v = call createOrder { id: "#(order1Id)", vendor: "#(globalVendorId)" }
    * def v = call createOrderLine { id: "#(orderLine1Id)", orderId: "#(order1Id)", fundId: "#(fundAId)", listUnitPrice: 10.00, titleOrPackage: "Order 1 For Over Encumbrance Test" }
    * def v = call openOrder { orderId: "#(order1Id)" }

    # 10. Create And Open Order #2 For Fund B With $1
    * print '10. Create And Open Order #2 For Fund B With $1'
    * def v = call createOrder { id: "#(order2Id)", vendor: "#(globalVendorId)" }
    * def v = call createOrderLine { id: "#(orderLine2Id)", orderId: "#(order2Id)", fundId: "#(fundBId)", listUnitPrice: 1.00, titleOrPackage: "Order 2 For Over Encumbrance Test" }
    * def v = call openOrder { orderId: "#(order2Id)" }

    # 11. Create Approve And Pay Standalone Invoice #1 For Fund A With $100
    * print '11. Create Approve And Pay Standalone Invoice #1 For Fund A With $100'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(fiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine1Id)", invoiceId: "#(invoice1Id)", fundId: "#(fundAId)", total: 100.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 12. Create Approve And Pay Standalone Invoice #2 For Fund B With $100
    * print '12. Create Approve And Pay Standalone Invoice #2 For Fund B With $100'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(fiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine2Id)", invoiceId: "#(invoice2Id)", fundId: "#(fundBId)", total: 100.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 13. Verify Fiscal Year Over Encumbrance Is $11 (Fund A $10 + Fund B $1)
    * print '13. Verify Fiscal Year Over Encumbrance Is $11 (Fund A $10 + Fund B $1)'
    * def validateFiscalYearOverEncumbrance =
    """
    function(response) {
      return response.financialSummary != null &&
             response.financialSummary.overEncumbrance == 11.00;
    }
    """
    Given path 'finance/fiscal-years', fiscalYearId
    And param withFinancialSummary = true
    And retry until validateFiscalYearOverEncumbrance(response)
    When method GET
    Then status 200

    # 14. Verify Ledger A Over Encumbrance Is $10
    * print '14. Verify Ledger A Over Encumbrance Is $10'
    * def validateLedgerAOverEncumbrance =
    """
    function(response) {
      return response.overEncumbrance == 10.00;
    }
    """
    Given path 'finance/ledgers', ledgerAId
    And param fiscalYear = fiscalYearId
    And retry until validateLedgerAOverEncumbrance(response)
    When method GET
    Then status 200

    # 15. Verify Ledger B Over Encumbrance Is $1
    * print '15. Verify Ledger B Over Encumbrance Is $1'
    * def validateLedgerBOverEncumbrance =
    """
    function(response) {
      return response.overEncumbrance == 1.00;
    }
    """
    Given path 'finance/ledgers', ledgerBId
    And param fiscalYear = fiscalYearId
    And retry until validateLedgerBOverEncumbrance(response)
    When method GET
    Then status 200

    # 16. Verify Group Over Encumbrance Is $1
    * print '16. Verify Group Over Encumbrance Is $1'
    Given path 'finance/ledgers', ledgerBId, 'current-fiscal-year'
    When method GET
    Then status 200
    * def currentFiscalYearId = response.id
    * def validateGroupOverEncumbrance =
    """
    function(response) {
      var summaries = response.groupFiscalYearSummaries;
      return summaries != null && summaries.length > 0 &&
             summaries[0].overEncumbrance == 1.00;
    }
    """
    Given path 'finance/group-fiscal-year-summaries'
    And param limit = 1000
    And param query = '(groupFundFY.groupId==' + groupId + ' or groupId==' + groupId + ') and fiscalYearId==' + currentFiscalYearId
    And retry until validateGroupOverEncumbrance(response)
    When method GET
    Then status 200
