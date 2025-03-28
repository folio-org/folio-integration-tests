@ignore
Feature: Get invoice by id
  # parameters: invoiceId
  # returns: invoice

  Background:
    * url baseUrl

  Scenario: Get invoice by id
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    * def invoice = $
