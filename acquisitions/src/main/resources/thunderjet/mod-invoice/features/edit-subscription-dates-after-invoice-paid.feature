# For MODINVOICE-328
Feature: Edit subscription dates after invoice is paid

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


  Scenario: Edit subscription dates after invoice is paid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 10000 }

    # 2. Create an invoice
    * configure headers = headersUser
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 3. Add an invoice line
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    * remove invoiceLine.fundDistributions[0].expenseClassId
    * set invoiceLine.subscriptionStart = '2018-08-01T00:00:00.000+0000'
    * set invoiceLine.subscriptionEnd = '2018-08-02T00:00:00.000+0000'
    * set invoiceLine.subscriptionInfo = 'initial'

    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    # 4. Approve the invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 5. Pay the invoice
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    # 6. Change subscription dates
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = $

    * set invoiceLine.subscriptionStart = '2022-03-16T00:00:00.000+0000'
    * set invoiceLine.subscriptionEnd = '2022-03-17T00:00:00.000+0000'
    * set invoiceLine.subscriptionInfo = 'modified'

    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204
