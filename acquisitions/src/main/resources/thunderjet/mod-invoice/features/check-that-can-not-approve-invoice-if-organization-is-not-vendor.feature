Feature: Check that can not approve invoice if organization is not vendor

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
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/to-check-invoice-and-invoice-lines-deletion-restrictions.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoiceLines/to-check-invoice-and-invoice-lines-deletion-restrictions.json')

    # initialize common invoice data
    * def approvedInvoiceId = callonce uuid1
    * def approvedInvoiceLineId = callonce uuid2
    * def paidInvoiceId = callonce uuid3
    * def paidInvoiceLineId = callonce uuid4

  Scenario: Create approved invoice and invoice line
    * set invoicePayload.id = approvedInvoiceId
    * set invoicePayload.vendorId = globalOrgIsNotVendorId

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
    Then status 400
    And response.errors[0].code == "organizationIsNotExist"
