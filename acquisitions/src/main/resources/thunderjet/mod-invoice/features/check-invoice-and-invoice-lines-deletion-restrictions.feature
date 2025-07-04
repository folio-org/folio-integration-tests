@parallel=false
Feature: Check invoice and invoice lines deletion restrictions

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    # prepare sample data
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/to-check-invoice-and-invoice-lines-deletion-restrictions.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoiceLines/to-check-invoice-and-invoice-lines-deletion-restrictions.json')

    # initialize common invoice data
    * def approvedInvoiceId = callonce uuid1
    * def approvedInvoiceLineId = callonce uuid2
    * def paidInvoiceId = callonce uuid3
    * def paidInvoiceLineId = callonce uuid4

  Scenario: Create approved invoice and invoice line
    * copy invoicePayload = invoiceTemplate
    * set invoicePayload.id = approvedInvoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * copy invoiceLinePayload = invoiceLineTemplate
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
    * copy invoicePayload = invoiceTemplate
    * set invoicePayload.id = paidInvoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * copy invoiceLinePayload = invoiceLineTemplate
    * set invoiceLinePayload.id = paidInvoiceLineId
    * set invoiceLinePayload.invoiceId = paidInvoiceId

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= approve the invoice ===================
    Given path 'invoice/invoices', paidInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"
    Given path 'invoice/invoices', paidInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

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
