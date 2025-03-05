Feature: Create invoice
  # parameters: id, acqUnitIds?

  Background:
    * url baseUrl

  Scenario: createInvoice
    * def invoice = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def fiscalYearId = karate.get('fiscalYearId', null)
    * def acqUnitIds = karate.get('acqUnitIds', [])
    * set invoice.id = id
    * set invoice.fiscalYearId = fiscalYearId
    * set invoice.acqUnitIds = acqUnitIds

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201
