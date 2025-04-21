# https://folio-org.atlassian.net/browse/MODORGSTOR-164
Feature: Audit events for Organization

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)'  }

    * configure headers = headersAdmin
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables
    * def orgId = callonce uuid

  Scenario: Creating Organization should produce "Create" event
    * table organizationData
      | id    | name       | code | status   |
      | orgId | "Test Org" | "TO" | "Active" |
    * def v = call createOrganization organizationData

    * table eventData
      | eventEntityId | eventType | eventCount |
      | orgId         | "Create"  | 1          |
    * def v = call read('@VerifyAuditEvents') eventData

  Scenario: Updating Organization should produce "Edit" event
    Given path 'organizations/organizations', orgId
    When method GET
    Then status 200
    * def org = response

    Given path 'organizations/organizations', orgId
    And request org
    When method PUT
    Then status 204

    * table eventData
      | eventEntityId | eventType | eventCount |
      | orgId         | "Edit"    | 2          |
    * def v = call read('@VerifyAuditEvents') eventData

  Scenario: Update Organization 50 times
    * def orgIds = []
    * def populateOrgIds =
      """
      function() {
        for (let i = 0; i < 50; i++) {
          orgIds.push({'newOrgId': orgId});
        }
      }
      """
    * eval populateOrgIds()
    * def v = call read('@UpdateOrganization') orgIds

    * table eventData
      | eventEntityId | eventType | eventCount |
      | orgId         | "Edit"    | 52         |
    * def v = call read('@VerifyAuditEvents') eventData

  @ignore @VerifyAuditEvents
  Scenario: Verify Audit Events
    Given path '/audit-data/acquisition/organization', eventEntityId
    And retry until response.totalItems == eventCount
    When method GET
    Then status 200
    And match response.totalItems == eventCount
    And match response.organizationAuditEvents[*].action contains eventType
    And match response.organizationAuditEvents[*].organizationId contains eventEntityId

  @ignore @UpdateOrganization
  Scenario: Update Organization
    Given path 'organizations/organizations', newOrgId
    When method GET
    Then status 200
    * def org = response

    Given path 'organizations/organizations', newOrgId
    And request org
    When method PUT
    Then status 204