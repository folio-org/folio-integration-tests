@ignore
Feature: Update invoice line
  # parameters: invoiceLineId

  Background:
    * url baseUrl

  Scenario: updateInvoiceLine
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    * def invoiceLine = response

    Given path 'invoice/invoice-lines', invoiceLineId
    And request invoiceLine
    When method PUT
    Then status 204