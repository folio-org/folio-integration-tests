Feature: Create invoice
  # parameters: id

  Background:
    * url baseUrl

  Scenario: createInvoice
    * def invoice = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def fiscalYearId = karate.get('fiscalYearId', null)
    * set invoice.id = id
    * set invoice.fiscalYearId = fiscalYearId

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201
