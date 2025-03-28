Feature: Cancel invoice
  # parameters: invoiceId

  Background:
    * url baseUrl

  Scenario: Cancel invoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Cancelled'

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204
