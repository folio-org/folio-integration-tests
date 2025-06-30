@ignore
Feature: Verify resource audit event
  # parameters: resourcePath, eventEntityId, eventCount, eventType

  Background:
    * url baseUrl

  Scenario: verifyResourceAuditEvents
    * configure headers = headersAdmin
    Given path '/audit-data/acquisition', resourcePath, eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.organizationAuditEvents[*].action contains eventType
    And match response.organizationAuditEvents[*].organizationId contains eventEntityId
    * configure headers = headersUser
