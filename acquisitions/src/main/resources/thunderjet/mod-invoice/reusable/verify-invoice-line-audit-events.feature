@ignore
Feature: Verify invoice line audit event
  # parameters: eventEntityId, eventCount, eventType

  Background:
    * url baseUrl

  Scenario: verifyInvoiceLineAuditEvents
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/invoice-line', eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.invoiceLineAuditEvents[*].action contains eventType
    And match response.invoiceLineAuditEvents[*].invoiceLineId contains eventEntityId
