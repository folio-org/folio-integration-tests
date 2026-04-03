# For MODINVOICE-473
Feature: Set invoice fiscal year automatically

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

    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')


  Scenario: Set invoice fiscal year automatically
    * def currentYear = callonce getCurrentYear
    * def currentStart = currentYear + '-01-01T00:00:00Z'
    * def currentEnd = currentYear + '-12-30T23:59:59Z'

    * def pastFiscalYearId = call uuid
    * def currentFiscalYearId = call uuid
    * def ledgerId = call uuid
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId1 = call uuid
    * def invoiceLineId2 = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFiscalYear { id: #(pastFiscalYearId), code: 'SETFYTEST2020', periodStart: '2020-01-01T00:00:00Z', periodEnd: '2020-12-30T23:59:59Z', series: 'SETFYTEST' }
    * def v = call createFiscalYear { id: #(currentFiscalYearId), code: #('SETFYTEST' + currentYear), periodStart: #(currentStart), periodEnd: #(currentEnd), series: 'SETFYTEST' }
    * def v = call createLedger { id: #(ledgerId), fiscalYearId: #(pastFiscalYearId), restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: #(fundId1), ledgerId: #(ledgerId) }
    * def v = call createFund { id: #(fundId2), ledgerId: #(ledgerId) }
    * def v = call createBudget { id: #(budgetId1), allocated: 100, fundId: #(fundId1), status: 'Active', fiscalYearId: #(currentFiscalYearId) }
    * def v = call createBudget { id: #(budgetId2), allocated: 100, fundId: #(fundId2), status: 'Active', fiscalYearId: #(pastFiscalYearId) }

    # 2. Create an invoice without specifying the fiscal year
    * configure headers = headersUser
    * def v = call createInvoice { id: #(invoiceId) }

    # 3. Add invoice line 1 using fund 1
    * def v = call createInvoiceLine { invoiceLineId: #(invoiceLineId1), invoiceId: #(invoiceId), fundId: #(fundId1), total: 10 }

    # 4. Check the invoice fiscalYearId
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match $.fiscalYearId == currentFiscalYearId

    # 5. Try to add invoice line 2 using fund 2
    # This will fail because fund2 does not have an active budget in the current fiscal year
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId2
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.fundDistributions[0].fundId = fundId2
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 404
    And match $.errors[0].code == 'budgetNotFoundByFundIdAndFiscalYearId'
