Feature: Check invoice lines and documents are deleted with invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def documentPayload = read('classpath:samples/mod-invoice/documents/sample-pdf.json')


  Scenario: Create an invoice, add a line and a document, delete the invoice, and check the line and document are gone
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid
    * def documentId = call uuid

    # 1. Create the invoice
    * def v = call createInvoice { id: '#(invoiceId)' }

    # 2. Create the invoice line
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', fundId: '#(globalFundId)', total: 100 }

    # 3. Create the invoice document
    * set documentPayload.documentMetadata.id = documentId
    * set documentPayload.documentMetadata.invoiceId = invoiceId
    * configure headers = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)'  }
    Given path 'invoice/invoices', invoiceId, 'documents'
    And request documentPayload
    When method POST
    Then status 201

    # 4. Get the invoice line
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200

    # 5. Get the document
    Given path 'invoice/invoices', invoiceId, 'documents', documentId
    When method GET
    Then status 200

    # 6. Delete the invoice
    Given path 'invoice/invoices', invoiceId
    When method DELETE
    Then status 204

    # 7. Verify the invoice line was deleted
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 404

    # 8. Verify the document was deleted
    Given path 'invoice/invoices', invoiceId, 'documents', documentId
    When method GET
    Then status 404
