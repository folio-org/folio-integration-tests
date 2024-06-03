# MODINVOICE-544
Feature: Cancel an invoice with an Encumbrance

  Background:
    * url baseUrl

    * call login testAdmin
    * def okapitokenAdmin = okapitoken

    * call login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * call variables

    * def cancelInvoiceCheckEncumbrance = read('classpath:thunderjet/mod-invoice/reusable/cancel-invoice-check-encumbrance-status.feature')

  @Positive
  Scenario: Cancel an invoice with an Encumbrance
    * table statusTable
      | paymentStatus          |
      | 'Pending'              |
      | 'Payment Not Required' |
    * call cancelInvoiceCheckEncumbrance statusTable