# For https://issues.folio.org/browse/MODINVOICE-463
@parallel=false
Feature: Approve and pay invoice with past fiscal year

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

    * def pastFiscalYearId = callonce uuid1
    * def presentFiscalYearId = callonce uuid2
    * def ledgerId = callonce uuid3
    * def fundId = callonce uuid4
    * def budgetId = callonce uuid5
    * def invoiceId = callonce uuid6
    * def invoiceLineId = callonce uuid7


  Scenario: Create 2 fiscal years, ledger, fund and budget
    * configure headers = headersAdmin
    * def v = call createFiscalYear { id: #(pastFiscalYearId), code: 'AFY2020', periodStart: '2020-01-01T00:00:00Z', periodEnd: '2020-12-30T23:59:59Z', series: 'AFY' }
    * def currentYear = call getCurrentYear
    * def currentStart = currentYear + '-01-01T00:00:00Z'
    * def currentEnd = currentYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(presentFiscalYearId), code: #('AFY' + currentYear), periodStart: #(currentStart), periodEnd: #(currentEnd), series: 'AFY' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(pastFiscalYearId), restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: #(fundId), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId), allocated: 100, fundId: #(fundId), status: Active, fiscalYearId: #(pastFiscalYearId) }

  Scenario: Create an invoice
    * def v = call createInvoice { id: #(invoiceId) }

  Scenario: Update the invoice to use the past fiscal year
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.fiscalYearId = pastFiscalYearId

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204

  Scenario: Add an invoice line
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId), invoiceId: #(invoiceId), fundId: #(fundId), total: 10 }

  Scenario: Approve the invoice
    * def v = call approveInvoice { invoiceId: #(invoiceId) }

  Scenario: Check that pending payments were created with the right fiscal year
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Pending payment'
    When method GET
    Then status 200
    And match $.transactions[0].fiscalYearId == pastFiscalYearId

  Scenario: Pay the invoice
    * def v = call payInvoice { invoiceId: #(invoiceId) }

  Scenario: Check that payments were created with the right fiscal year
    Given path 'finance/transactions'
    And headers headersAdmin
    And param query = 'sourceInvoiceLineId==' + invoiceLineId + ' and transactionType==Payment'
    When method GET
    Then status 200
    And match $.transactions[0].fiscalYearId == pastFiscalYearId

  Scenario: Check the past budget
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.unavailable == 10
    And match $.available == 90
    And match $.cashBalance == 90
    And match $.overExpended == 0
    And match $.encumbered == 0

  Scenario: Check the past fiscal year balance
    Given path 'finance/fiscal-years', pastFiscalYearId
    And param withFinancialSummary = true
    When method GET
    Then status 200
    And match response.financialSummary.available == 90
    And match response.financialSummary.cashBalance == 90
