# For https://issues.folio.org/browse/MODINVOICE-449
@parallel=false
Feature: Check invoiceLine validation with  adjustments

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceTemplateWithNoFunds = read('classpath:samples/mod-invoice/invoices/global/invoice-with-no-fund-distribution.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-with-adjustments.json')


  Scenario: Check invoice should be approved for no fund distribution in invoice_line adjustments.
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active'}] }
    * configure headers = headersUser

    * print "Create an invoice"
    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

    * print "Add an invoice line"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    * remove invoiceLine.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    * print "Approve the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


    * print "Check the invoice line status"
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match $.invoiceLineStatus == 'Approved'

  Scenario: Check invoice should not be approved for no fund distribution in invoice adjustments.
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 1000, 'fundId': '#(fundId)', 'status': 'Active'}] }
    * configure headers = headersUser

    * print "Create an invoice"
    * copy invoice = invoiceTemplateWithNoFunds
    * set invoice.id = invoiceId
    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201

    * print "Add an invoice line"
    * copy invoiceLine = invoiceLineTemplate
    * set invoiceLine.id = invoiceLineId
    * set invoiceLine.invoiceId = invoiceId
    * set invoiceLine.fundDistributions[0].fundId = fundId
    * set invoiceLine.total = 10
    * set invoiceLine.subTotal = 10
    * remove invoiceLine.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLine
    When method POST
    Then status 201

    * print "Approve the invoice"
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
    * set invoice.status = 'Approved'
    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 400
    And match response.errors[0].message == "At least one fund distribution should present for every non-prorated adjustment"
    And match response.errors[0].code == "adjustmentFundDistributionsNotPresent"

