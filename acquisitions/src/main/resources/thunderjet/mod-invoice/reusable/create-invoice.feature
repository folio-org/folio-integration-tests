Feature: Create invoice
  # parameters: id

  Background:
    * url baseUrl

  Scenario: createInvoice
    * def invoice = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * set invoice.id = id

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201
