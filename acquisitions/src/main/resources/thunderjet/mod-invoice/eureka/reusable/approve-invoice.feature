Feature: Approve invoice
  # parameters: invoiceId

  Background:
    * url baseUrl

  Scenario: Approve invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Approved'

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204
