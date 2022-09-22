# Created for MODINVOICE-294. Don't allow to pay for the invoice which was not approved before
Feature: Check that it is not impossible to pay for the invoice without approved status

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testinvoices'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    # prepare sample data
    * def invoiceTemplate = read('classpath:samples/mod-invoice/invoices/to-check-invoice-and-invoice-lines-deletion-restrictions.json')
    * def invoiceLineTemplate = read('classpath:samples/mod-invoice/invoiceLines/to-check-invoice-and-invoice-lines-deletion-restrictions.json')

    # initialize common invoice data
    * def openInvoiceId = callonce uuid1
    * def openInvoiceLineId = callonce uuid2
    * def reviewedInvoiceId = callonce uuid3
    * def reviewedInvoiceLineId = callonce uuid4
    * def cancelledInvoiceId = callonce uuid5
    * def cancelledInvoiceLineId = callonce uuid6

  Scenario: Create invoice with 'Open' status
    * copy invoicePayload = invoiceTemplate
    * set invoicePayload.id = openInvoiceId
    * set invoicePayload.lockTotal = 10.02

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * copy invoiceLinePayload = invoiceLineTemplate
    * set invoiceLinePayload.id = openInvoiceLineId
    * set invoiceLinePayload.invoiceId = openInvoiceId

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= get invoice===================
    Given path 'invoice/invoices', openInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Open"

    # ============= put open invoice ===================
    Given path 'invoice/invoices', openInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Pay for invoice with 'Open' status
    Given path 'invoice/invoices', openInvoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'

    Given path 'invoice/invoices', openInvoiceId
    And request invoicePayload
    When method PUT
    Then status 400
    And match $.errors[0].code == 'cannotPayInvoiceWithoutApproval'


  Scenario: Create invoice with 'Reviewed' status
    * copy invoicePayload = invoiceTemplate
    * set invoicePayload.id = reviewedInvoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * copy invoiceLinePayload = invoiceLineTemplate
    * set invoiceLinePayload.id = reviewedInvoiceLineId
    * set invoiceLinePayload.invoiceId = reviewedInvoiceId

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= get invoice to review ===================
    Given path 'invoice/invoices', reviewedInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Reviewed"

    # ============= put reviewed invoice ===================
    Given path 'invoice/invoices', reviewedInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Pay for invoice with 'Reviewed' status
    Given path 'invoice/invoices', reviewedInvoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'

    Given path 'invoice/invoices', reviewedInvoiceId
    And request invoicePayload
    When method PUT
    Then status 400
    And match $.errors[0].code == 'cannotPayInvoiceWithoutApproval'

  Scenario: Create invoice with 'Cancelled' status
    * copy invoicePayload = invoiceTemplate
    * set invoicePayload.id = cancelledInvoiceId

    # ============= create invoice ===================
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    * copy invoiceLinePayload = invoiceLineTemplate
    * set invoiceLinePayload.id = cancelledInvoiceLineId
    * set invoiceLinePayload.invoiceId = cancelledInvoiceId

    # ============= create invoice lines ===================
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= approve the invoice ===================
    Given path 'invoice/invoices', cancelledInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Approved"
    Given path 'invoice/invoices', cancelledInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

    # ============= get invoice to cancel ===================
    Given path 'invoice/invoices', cancelledInvoiceId
    When method GET
    Then status 200
    * def invoiceBody = $
    * set invoiceBody.status = "Cancelled"

    # ============= put cancelled invoice ===================
    Given path 'invoice/invoices', cancelledInvoiceId
    And request invoiceBody
    When method PUT
    Then status 204

  Scenario: Pay for invoice with 'Cancelled' status
    Given path 'invoice/invoices', cancelledInvoiceId
    When method GET
    Then status 200
    * def invoicePayload = $
    * set invoicePayload.status = 'Paid'

    Given path 'invoice/invoices', cancelledInvoiceId
    And request invoicePayload
    When method PUT
    Then status 400
    And match $.errors[0].code == 'cannotPayInvoiceWithoutApproval'
