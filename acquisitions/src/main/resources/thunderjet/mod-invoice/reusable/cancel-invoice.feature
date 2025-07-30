@ignore
Feature: Cancel invoice
  # parameters: invoiceId, poLinePaymentStatus?

  Background:
    * url baseUrl

  Scenario: Cancel invoice
    * def poLinePaymentStatus = karate.get('poLinePaymentStatus', null)

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Cancelled'

    Given path 'invoice/invoices', invoiceId
    And param poLinePaymentStatus = poLinePaymentStatus
    And request invoice
    When method PUT
    Then status 204
