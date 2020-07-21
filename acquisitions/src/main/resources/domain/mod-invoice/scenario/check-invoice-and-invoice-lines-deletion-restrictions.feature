Feature: Check invoice and invoice lines deletion restrictions

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_invoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * print okapitokenAdmin

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }

    * configure headers = headersUser

  # prepare sample data
    * def invoicePayload = read('samples/invoice.json')
    * def invoiceLinePayload = read('samples/invoiceLine.json')

  Scenario: Create approved invoice and invoice line
    * def approvedInvoiceId = call uuid
    * def approvedInvoiceLineId = call uuid
    * set invoicePayload.id = approvedInvoiceId

    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * set invoiceLinePayload.id = approvedInvoiceLineId
    * set invoiceLinePayload.invoiceId = approvedInvoiceId

    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    Given path 'invoice/invoices', approvedInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"

    Given path 'invoice/invoices', approvedInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Create paid invoice and invoice line
    * def paidInvoiceId = call uuid
    * def paidInvoiceLineId = call uuid
    * set invoicePayload.id = paidInvoiceId

    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * set invoiceLinePayload.id = paidInvoiceLineId
    * set invoiceLinePayload.invoiceId = paidInvoiceId

    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    Given path 'invoice/invoices', paidInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Paid"

    Given path 'invoice/invoices', paidInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  # test invoice and invoice line deletion restrictions
  Scenario: Delete approved invoice and invoice line
    Given path 'invoice/invoices', approvedInvoiceId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"

    Given path 'invoice/invoice-lines', approvedInvoiceLineId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"

  Scenario: Delete paid invoice and invoice line
    Given path 'invoice/invoices', paidInvoiceId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"

    Given path 'invoice/invoice-lines', paidInvoiceLineId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"