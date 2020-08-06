Feature: Check invoice and invoice lines deletion restrictions

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_invoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/to-check-invoice-and-invoice-lines-deletion-restrictions.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoiceLines/to-check-invoice-and-invoice-lines-deletion-restrictions.json')

  Scenario: Create approved invoice and invoice line
    * def approvedInvoiceId = call uuid
    * def approvedInvoiceLineId = call uuid
    * set invoicePayload.id = approvedInvoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * set invoiceLinePayload.id = approvedInvoiceLineId
    * set invoiceLinePayload.invoiceId = approvedInvoiceId

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= get invoice to approve ===================
    Given path 'invoice/invoices', approvedInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"

    # ============= put approved invoice ===================
    Given path 'invoice/invoices', approvedInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Create paid invoice and invoice line
    * def paidInvoiceId = call uuid
    * def paidInvoiceLineId = call uuid
    * set invoicePayload.id = paidInvoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * set invoiceLinePayload.id = paidInvoiceLineId
    * set invoiceLinePayload.invoiceId = paidInvoiceId

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= get invoice to pay ===================
    Given path 'invoice/invoices', paidInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Paid"

    # ============= put paid invoice ===================
    Given path 'invoice/invoices', paidInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  # test invoice and invoice line deletion restrictions
  Scenario: Delete approved invoice and invoice line
    # ============= try to delete approved invoice ===================
    Given path 'invoice/invoices', approvedInvoiceId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"

    # ============= try to delete approved invoice line ===================
    Given path 'invoice/invoice-lines', approvedInvoiceLineId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"

  Scenario: Delete paid invoice and invoice line
    # ============= try to delete paid invoice ===================
    Given path 'invoice/invoices', paidInvoiceId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"

    # ============= try to delete paid invoice line ===================
    Given path 'invoice/invoice-lines', paidInvoiceLineId
    When method DELETE
    Then status 403
    And match response.errors[0].code == "approvedOrPaidInvoiceDeleteForbiddenError"
