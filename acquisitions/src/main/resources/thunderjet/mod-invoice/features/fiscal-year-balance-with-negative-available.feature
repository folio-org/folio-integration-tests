# For https://issues.folio.org/browse/MODFISTO-285
@parallel=false
Feature: Check fiscal year balance when using a negative available

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')
    * def approveInvoice = read('classpath:thunderjet/mod-invoice/reusable/approve-invoice.feature')
    * def payInvoice = read('classpath:thunderjet/mod-invoice/reusable/pay-invoice.feature')

    * def fiscalYearId = callonce uuid1
    * def ledgerId = callonce uuid2
    * def fundId1 = callonce uuid3
    * def fundId2 = callonce uuid4
    * def budgetId1 = callonce uuid5
    * def budgetId2 = callonce uuid6
    * def invoiceId = callonce uuid7
    * def invoiceLineId = callonce uuid8


  Scenario: Create new fy and ledger, fund 1 with 100, fund 2 with 0
    * configure headers = headersAdmin
    * def v = call createFiscalYear { id: #(fiscalYearId), code: 'FYTEST2030', periodStart: '2030-01-01T00:00:00Z', periodEnd: '2030-12-30T23:59:59Z', series: 'FY' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(fiscalYearId), restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: #(fundId1), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), allocated: 100, fundId: #(fundId1), status: Active, fiscalYearId: #(fiscalYearId) }
    * def v = call createFund { id: #(fundId2), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId2), allocated: 0, fundId: #(fundId2), status: Active, fiscalYearId: #(fiscalYearId) }

  Scenario: Create an invoice
    * def v = call createInvoice { id: #(invoiceId) }

  Scenario: Add an invoice line using fund 2
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), fundId: #(fundId2), total: 10 }

  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: #(invoiceId) }

  Scenario: Check budget for fund 2
    Given path 'finance/budgets', budgetId2
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == -10
    And match $.cashBalance == -10
    And match $.overExpended == 10
    And match $.encumbered == 0

  Scenario: Check fiscal year balance
    Given path 'finance/fiscal-years', fiscalYearId
    And param withFinancialSummary = true
    When method GET
    Then status 200
    And match response.financialSummary.available == 90
    And match response.financialSummary.cashBalance == 90
