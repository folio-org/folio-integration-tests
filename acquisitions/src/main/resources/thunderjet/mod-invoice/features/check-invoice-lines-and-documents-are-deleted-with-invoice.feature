Feature: Check invoice lines and documents are deleted with invoice

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
    * def invoicePayload = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def invoiceLinePayload = read('classpath:samples/mod-invoice/invoices/global/invoice-line-percentage.json')
    * def documentPayload = read('classpath:samples/mod-invoice/documents/sample-pdf.json')

    # initialize common invoice data
    * def invoiceId = callonce uuid1
    * def invoiceLineId = callonce uuid2
    * def documentId = callonce uuid3

  Scenario: Create an invoice, add a line and a document, delete the invoice, and check the line and document are gone
    # ============= create the invoice ===================
    * set invoicePayload.id = invoiceId
    Given path 'invoice/invoices'
    And request invoicePayload
    When method POST
    Then status 201

    # ============= create the invoice line ===================
    * set invoiceLinePayload.id = invoiceLineId
    * set invoiceLinePayload.invoiceId = invoiceId
    * remove invoiceLinePayload.fundDistributions[0].expenseClassId
    Given path 'invoice/invoice-lines'
    And request invoiceLinePayload
    When method POST
    Then status 201

    # ============= create the invoice document ================
    * set documentPayload.documentMetadata.id = documentId
    * set documentPayload.documentMetadata.invoiceId = invoiceId
    * configure headers = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    Given path 'invoice/invoices', invoiceId, 'documents'
    And request documentPayload
    When method POST
    Then status 201
    * configure headers = headersUser

    # ============= get the invoice line ===================
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200

    # ============= get the document ===================
    Given path 'invoice/invoices', invoiceId, 'documents', documentId
    When method GET
    Then status 200

    # ============= delete the invoice ===================
    Given path 'invoice/invoices', invoiceId
    When method DELETE
    Then status 204

    # ============= verify the invoice line was deleted ===================
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 404

    # ============= verify the document was deleted ===================
    Given path 'invoice/invoices', invoiceId, 'documents', documentId
    When method GET
    Then status 404
