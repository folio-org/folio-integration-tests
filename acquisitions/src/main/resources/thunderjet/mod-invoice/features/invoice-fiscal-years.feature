# For https://issues.folio.org/browse/MODINVOICE-465
@parallel=false
Feature: Invoice fiscal years

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
    * def currentYear = callonce getCurrentYear

    * def createFiscalYear = read('classpath:thunderjet/mod-finance/reusable/createFiscalYear.feature')
    * def createInvoice = read('classpath:thunderjet/mod-invoice/reusable/create-invoice.feature')
    * def createInvoiceLine = read('classpath:thunderjet/mod-invoice/reusable/create-invoice-line.feature')

    * def pastFiscalYearId1 = callonce uuid1
    * def pastFiscalYearId2 = callonce uuid2
    * def presentFiscalYearId = callonce uuid3
    * def futureFiscalYearId = callonce uuid4
    * def ledgerId = callonce uuid5
    * def fundId1 = callonce uuid6
    * def fundId2 = callonce uuid7
    * def fundId3 = callonce uuid8
    * def fundId4 = callonce uuid9
    * def budgetId1 = callonce uuid10
    * def budgetId2 = callonce uuid11
    * def budgetId3 = callonce uuid12
    * def budgetId4 = callonce uuid13
    * def budgetId5 = callonce uuid14
    * def budgetId6 = callonce uuid15
    * def budgetId7 = callonce uuid16
    * def budgetId8 = callonce uuid17
    * def budgetId9 = callonce uuid18
    * def budgetId10 = callonce uuid19
    * def budgetId11 = callonce uuid20
    * def budgetId12 = callonce uuid21
    * def invoiceId1 = callonce uuid22
    * def invoiceId2 = callonce uuid23
    * def invoiceLineId1 = callonce uuid24
    * def invoiceLineId2 = callonce uuid25
    * def invoiceLineId3 = callonce uuid26
    * def invoiceLineId4 = callonce uuid27


  Scenario: Create finances
    * configure headers = headersAdmin
    # 2 FY in the past, 1 in present, 1 in the future
    * def v = call createFiscalYear { id: #(pastFiscalYearId1), code: 'TESTFY2020', periodStart: '2020-01-01T00:00:00Z', periodEnd: '2020-12-30T23:59:59Z', series: 'TESTFY' }
    * def v = call createFiscalYear { id: #(pastFiscalYearId2), code: 'TESTFY2021', periodStart: '2021-01-01T00:00:00Z', periodEnd: '2021-12-30T23:59:59Z', series: 'TESTFY' }
    * def currentStart1 = currentYear + '-01-01T00:00:00Z'
    * def currentEnd1 = currentYear + '-12-30T23:59:59Z'
    * def v = call createFiscalYear { id: #(presentFiscalYearId), code: 'TESTFY2023', periodStart: #(currentStart1), periodEnd: #(currentEnd1), series: 'TESTFY' }
    * def v = call createFiscalYear { id: #(futureFiscalYearId), code: 'FYTEST2100', periodStart: '2100-01-01T00:00:00Z', periodEnd: '2100-12-30T23:59:59Z', series: 'TESTFY' }

    # 1 ledger
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(pastFiscalYearId1), restrictEncumbrance: false, restrictExpenditures: false }

    # fund 1 has a budget for all fiscal years
    * def v = call createFund { id: #(fundId1), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), allocated: 100, fundId: #(fundId1), status: Active, fiscalYearId: #(pastFiscalYearId1) }
    * def v = call createBudget { id: #(budgetId2), allocated: 100, fundId: #(fundId1), status: Active, fiscalYearId: #(pastFiscalYearId2) }
    * def v = call createBudget { id: #(budgetId3), allocated: 100, fundId: #(fundId1), status: Active, fiscalYearId: #(presentFiscalYearId) }
    * def v = call createBudget { id: #(budgetId4), allocated: 100, fundId: #(fundId1), status: Active, fiscalYearId: #(futureFiscalYearId) }
    # fund 2 is missing a budget for past fiscal year 2
    * def v = call createFund { id: #(fundId2), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId5), allocated: 100, fundId: #(fundId2), status: Active, fiscalYearId: #(pastFiscalYearId1) }
    * def v = call createBudget { id: #(budgetId6), allocated: 100, fundId: #(fundId2), status: Active, fiscalYearId: #(presentFiscalYearId) }
    * def v = call createBudget { id: #(budgetId7), allocated: 100, fundId: #(fundId2), status: Active, fiscalYearId: #(futureFiscalYearId) }
    # fund 3 has a budget for all fiscal years
    * def v = call createFund { id: #(fundId3), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId8), allocated: 100, fundId: #(fundId3), status: Active, fiscalYearId: #(pastFiscalYearId1) }
    * def v = call createBudget { id: #(budgetId9), allocated: 100, fundId: #(fundId3), status: Active, fiscalYearId: #(pastFiscalYearId2) }
    * def v = call createBudget { id: #(budgetId10), allocated: 100, fundId: #(fundId3), status: Active, fiscalYearId: #(presentFiscalYearId) }
    * def v = call createBudget { id: #(budgetId11), allocated: 100, fundId: #(fundId3), status: Active, fiscalYearId: #(futureFiscalYearId) }
    # fund 4 only has a budget for the future fiscal year
    * def v = call createFund { id: #(fundId4), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId12), allocated: 100, fundId: #(fundId4), status: Active, fiscalYearId: #(futureFiscalYearId) }

  Scenario: Create invoice 1
    * def v = call createInvoice { id: #(invoiceId1) }

  Scenario: Add an invoice line for each fund
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId1), invoiceId: #(invoiceId1), fundId: #(fundId1), total: 1 }
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId2), invoiceId: #(invoiceId1), fundId: #(fundId2), total: 2 }
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId3), invoiceId: #(invoiceId1), fundId: #(fundId3), total: 3 }

  Scenario: Get the fiscal years for invoice 1
    Given path 'invoice/invoices', invoiceId1, 'fiscal-years'
    When method GET
    Then status 200
    And match $.totalRecords == 2
    # should only include past fiscal year 1 and present fiscal year
    And match $.fiscalYears[0].id == presentFiscalYearId
    And match $.fiscalYears[1].id == pastFiscalYearId1

  Scenario: Create invoice 2
    * def v = call createInvoice { id: #(invoiceId2) }

  Scenario: Add an invoice line using fund 4
    # NOTE: this currently fails because fund 4 does not have a current budget
    # So this is disabled until it becomes supported - the result will be the same without any line
    # * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId4), invoiceId: #(invoiceId2), fundId: #(fundId4), total: 1 }

  Scenario: Get the fiscal years for invoice 2
    Given path 'invoice/invoices', invoiceId2, 'fiscal-years'
    When method GET
    Then status 422
    And match $.errors[0].code == 'couldNotFindValidFiscalYear'
