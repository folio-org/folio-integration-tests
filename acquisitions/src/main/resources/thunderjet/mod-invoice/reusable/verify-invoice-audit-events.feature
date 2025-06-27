@ignore
Feature: Verify invoice audit event
  # parameters: eventEntityId, eventCount, eventType

  Background:
    * url baseUrl

  Scenario: verifyInvoiceAuditEvent
    * configure headers = headersAdmin
    Given path '/audit-data/acquisition/invoice', eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.invoiceAuditEvents[*].action contains eventType
    And match response.invoiceAuditEvents[*].invoiceId contains eventEntityId
