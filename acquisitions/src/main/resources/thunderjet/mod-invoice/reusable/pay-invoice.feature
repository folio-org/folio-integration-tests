@ignore
Feature: Pay invoice
  # parameters: invoiceId, poLinePaymentStatus?

  Background:
    * url baseUrl

  Scenario: Pay invoice
    * def poLinePaymentStatus = karate.get('poLinePaymentStatus', null)

    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200

    * def invoice = $
    * set invoice.status = 'Paid'

    Given path 'invoice/invoices', invoiceId
    And param poLinePaymentStatus = poLinePaymentStatus
    And request invoice
    When method PUT
    Then status 204
