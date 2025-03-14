Feature: Create invoice
  # parameters: id, fiscalYearId?, acqUnitIds?, currency?, adjustments?

  Background:
    * url baseUrl

  Scenario: createInvoice
    * def invoice = read('classpath:samples/mod-invoice/invoices/global/invoice.json')
    * def fiscalYearId = karate.get('fiscalYearId', null)
    * def acqUnitIds = karate.get('acqUnitIds', [])
    * def currency = karate.get('currency', "USD")
    * def adjustments = karate.get('adjustments', [])
    * set invoice.id = id
    * set invoice.fiscalYearId = fiscalYearId
    * set invoice.acqUnitIds = acqUnitIds
    * set invoice.currency = currency
    * set invoice.adjustments = adjustments

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201
