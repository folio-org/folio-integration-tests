# For https://issues.folio.org/browse/MODINVOICE-328
@parallel=false
Feature: Edit subscription dates after invoice is paid

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def invoiceId = callonce uuid5
    * def invoiceLineId = callonce uuid6


  Scenario: Create finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }


  Scenario: Create an invoice
    * print "Create an invoice"

    * copy invoice = invoiceTemplate
    * set invoice.id = invoiceId

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201


  Scenario: Add an invoice line
    * print "Add an invoice line"

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


  Scenario: Approve the invoice
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


  Scenario: Pay the invoice
    * print "Pay the invoice"

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Paid'

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204


  Scenario: Change subscription dates
    * print "Change subscription dates"

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


