Feature: Check that it is impossible to add an invoice line to an already approved invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Check that it is impossible to add an invoice line to an already approved invoice
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')

    * def invoiceId = call uuid
    * def firstInvoiceLineId = call uuid
    * def secondInvoiceLineId = call uuid

    # 1. Create invoice with lockTotal and without adjustment
    * set invoicePayload.id = invoiceId
    * set invoicePayload.lockTotal = 10.02
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201
    And match $.currency == 'USD'
    And match $.status == 'Open'
    And match $.adjustmentsTotal == 0.0
    And match $.lockTotal == 10.02
    And match $.subTotal == 0.0
    And match $.total == 0.0

    # 2. Add first invoice line to created invoice
    * copy invoiceLine1 = invoiceLineTemplate
    * set invoiceLine1.id = firstInvoiceLineId
    * set invoiceLine1.invoiceId = invoiceId
    * set invoiceLine1.quantity = 1
    * set invoiceLine1.subTotal = 10.02
    * set invoiceLine1.total = 10.02
    * remove invoiceLine1.fundDistributions[0].expenseClassId

    Given path 'invoice/invoice-lines'
    And request invoiceLine1
    When method POST
    Then status 201
    And match $.adjustmentsTotal == 0.0
    And match $.subTotal == 10.02
    And match $.total == 10.02

    # 3. Approve invoice with lock total is not equal to calculated total
  * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 4. Add second invoice line to created invoice, check error code
    * copy invoiceLine2 = invoiceLineTemplate
    * set invoiceLine2.id = secondInvoiceLineId
    * set invoiceLine2.invoiceId = invoiceId
    * set invoiceLine2.quantity = 1
    * set invoiceLine2.subTotal = 11.02
    * set invoiceLine2.total = 11.02
    * remove invoiceLine2.fundDistributions[0].expenseClassId

    Given path 'invoice/invoice-lines'
    And request invoiceLine2
    When method POST
    Then status 500
    And match $.errors[0].code == 'prohibitedInvoiceLineCreation'
