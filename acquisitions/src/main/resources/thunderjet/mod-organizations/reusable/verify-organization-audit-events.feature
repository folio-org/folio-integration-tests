@ignore
Feature: Verify invoice audit event
  # parameters: eventEntityId, eventCount, eventType

  Background:
    * url baseUrl

  Scenario: verifyOrganizationAuditEvents
    * configure headers = headersAdmin
    Given path '/audit-data/acquisition/organization', eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.organizationAuditEvents[*].action contains eventType
    And match response.organizationAuditEvents[*].organizationId contains eventEntityId
    * configure headers = headersUser
