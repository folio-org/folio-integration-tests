@ignore
Feature: Create invoice
  # parameters: id, fiscalYearId?, acqUnitIds?, currency?, adjustments?, exchangeRate?

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create invoice
    * def invoice = read('classpath:samples/mod-invoice/invoices/global/invoice.json')

    * def fiscalYearId = karate.get('fiscalYearId', null)
    * def acqUnitIds = karate.get('acqUnitIds', [])
    * def currency = karate.get('currency', "USD")
    * def adjustments = karate.get('adjustments', [])
    * def exchangeRate = karate.get('exchangeRate', null)

    * set invoice.id = id
    * set invoice.fiscalYearId = fiscalYearId
    * set invoice.acqUnitIds = acqUnitIds
    * set invoice.currency = currency
    * set invoice.adjustments = adjustments
    * set invoice.exchangeRate = exchangeRate

    Given path 'invoice/invoices'
    And request invoice
    When method POST
    Then status 201
