@ignore
Feature: Update invoice
  # parameters: invoiceId

  Background:
    * url baseUrl

  Scenario: updateInvoice
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = response

    Given path 'invoice/invoices', invoiceId
    And request invoice
    When method PUT
    Then status 204
