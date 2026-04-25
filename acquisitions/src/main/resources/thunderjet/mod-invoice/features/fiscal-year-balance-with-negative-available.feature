# For MODFISTO-285
Feature: Check fiscal year balance when using a negative available

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Check fiscal year balance when using a negative available
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create new fy and ledger, fund 1 with 100, fund 2 with 0
    * configure headers = headersAdmin
    * def v = call createFiscalYear { id: #(fiscalYearId), code: 'FYTEST2030', periodStart: '2030-01-01T00:00:00Z', periodEnd: '2030-12-30T23:59:59Z', series: 'FY' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fiscalYearId), restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: #(fundId1), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), allocated: 100, fundId: #(fundId1), status: Active, fiscalYearId: #(fiscalYearId) }
    * def v = call createFund { id: #(fundId2), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId2), allocated: 0, fundId: #(fundId2), status: Active, fiscalYearId: #(fiscalYearId) }

    # 2. Create an invoice
    * configure headers = headersUser
    * def v = call createInvoice { id: #(invoiceId) }

    # 3. Add an invoice line using fund 2
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), fundId: #(fundId2), total: 10 }

    # 4. Approve the invoice
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

    # 5. Pay the invoice
    * def v = call payInvoice { invoiceId: #(invoiceId) }

    # 6. Check budget for fund 2
    * configure headers = headersAdmin
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == -10
    And match $.cashBalance == -10
    And match $.overExpended == 10
    And match $.encumbered == 0

    # 7. Check fiscal year balance
    Given path 'finance/fiscal-years', fiscalYearId
    And param withFinancialSummary = true
    When method GET
    Then status 200
    And match response.financialSummary.available == 90
    And match response.financialSummary.cashBalance == 90
