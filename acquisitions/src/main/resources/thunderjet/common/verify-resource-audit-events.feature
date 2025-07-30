@ignore
Feature: Verify resource audit event
  # parameters: resourcePath, entityName, eventEntityId, eventCount, eventType

  Background:
    * url baseUrl

  Scenario: verifyResourceAuditEvents
    * configure headers = headersAdmin
    Given path '/audit-data/acquisition', resourcePath, eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match karate.jsonPath(response, '$.' + entityName + 'AuditEvents[*].action') contains eventType
    And match karate.jsonPath(response, '$.' + entityName + 'AuditEvents[*].' + entityName + 'Id') contains eventEntityId
    * configure headers = headersUser
